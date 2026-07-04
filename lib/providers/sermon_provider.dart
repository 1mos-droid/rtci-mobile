import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/models/sermon.dart';

class SermonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Sermon> _sermons = [];
  bool _isLoading = false;

  List<Sermon> get sermons => _sermons;
  bool get isLoading => _isLoading;

  Future<void> fetchSermons() async {
    _isLoading = true;