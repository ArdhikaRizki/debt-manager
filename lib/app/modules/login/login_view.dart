import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Wave
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Color(0xFFFF8A8A),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sign in", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  Container(height: 4, width: 60, color: Color(0xFFFF8A8A), margin: EdgeInsets.only(top: 5)),
                  SizedBox(height: 40),
                  _buildInput("Email", "demo@email.com", Icons.email_outlined),
                  _buildInput("Password", "enter your password", Icons.lock_outline, isPass: true),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_box_outline_blank, color: Color(0xFFFF8A8A)),
                          SizedBox(width: 5),
                          Text("Remember Me", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text("Forgot Password?", style: TextStyle(color: Color(0xFFFF8A8A), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF8A8A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.signup),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an Account ? ",
                          style: TextStyle(color: Colors.grey),
                          children: [TextSpan(text: "Sign up", style: TextStyle(color: Color(0xFFFF8A8A), fontWeight: FontWeight.bold))]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, IconData icon, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
        TextField(
          obscureText: isPass,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPass ? Icon(Icons.visibility_outlined, size: 20) : null,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8A8A))),
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }
}

// Clipper untuk membuat lengkungan wave di atas
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}