import 'package:cloud_firestore/cloud_firestore.dart';

class Sermon {
  final String id;
  final String title;
  final String speaker;
  final String category; // Sermon, Media
  final String duration;
  final DateTime date;