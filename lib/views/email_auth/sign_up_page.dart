import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SignUpPage extends StatelessWidget {
  final AuthController _authController = Get.find();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFFFFE5B4),
          title: Text('Sign Up')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5B4), Color(0xFF093952)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Email',),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              SizedBox(height: 9),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
              ),
              SizedBox(height: 9),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Confirm Password'),
                    obscureText: true,
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text != _confirmPasswordController.text) {
                    Get.snackbar('Error', 'Passwords do not match');
                    return;
                  }
                  _authController.signUp(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                },
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}