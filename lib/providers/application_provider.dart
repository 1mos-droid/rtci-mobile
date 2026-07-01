import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/models/member_application.dart';

class ApplicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  MemberApplication _application = MemberApplication();
  int _currentStep = 0;
  bool _isLoading = false;

  MemberApplication get application => _application;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;

  String? get pdfExportPath => _application.isSubmitted 
    ? "RTCI-MEMBER-CERT-${_application.fullName.replaceAll(' ', '_')}.pdf" 
    : null;

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void updatePersonalInfo({
    required String fullName,
    required String email,
    required String phone,
    required String birthDate,
    required String address,
  }) {
    _application = _application.copyWith(
      fullName: fullName,
      email: email,
    notifyListeners();
  }

  // Submission Pipeline
  Future<bool> submitApplication() async {
    _isLoading = true;
    notifyListeners();

    // Simulate backend network API delay
    await Future.delayed(const Duration(milliseconds: 2500));

    _application.isSubmitted = true;
    _currentStep = 3; // Ensure at end
    await saveProgress();

    // Simulate exporting membership application as a PDF/Document
    _pdfExportPath = "/exports/rtci_application_${_application.fullName.toLowerCase().replaceAll(' ', '_')}.pdf";

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
