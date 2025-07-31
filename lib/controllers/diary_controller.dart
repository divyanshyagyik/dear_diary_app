import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';
import 'auth_controller.dart';

class DiaryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<DiaryEntry> entries = <DiaryEntry>[].obs;
  final String userId = Get.find<AuthController>().firebaseUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      loadEntries();
    } else {
      ever(Get.find<AuthController>().firebaseUser, (user) {
        if (user != null) {
          loadEntries();
        } else {
          entries.clear();
        }
      });
    }
  }

  Future<void> loadEntries() async {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      entries.assignAll(
        snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList(),
      );
    });
  }

  Future<void> addOrUpdateEntry(DiaryEntry entry) async {
    final collection = _firestore.collection('users').doc(userId).collection('entries');

    if (entry.id == null) {
      // Add new entry
      await collection.add(entry.toFirestore());
    } else {
      // Update existing entry
      await collection.doc(entry.id).update(entry.toFirestore());
    }
  }

  Future<void> deleteEntry(String id) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(id)
        .delete();
  }
}