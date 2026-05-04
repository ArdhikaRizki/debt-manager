import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SpinMember {
  final String username;
  bool isSelected;

  SpinMember({required this.username, this.isSelected = true});
}

class SpinWheelGameScreen extends StatefulWidget {
  final List<String> usernames;

  const SpinWheelGameScreen({super.key, required this.usernames});

  @override
  State<SpinWheelGameScreen> createState() => _SpinWheelGameScreenState();
}

class _SpinWheelGameScreenState extends State<SpinWheelGameScreen> {
  late List<SpinMember> _members;

  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;
  final StreamController<int> _wheelController = StreamController<int>.broadcast();
  
  bool _hasSpun = false;
  String _winnerText = '';
  int _winnerIndex = 0; 

  List<SpinMember> get _activeMembers => _members.where((m) => m.isSelected).toList();

  @override
  void initState() {
    super.initState();
    _members = widget.usernames.map((u) => SpinMember(username: u)).toList();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _initSensor();
    });
  }

  void _initSensor() {
    _sensorSubscription?.cancel();
    _sensorSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (_hasSpun) return; 

      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      if (acceleration > 15.0 && _activeMembers.length > 1) {
        _triggerSpin();
      }
    });
  }

  void _triggerSpin() {
    setState(() {
      _hasSpun = true; 
    });

    _sensorSubscription?.cancel(); 

    _winnerIndex = Random().nextInt(_activeMembers.length);
    _wheelController.add(_winnerIndex);
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _wheelController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Roda Penentu Nasib Reimbursement', style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _activeMembers.length > 1
                  ? FortuneWheel(
                      animateFirst: false, 
                      selected: _wheelController.stream,
                      items: [
                        for (var member in _activeMembers)
                          FortuneItem(
                            child: Text(
                              member.username,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: FortuneItemStyle(
                              color: _getRandomColor(member.username),
                              borderColor: Colors.white,
                              borderWidth: 2,
                            ),
                          ),
                      ],
                      onAnimationEnd: () {
                        if (!_hasSpun) return; 

                        setState(() {
                          _winnerText = "🎉 ${_activeMembers[_winnerIndex].username} yang nalangin!";
                        });
                        _showWinnerDialog();
                      },
                    )
                  : const Center(
                      child: Text(
                        "Minimal 2 orang yang ikut patungan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _hasSpun ? _winnerText : 'Goyangin HP kamu!, nanti dia yang bayar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: _hasSpun ? FontWeight.bold : FontWeight.w500,
                color: _hasSpun ? Colors.green[700] : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return CheckboxListTile(
                    title: Text(
                      member.username,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    value: member.isSelected,
                    activeColor: Colors.black87,
                    onChanged: _hasSpun 
                        ? null 
                        : (bool? value) {
                            setState(() {
                              member.isSelected = value ?? false;
                            });
                          },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hasil Keputusan', textAlign: TextAlign.center),
        content: Text(
          _winnerText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              
              setState(() {
                _hasSpun = false; 
                _winnerText = ''; 
              });
              
              _initSensor(); 
            },
            child: const Text('Tutup & Ulangi'),
          )
        ],
      ),
    );
  }

  Color _getRandomColor(String username) {
    final colors = [
      Colors.blue[400]!,
      Colors.red[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
    ];
    int hash = username.hashCode.abs();
    return colors[hash % colors.length];
  }
}
