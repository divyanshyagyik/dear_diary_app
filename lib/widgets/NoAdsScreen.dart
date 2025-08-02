import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/payment_service.dart';

class PremiumPage extends StatelessWidget {
  final PaymentService _paymentService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Go Ad-Free')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.no_accounts, size: 64, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Remove All Ads',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enjoy an uninterrupted diary experience',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _paymentService.openCheckout,
                      child: Text('Subscribe for ₹299/year'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: _paymentService.hasNoAds(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Text(
                    'Thank you for your subscription!',
                    style: TextStyle(color: Colors.green),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}