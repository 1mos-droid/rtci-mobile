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
      phone: phone,
      birthDate: birthDate,
      address: address,
    );
    notifyListeners();
  }

  void updateSpiritualJourney({
    String? conversionDate,
    String? previousChurch,
    bool? isWaterBaptized,
    bool? isHolyGhostBaptized,
  }) {
    _application = _application.copyWith(
      conversionDate: conversionDate,
      previousChurch: previousChurch,
      isWaterBaptized: isWaterBaptized,
      isHolyGhostBaptized: isHolyGhostBaptized,
    );
    notifyListeners();
  }

  void toggleMinistry(String ministry) {
    final list = List<String>.from(_application.selectedMinistries);
    if (list.contains(ministry)) {
      list.remove(ministry);
    } else {
      list.add(ministry);
    }
    _application = _application.copyWith(selectedMinistries: list);
    notifyListeners();
  }

  void updateTalents(String talents) {
    _application = _application.copyWith(talentsAndSkills: talents);
    notifyListeners();
  }

  void updateCovenantAgreement(bool agreed) {
    _application = _application.copyWith(covenantsAgreed: agreed);
    notifyListeners();
  }

  void updateSignature(List<Offset?> points) {
    // Convert Offset list to a format suitable for MemberApplication (List<String>)
    final stringPoints = points.map((p) => p == null ? "null" : "${p.dx},${p.dy}").toList();
    _application = _application.copyWith(signaturePoints: stringPoints);
    notifyListeners();
  }

  Future<bool> submitApplication() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      
      await _firestore.collection('applications').add({
        'user_id': user?.uid,
        'full_name': _application.fullName,
        'email': _application.email,
        'phone': _application.phone,
        'birth_date': _application.birthDate,
        'address': _application.address,
        'conversion_date': _application.conversionDate,
        'previous_church': _application.previousChurch,
        'is_water_baptized': _application.isWaterBaptized,
        'is_holy_ghost_baptized': _application.isHolyGhostBaptized,
        'selected_ministries': _application.selectedMinistries,
        'talents_and_skills': _application.talentsAndSkills,
        'covenants_agreed': _application.covenantsAgreed,
        'signature_points': _application.signaturePoints,
        'created_at': FieldValue.serverTimestamp(),
      });

      _application = _application.copyWith(isSubmitted: true);

    // Simulate exporting membership application as a PDF/Document
    _pdfExportPath = "/exports/rtci_application_${_application.fullName.toLowerCase().replaceAll(' ', '_')}.pdf";

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
