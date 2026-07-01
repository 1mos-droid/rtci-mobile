import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BroadcastMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String target;
  final String channel;
  final String subject;
  final String body;
  final DateTime createdAt;
  final String category;

  BroadcastMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.target,
    required this.channel,
    required this.subject,
    required this.body,
    required this.createdAt,
    required this.category,
  });

  factory BroadcastMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BroadcastMessage(
      id: doc.id,
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? '',
      target: data['target'] ?? '',
      channel: data['channel'] ?? '',
      subject: data['subject'] ?? '',
      body: data['body'] ?? '',
