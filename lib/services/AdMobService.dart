import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  // Your provided IDs
  static const String testDeviceId = "8F0774DC98F4591E4A87065098D2E390";
  static const String appId = "ca-app-pub-6722641929342110~5197357833";
  static const String bannerAdUnitId = "ca-app-pub-6722641929342110/8035274163";

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();

      // Configure for testing
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [testDeviceId],
        ),
      );

      if (kDebugMode) {
        print('AdMob initialized in TEST mode');
        print('Using test device ID: $testDeviceId');
      }
    } catch (e) {
      print('AdMob initialization error: $e');
    }
  }

  static String getBannerAdId() {
    // Use test ID in debug mode, real ID in release
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
        : bannerAdUnitId; // Your real ad unit ID
  }
}