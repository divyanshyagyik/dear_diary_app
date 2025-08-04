import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/payment_service.dart';

class PremiumPage extends StatelessWidget {
  final PaymentService payment = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFE5B4),
          title: Text('Go Ad-Free')),
      body:Obx(() {
          if (payment.subscriptionStatus.value == SubscriptionStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
              children: [
                _buildPlanCard(
                  context,
                  SubscriptionPlan.monthly,
                  payment.subscriptionStatus.value == SubscriptionStatus.active &&
                      payment.nextBillingDate.value != null &&
                      payment.nextBillingDate.value!
                              .difference(DateTime.now())
                              .inDays >
                          25,
                ),
                _buildPlanCard(
                  context,
                  SubscriptionPlan.yearly,
                  payment.subscriptionStatus.value == SubscriptionStatus.active &&
                      payment.nextBillingDate.value != null &&
                      payment.nextBillingDate.value!
                              .difference(DateTime.now())
                              .inDays >
                          300,
                ),
                if (payment.subscriptionStatus.value == SubscriptionStatus.active)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Next billing: ${DateFormat('MMM dd, yyyy').format(payment.nextBillingDate.value!)}',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
          );
        }
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    bool isCurrent,
  ) {
    return Card(
        margin: EdgeInsets.all(16),
        color: isCurrent ? Colors.green[50] : null,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                plan.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Text(
                '₹${plan.amountInPaise / 100} ${plan == SubscriptionPlan.monthly ? 'per month' : 'per year'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isCurrent ? null : () => payment.openCheckout(plan),
                child: Text(isCurrent ? 'Current Plan' : 'Subscribe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCurrent ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
