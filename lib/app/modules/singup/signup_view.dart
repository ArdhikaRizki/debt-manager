import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/login_view.dart'; // Import Clipper yang sama

class SignupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(height: 180, width: double.infinity, color: Color(0xFFFF8A8A)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sign up", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  Container(height: 4, width: 60, color: Color(0xFFFF8A8A), margin: EdgeInsets.only(top: 5)),
                  SizedBox(height: 30),
                  _buildInput("Email", "demo@email.com", Icons.email_outlined),
                  _buildInput("Phone no", "+00 000-0000-000", Icons.phone_android),
                  _buildInput("Password", "enter your password", Icons.lock_outline, isPass: true),
                  _buildInput("Confirm Password", "confirm your password", Icons.lock_outline, isPass: true),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF8A8A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Create Account", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an Account! ",
                          style: TextStyle(color: Colors.grey),
                          children: [TextSpan(text: "Login", style: TextStyle(color: Color(0xFFFF8A8A), fontWeight: FontWeight.bold))]
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
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
        SizedBox(height: 20),
      ],
    );
  }
}