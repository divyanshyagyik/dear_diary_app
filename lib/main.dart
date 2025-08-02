import 'package:dear_diary/api/firebase_api.dart';
import 'package:dear_diary/services/AdMobService.dart';
import 'package:dear_diary/services/payment_service.dart';
import 'package:dear_diary/views/email_auth/sign_in_page.dart';
import 'package:dear_diary/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  await AdMobService.initialize();


  // Initialize GetX controllers
  Get.put(AuthController());
  Get.put(PaymentService());

  // Initialize notifications
  await FirebaseApi().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Diary',
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Obx(() {
      return authController.firebaseUser.value != null
          ? HomePage()
          : SignInPage();
    });
  }
}