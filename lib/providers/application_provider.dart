import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/models/member_application.dart';

class ApplicationProvider extends ChangeNotifier {
  MemberApplication _application = MemberApplication();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _pdfExportPath;

  MemberApplication get application => _application;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get pdfExportPath => _pdfExportPath;

  ApplicationProvider() {
    _loadApplicationProgress();
  }

  // Load progress from local disk
  Future<void> _loadApplicationProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_member_application');
    _currentStep = prefs.getInt('member_application_step') ?? 0;
    if (data != null) {
      try {
        _application = MemberApplication.fromJson(data);
      } catch (e) {
        _application = MemberApplication();
      }
    }
    notifyListeners();
  }

  // Save current progress to local disk
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_member_application', _application.toJson());
    await prefs.setInt('member_application_step', _currentStep);
  }

  // Update Personal Info
  void updatePersonalInfo({
    String? fullName,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
    String? address,
  }) {
    _application.fullName = fullName ?? _application.fullName;
    _application.email = email ?? _application.email;
    _application.phone = phone ?? _application.phone;
    _application.birthDate = birthDate ?? _application.birthDate;
    _application.gender = gender ?? _application.gender;
    _application.address = address ?? _application.address;
    
    // Auto calculate step progress
    _calculateProgress();
    saveProgress();
    notifyListeners();
  }

  // Update Spiritual Journey
  void updateSpiritualJourney({
    String? conversionDate,
    bool? isWaterBaptized,
    bool? isHolyGhostBaptized,
    String? previousChurch,
  }) {
    _application.conversionDate = conversionDate ?? _application.conversionDate;
    _application.isWaterBaptized = isWaterBaptized ?? _application.isWaterBaptized;
    _application.isHolyGhostBaptized = isHolyGhostBaptized ?? _application.isHolyGhostBaptized;
    _application.previousChurch = previousChurch ?? _application.previousChurch;
    
    _calculateProgress();
    saveProgress();
    notifyListeners();
  }

  // Update Ministries
  void toggleMinistry(String ministry) {
    if (_application.selectedMinistries.contains(ministry)) {
      _application.selectedMinistries.remove(ministry);
    } else {
      _application.selectedMinistries.add(ministry);
    }
    _calculateProgress();
    saveProgress();
    notifyListeners();
  }

  void updateTalents(String talents) {
    _application.talentsAndSkills = talents;
    _calculateProgress();
    saveProgress();
    notifyListeners();
  }

  // Update Verification
  void updateCovenantAgreement(bool agreed) {
    _application.covenantsAgreed = agreed;
    _calculateProgress();
    saveProgress();
    notifyListeners();
  }

  void updateSignature(List<Offset?> points) {
    // Save signature coordinates as serialized string list
    _application.signaturePoints = points.map((p) => p != null ? "${p.dx},${p.dy}" : "null").toList();
    _calculateProgress();
    saveProgress();
    notifyListeners();
  }

  void _calculateProgress() {
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
