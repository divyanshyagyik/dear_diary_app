import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Razorpay _razorpay = Razorpay();
  final Rx<SubscriptionStatus> subscriptionStatus = SubscriptionStatus.loading.obs;
  var nextBillingDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initPayment();
    _checkSubscription();
  }

  void _initPayment() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _checkSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('subscriptions').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        final expiry = (data['expiry_date'] as Timestamp).toDate();

        if (expiry.isAfter(DateTime.now())) {
          subscriptionStatus.value = SubscriptionStatus.active;
          nextBillingDate.value = expiry;
        } else {
          _handleSubscriptionEnd();
        }
      } else {
        subscriptionStatus.value = SubscriptionStatus.inactive;
      }
    } catch (e) {
      print('Subscription check error: $e');
      subscriptionStatus.value = SubscriptionStatus.inactive;
    }
  }

  void openCheckout(SubscriptionPlan plan) {
    try {
      final options = {
        'key': 'rzp_test_Z7NclbqzTLR8o5',
        'amount': plan.amountInPaise,
        'name': 'Dear Diary Premium',
        'description': plan.displayName,
        'prefill': {
          'email': _auth.currentUser?.email ?? '',
          'contact': '8955382123',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Failed to open payment: ${e.toString()}');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get payment details from Razorpay API
      final paymentDetails = await _getPaymentDetails(response.paymentId!);
      final amountPaid = paymentDetails['amount'] / 100; // Convert to rupees

      // Determine plan from payment amount
      final isYearly = amountPaid >= (SubscriptionPlan.yearly.amountInPaise / 100);
      final expiry = DateTime.now().add(
        isYearly ? Duration(days: 365) : Duration(days: 30),
      );

      await _firestore.collection('subscriptions').doc(user.uid).set({
        'plan': isYearly ? 'yearly' : 'monthly',
        'expiry_date': expiry,
        'last_payment': FieldValue.serverTimestamp(),
        'payment_id': response.paymentId,
        'amount_paid': amountPaid,
      });

      subscriptionStatus.value = SubscriptionStatus.active;
      nextBillingDate.value = expiry;

      Get.snackbar('Success', 'Payment successful!');
    } catch (e) {
      print('Payment success handling error: $e');
      Get.snackbar('Error', 'Failed to process payment');
    }
  }

  Future<Map<String, dynamic>> _getPaymentDetails(String paymentId) async {
    // In production, implement this using Razorpay API
    // This is a mock implementation for testing
    return {
      'amount': 29900, // Default to monthly amount
      'currency': 'INR',
      'status': 'captured'
    };
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle specific error codes
    final message = response.message ?? 'Payment failed';
    final code = response.code?.toString() ?? 'Unknown error';

    print('Payment error ($code): $message');
    Get.snackbar('Payment Failed', '$message (Code: $code)');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
    Get.snackbar('Info', 'Redirecting to ${response.walletName}');
  }

  void _handleSubscriptionEnd() {
    subscriptionStatus.value = SubscriptionStatus.inactive;
    Get.snackbar('Subscription Ended', 'Your premium access has expired');
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}

enum SubscriptionStatus { loading, active, inactive }

enum SubscriptionPlan {
  monthly('Monthly (₹299/month)', 29900),
  yearly('Yearly (₹2990/year)', 299000);

  final String displayName;
  final int amountInPaise;
  const SubscriptionPlan(this.displayName, this.amountInPaise);
}