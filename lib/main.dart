import 'package:dear_diary/views/email_auth/sign_in_page.dart';
import 'package:dear_diary/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Diary',
      home: FutureBuilder(
        future: Get.putAsync(() => AuthController().init()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AuthWrapper();
          }
          return CircularProgressIndicator();
        },
      ),
      // Keep your existing routes if you have any
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _authController.firebaseUser.value != null
          ? HomePage()
          : SignInPage();
    });
  }
}