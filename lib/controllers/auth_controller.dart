import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> firebaseUser = Rx<User?>(null);

  Future<AuthController> init() async {
    firebaseUser.value = _auth.currentUser;
    firebaseUser.bindStream(_auth.authStateChanges());
    return this;
  }

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.back(); // Return to previous screen after successful signup
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Sign Up Failed', e.message ?? 'Unknown error');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Sign In Failed', e.message ?? 'Unknown error');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent');
      Get.back(); // Return to login screen
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Failed', e.message ?? 'Unknown error');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    firebaseUser.value = null; // aint tested
  }
}