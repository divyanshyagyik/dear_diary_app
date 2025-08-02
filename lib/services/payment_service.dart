import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService extends GetxController {
  static const _keyNoAds = 'no_ads_purchased';
  final Razorpay _razorpay = Razorpay();
  var hasPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initPayment();
    _loadPurchaseStatus();
  }

  Future<void> _loadPurchaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hasPremium.value = prefs.getBool(_keyNoAds) ?? false;
  }

  void _initPayment() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<bool> hasNoAds() async {
    return hasPremium.value;
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_Z7NclbqzTLR8o5',
      'amount': 29900,
      'name': 'Dear Diary Premium',
      'description': 'Ad-free experience',
      'prefill': {'contact': '9999999999', 'email': 'user@example.com'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Could not open payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNoAds, true);
    hasPremium.value = true;
    Get.snackbar('Success', 'Premium activated! Ads are now removed');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
}