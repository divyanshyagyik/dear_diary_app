import 'package:dear_diary/views/analytics_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/diary_controller.dart';
import '../widgets/BannerAdWidget.dart';
import '../widgets/NoAdsScreen.dart';
import 'email_auth/sign_in_page.dart';
import 'entry_edit_page.dart';

class HomePage extends StatelessWidget {
  final DiaryController _diaryController = Get.put(DiaryController());
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    _authController.firebaseUser.value ?? Get.offAll(() => SignInPage());
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        actions: [
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            itemBuilder:
                (context) => [
                  PopupMenuItem(child: Text('Logout'), value: 'logout'),
                ],
            onSelected: (value) async {
              if (value == 'logout') {
                await _authController.signOut();
                Get.offAllNamed('/sign-in');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.no_accounts),
            onPressed: () => Get.to(() => PremiumPage()), // Add this
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.to(() => AnalyticsPage()),
          ),
        ],
      ),
      body: Column(children: [Expanded(child: _buildEntriesList()),BannerAdWidget(),]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Get.to(() => EntryEditPage()),
      ),
    );
  }

  Widget _buildEntriesList() {
    return Obx(() {
      if (_diaryController.entries.isEmpty) {
        return const Center(child: Text('No entries yet. Tap + to add one!'));
      }

      return ListView.builder(
        itemCount: _diaryController.entries.length,
        itemBuilder: (context, index) {
          final entry = _diaryController.entries[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Text(
                entry.sentimentEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(entry.title),
              subtitle: Text(entry.formattedDate),
              onTap: () => Get.to(() => EntryEditPage(entry: entry)),
            ),
          );
        },
      );
    });
  }
}
