import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiaryEntry {
  String? id;
  final String title;
  final String content;
  final DateTime date;
  final int sentimentScore;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.sentimentScore,
  });

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      title: data['title'],
      content: data['content'],
      date: (data['date'] as Timestamp).toDate(),
      sentimentScore: data['sentimentScore'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'sentimentScore': sentimentScore,
    };
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  String get sentimentEmoji {
    if (sentimentScore > 3) return '😊';
    if (sentimentScore > 0) return '🙂';
    if (sentimentScore == 0) return '😐';
    if (sentimentScore > -3) return '😕';
    return '😢';
  }
}