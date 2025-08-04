import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/AdMobService.dart';
import '../services/payment_service.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  final PaymentService _paymentService = Get.find();

  @override
  void initState() {
    super.initState();
    _initializeAd();
  }

  void _initializeAd() {
    if (_paymentService.subscriptionStatus.value != SubscriptionStatus.active) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId: AdMobService.getBannerAdId(),
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Ad loaded successfully');
          setState(() {
            _isLoaded = true;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: ${error.message} [${error.code}]');
          ad.dispose();
          setState(() => _isLoading = false);

          // Retry with exponential backoff
          final delay = _calculateRetryDelay(error.code);
          print('Retrying in $delay seconds...');
          Future.delayed(Duration(seconds: delay), _loadBannerAd);
        },
      ),
    )..load();
  }

  int _calculateRetryDelay(int errorCode) {
    // Handle different error codes
    switch (errorCode) {
      case 3: // No fill
        return 60;
      case 2: // Network error
        return 30;
      case 1: // Invalid request
        return 300; // Longer delay for configuration issues
      default:
        return 30;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Hide ads for premium users
      if (_paymentService.subscriptionStatus.value == SubscriptionStatus.active) {
        return SizedBox.shrink();
      }

      // Show loading indicator
      if (_isLoading) {
        return Container(
          height: AdSize.banner.height.toDouble(),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Show loaded ad
      if (_isLoaded) {
        return Container(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          child: AdWidget(ad: _bannerAd!),
        );
      }

      // Default empty container
      return Container(height: AdSize.banner.height.toDouble());
    });
  }
}