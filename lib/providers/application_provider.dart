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

    double totalWeight = 0.0;
    if (_application.fullName.isNotEmpty) totalWeight += 0.25;
    if (_application.email.isNotEmpty) totalWeight += 0.25;
    if (_application.conversionDate.isNotEmpty) totalWeight += 0.25;
    if (_application.covenantsAgreed && _application.signaturePoints.isNotEmpty) totalWeight += 0.25;
    _application.progress = totalWeight;
  }

  // Navigate wizard steps
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      saveProgress();
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      saveProgress();
      notifyListeners();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      saveProgress();
      notifyListeners();
    }
  }

  // Clear Form
  Future<void> resetForm() async {
    _application = MemberApplication();
    _currentStep = 0;
    _pdfExportPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_member_application');
    await prefs.remove('member_application_step');
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
