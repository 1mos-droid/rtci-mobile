import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRequest {
  final String id;
  final String request;
  final String status; // pending, praying, answered
  final bool isPrivate;
  final String? memberId;
  final String? memberName;
  final String? campus;
  final DateTime createdAt;
  final int intercessionCount;

  PrayerRequest({
    required this.id,
    required this.request,
    required this.status,
    required this.isPrivate,
    required this.createdAt,
    this.memberId,
    this.memberName,
    this.campus,
    this.intercessionCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'request': request,
      'status': status,
      'is_private': isPrivate,
      'member_id': memberId,
      'campus': campus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PrayerRequest.fromMap(Map<String, dynamic> map) {
    return PrayerRequest(
      id: map['id']?.toString() ?? '',
      request: map['request'] ?? '',
      status: map['status'] ?? 'pending',
      isPrivate: map['is_private'] ?? false,
      memberId: map['member_id']?.toString(),
      memberName: map['members'] != null ? map['members']['name'] : null,
      campus: map['campus']?.toString(),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory PrayerRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrayerRequest(
      id: doc.id,
      request: data['content'] ?? data['request'] ?? '',
      status: data['status'] ?? 'pending',
      isPrivate: data['is_anonymous'] ?? data['is_private'] ?? false,
      memberId: data['user_id'] ?? data['member_id'],
      memberName: data['user_name'] ?? data['member_name'],
      campus: data['campus'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      intercessionCount: data['intercession_count'] ?? 0,
    );
  }

  PrayerRequest copyWith({
    String? id,
    String? request,
    String? status,
    bool? isPrivate,
    String? memberId,
    String? memberName,
    String? campus,
    DateTime? createdAt,
    int? intercessionCount,
  }) {
    return PrayerRequest(
      id: id ?? this.id,
      request: request ?? this.request,
      status: status ?? this.status,
      isPrivate: isPrivate ?? this.isPrivate,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      campus: campus ?? this.campus,
      createdAt: createdAt ?? this.createdAt,
      intercessionCount: intercessionCount ?? this.intercessionCount,
    );
  }
}
