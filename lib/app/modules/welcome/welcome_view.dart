import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Merah dengan Pattern
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFFF8A8A),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
                // Uncomment jika sudah ada assetnya
                // image: DecorationImage(image: AssetImage('assets/topo.png'), fit: BoxFit.cover, opacity: 0.3)
              ),
            ),
          ),
          // Content
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  SizedBox(height: 10),
                  Text("Lorem ipsum dolor sit amet consectetur. Lorem id sit", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
                          SizedBox(width: 15),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Color(0xFFFF8A8A), shape: BoxShape.circle),
                            child: Icon(Icons.arrow_forward, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}