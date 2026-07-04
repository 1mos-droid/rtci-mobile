import 'package:cloud_firestore/cloud_firestore.dart';

class Sermon {
  final String id;
  final String title;
  final String speaker;
  final String category; // Sermon, Media
  final String duration;
  final DateTime date;
  final String imageUrl;
  final String tag; // Featured, New, Trending, etc.
  final String? audioUrl;
  final String? videoUrl;
  final String? loggedBy;

  Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.category,
    required this.duration,
    required this.date,
    required this.imageUrl,
    required this.tag,
    this.audioUrl,
    this.videoUrl,
    this.loggedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'speaker': speaker,
      'category': category,
      'duration': duration,
      'date': FieldValue.serverTimestamp(),
      'image_url': imageUrl,
      'tag': tag,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'logged_by': loggedBy,