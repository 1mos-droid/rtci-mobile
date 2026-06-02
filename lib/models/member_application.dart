import 'dart:convert';

class MemberApplication {
  // Step 1: Personal Info
  String fullName;
  String email;
  String phone;
  String birthDate;
  String gender;
  String address;

  // Step 2: Spiritual Journey
  String conversionDate;
  bool isWaterBaptized;
  bool isHolyGhostBaptized;
  String previousChurch;

  // Step 3: Ministries & Area of Interests
  List<String> selectedMinistries;
  String talentsAndSkills;

  // Step 4: Verification & Signature
  bool covenantsAgreed;
  String signaturePath; // Local path or representation
  List<String> signaturePoints; // JSON serialized signature coordinate points

  // Status Management
  bool isSubmitted;
  double progress;

  MemberApplication({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.birthDate = '',
    this.gender = 'Male',
    this.address = '',
    this.conversionDate = '',
    this.isWaterBaptized = false,
    this.isHolyGhostBaptized = false,
    this.previousChurch = '',
    List<String>? selectedMinistries,
    this.talentsAndSkills = '',
    this.covenantsAgreed = false,
    this.signaturePath = '',
    List<String>? signaturePoints,
    this.isSubmitted = false,
    this.progress = 0.0,
  })  : selectedMinistries = selectedMinistries ?? [],
        signaturePoints = signaturePoints ?? [];

  // Clone/Copy implementation
  MemberApplication copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
    String? address,
    String? conversionDate,
    bool? isWaterBaptized,
    bool? isHolyGhostBaptized,
    String? previousChurch,
    List<String>? selectedMinistries,
    String? talentsAndSkills,
    bool? covenantsAgreed,
    String? signaturePath,
    List<String>? signaturePoints,
    bool? isSubmitted,
    double? progress,
  }) {
    return MemberApplication(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      conversionDate: conversionDate ?? this.conversionDate,
      isWaterBaptized: isWaterBaptized ?? this.isWaterBaptized,
      isHolyGhostBaptized: isHolyGhostBaptized ?? this.isHolyGhostBaptized,
      previousChurch: previousChurch ?? this.previousChurch,
      selectedMinistries: selectedMinistries ?? List.from(this.selectedMinistries),
      talentsAndSkills: talentsAndSkills ?? this.talentsAndSkills,
      covenantsAgreed: covenantsAgreed ?? this.covenantsAgreed,
      signaturePath: signaturePath ?? this.signaturePath,
      signaturePoints: signaturePoints ?? List.from(this.signaturePoints),
      isSubmitted: isSubmitted ?? this.isSubmitted,
      progress: progress ?? this.progress,
    );
  }

  // Convert to Map for Shared Preferences / API
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'address': address,
      'conversionDate': conversionDate,
      'isWaterBaptized': isWaterBaptized,
      'isHolyGhostBaptized': isHolyGhostBaptized,
      'previousChurch': previousChurch,
      'selectedMinistries': selectedMinistries,
      'talentsAndSkills': talentsAndSkills,
      'covenantsAgreed': covenantsAgreed,
      'signaturePath': signaturePath,
      'signaturePoints': signaturePoints,
      'isSubmitted': isSubmitted,
      'progress': progress,
    };
  }

  // Factory constructor from Map
  factory MemberApplication.fromMap(Map<String, dynamic> map) {
    return MemberApplication(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      birthDate: map['birthDate'] ?? '',
      gender: map['gender'] ?? 'Male',
      address: map['address'] ?? '',
      conversionDate: map['conversionDate'] ?? '',
      isWaterBaptized: map['isWaterBaptized'] ?? false,
      isHolyGhostBaptized: map['isHolyGhostBaptized'] ?? false,
      previousChurch: map['previousChurch'] ?? '',
      selectedMinistries: List<String>.from(map['selectedMinistries'] ?? []),
      talentsAndSkills: map['talentsAndSkills'] ?? '',
      covenantsAgreed: map['covenantsAgreed'] ?? false,
      signaturePath: map['signaturePath'] ?? '',
      signaturePoints: List<String>.from(map['signaturePoints'] ?? []),
      isSubmitted: map['isSubmitted'] ?? false,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert to JSON String
  String toJson() => json.encode(toMap());

  // Create from JSON String
  factory MemberApplication.fromJson(String source) =>
      MemberApplication.fromMap(json.decode(source));
}
