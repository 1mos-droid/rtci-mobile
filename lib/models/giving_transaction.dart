import 'package:cloud_firestore/cloud_firestore.dart';

class GivingTransaction {
  final String id;
  final double amount;
  final String type; // contribution, expense
  final String? category; // Tithe, Offering, etc.
  final DateTime date;
  final String description;
  final String? memberId;
  final String? campus;
  final String status; // pending, completed, failed
  final String? loggedBy;
  final bool isShared;

  GivingTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    this.category,
    this.memberId,
    this.campus,
    this.status = 'completed',
    this.loggedBy,
    this.isShared = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'member_id': memberId,
      'campus': campus,
      'status': status,
      'logged_by': loggedBy,
      'is_shared': isShared,
    };
  }

  factory GivingTransaction.fromMap(Map<String, dynamic> map) {
    return GivingTransaction(
      id: map['id']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] ?? 'contribution',
      category: map['category'],
      date: DateTime.parse(map['date'] ?? map['created_at'] ?? DateTime.now().toIso8601String()),
      description: map['description'] ?? '',
      memberId: map['member_id']?.toString(),
      campus: map['campus']?.toString(),
    );
  }

  factory GivingTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GivingTransaction(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? 'contribution',
      category: data['category'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      memberId: data['member_id'],
      campus: data['campus'],
    );
  }
}