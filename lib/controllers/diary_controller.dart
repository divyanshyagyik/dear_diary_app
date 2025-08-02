import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';
import '../controllers/auth_controller.dart';

class DiaryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<DiaryEntry> entries = <DiaryEntry>[].obs;
  final AuthController _authController = Get.find();

  StreamSubscription? _entriesSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen for auth state changes
    ever(_authController.firebaseUser, (user) {
      if (user != null) {
        _loadEntries(user.uid);
      } else {
        _clearEntries();
      }
    });

    // Initial load if already logged in
    if (_authController.firebaseUser.value != null) {
      _loadEntries(_authController.firebaseUser.value!.uid);
    }
  }

  void _loadEntries(String userId) {
    // Cancel any existing subscription
    _entriesSubscription?.cancel();

    _entriesSubscription = _firestore
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

  void _clearEntries() {
    entries.clear();
    _entriesSubscription?.cancel();
    _entriesSubscription = null;
  }

  Future<void> addOrUpdateEntry(DiaryEntry entry) async {
    final userId = _authController.firebaseUser.value?.uid;
    if (userId == null) throw Exception("User not logged in");

    final collection = _firestore.collection('users').doc(userId).collection('entries');

    if (entry.id == null) {
      await collection.add(entry.toFirestore());
    } else {
      await collection.doc(entry.id).update(entry.toFirestore());
    }
  }

  Future<void> deleteEntry(String id) async {
    final userId = _authController.firebaseUser.value?.uid;
    if (userId == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(id)
        .delete();
  }

  @override
  void onClose() {
    _entriesSubscription?.cancel();
    super.onClose();
  }
}