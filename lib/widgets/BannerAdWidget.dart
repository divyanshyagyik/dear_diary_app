import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/AdMobService.dart';
import 'package:flutter/material.dart';

import '../services/payment_service.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final PaymentService _paymentService = Get.find();

  @override
  void initState() {
    super.initState();
    _checkAdStatus();
    //_loadBannerAd();
  }

  Future<void> _checkAdStatus() async {
    final hasNoAds = await _paymentService.hasNoAds();
    if (!hasNoAds) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.getBannerAdId(),
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner Ad loaded');
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad failed to load: $error');
          ad.dispose();
          // Retry after 30 seconds
          Future.delayed(Duration(seconds: 30), _loadBannerAd);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _paymentService.hasNoAds(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return SizedBox.shrink(); // Hide ads if subscribed
        }
        return _isLoaded
            ? Container(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : Container(height: 50);
      },
    );
  }
}