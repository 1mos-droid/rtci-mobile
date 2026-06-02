import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/widgets/digital_signature_pad.dart';
import 'package:rtc_mobile/providers/application_provider.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Step 2 Controllers
  final _conversionDateController = TextEditingController();
  final _prevChurchController = TextEditingController();
  
  // Step 3 Controllers
  final _talentsController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      final app = provider.application;
      
      _nameController.text = app.fullName;
      _emailController.text = app.email;
      _phoneController.text = app.phone;
      _birthDateController.text = app.birthDate;
      _addressController.text = app.address;
      _conversionDateController.text = app.conversionDate;
      _prevChurchController.text = app.previousChurch;
      _talentsController.text = app.talentsAndSkills;
      
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _conversionDateController.dispose();
    _prevChurchController.dispose();
    _talentsController.dispose();
    super.dispose();
  }

  void _saveCurrentStepData(int step, ApplicationProvider provider) {
    if (step == 0) {
      provider.updatePersonalInfo(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        birthDate: _birthDateController.text,
        address: _addressController.text,
      );
    } else if (step == 1) {
      provider.updateSpiritualJourney(
        conversionDate: _conversionDateController.text,
        previousChurch: _prevChurchController.text,
      );
    } else if (step == 2) {
      provider.updateTalents(_talentsController.text);
    }
  }

  Future<void> _handleSubmit(ApplicationProvider provider) async {
    if (provider.application.covenantsAgreed && provider.application.signaturePoints.isNotEmpty) {
      final success = await provider.submitApplication();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Application submitted successfully to church archives!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please agree to the covenants and sign the form before submitting."),
          backgroundColor: ObsidianTheme.primaryCrimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApplicationProvider>(context);
    final app = provider.application;
    final step = provider.currentStep;

    if (app.isSubmitted) {
      return _buildSuccessScreen(provider);
    }

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
            onPressed: () {
              _saveCurrentStepData(step, provider);
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Covenant Membership",
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clean Step progress tracker
              _buildProgressBar(step),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  child: Form(
                    key: _formKey,
                    child: GlassCard(
                      padding: const EdgeInsets.all(22),
                      borderType: GlassBorderType.gold,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (step == 0) _buildPersonalInfoStep(provider),
                          if (step == 1) _buildSpiritualJourneyStep(provider),
                          if (step == 2) _buildMinistriesStep(provider),
                          if (step == 3) _buildVerificationStep(provider),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              _buildBottomNavBar(step, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int activeStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final stepTitles = ["Identity", "Spiritual", "Service", "Covenant"];
              final isCurrent = index == activeStep;
              final isCompleted = index < activeStep;
              return Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? ObsidianTheme.secondaryGold
                          : (isCurrent ? ObsidianTheme.primaryCrimson : ObsidianTheme.surfaceDark),
                      border: Border.all(
                        color: isCurrent || isCompleted ? ObsidianTheme.secondaryGold : ObsidianTheme.borderHairline,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 12, color: ObsidianTheme.backgroundDark)
                          : Text(
                              "${index + 1}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? Colors.white : ObsidianTheme.textMuted,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepTitles[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent || isCompleted ? ObsidianTheme.textVibrant : ObsidianTheme.textMuted,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1.0,
            color: ObsidianTheme.borderHairline,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep(ApplicationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Personal Identification",
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ObsidianTheme.textVibrant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Enter your legal name and contact details to register your local church records profile.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Full Legal Name",
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Contact Email",
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (val) => val == null || !val.contains('@') ? "Valid email is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Mobile Connection",
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (val) => val == null || val.isEmpty ? "Phone number is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _birthDateController,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Date of Birth",
            prefixIcon: Icon(Icons.cake_outlined),
            hintText: "YYYY-MM-DD",
          ),
          validator: (val) => val == null || val.isEmpty ? "Birth date is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Residential Address",
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (val) => val == null || val.isEmpty ? "Address is required" : null,
        ),
      ],
    );
  }

  Widget _buildSpiritualJourneyStep(ApplicationProvider provider) {
    final app = provider.application;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Spiritual Journey",
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ObsidianTheme.textVibrant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Detail your spiritual conversion milestones to help us allocate fellowship groups.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _conversionDateController,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Conversion Date",
            prefixIcon: Icon(Icons.favorite_border),
            hintText: "YYYY-MM-DD (Approximate OK)",
          ),
          validator: (val) => val == null || val.isEmpty ? "Conversion date is required" : null,
        ),
        const SizedBox(height: 20),
        
        SwitchListTile(
          title: Text(
            "Fully Baptized by Water?",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: ObsidianTheme.textVibrant),
          ),
          subtitle: const Text("Full immersion baptism by water."),
          value: app.isWaterBaptized,
          activeColor: ObsidianTheme.secondaryGold,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) {
            provider.updateSpiritualJourney(isWaterBaptized: val);
          },
        ),
        const Divider(color: ObsidianTheme.borderHairline, height: 24),

        SwitchListTile(
          title: Text(
            "Baptized with the Holy Ghost?",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: ObsidianTheme.textVibrant),
          ),
          subtitle: const Text("Baptism of the Holy Spirit with gifts."),
          value: app.isHolyGhostBaptized,
          activeColor: ObsidianTheme.secondaryGold,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) {
            provider.updateSpiritualJourney(isHolyGhostBaptized: val);
          },
        ),
        const Divider(color: ObsidianTheme.borderHairline, height: 24),

        TextFormField(
          controller: _prevChurchController,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Previous Ministry Affiliation",
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildMinistriesStep(ApplicationProvider provider) {
    final app = provider.application;
    final ministries = [
      "Choir & Praise",
      "Ushering & Protocol",
      "Technical & Media",
      "Children Ministry",
      "Intercession Core",
      "Evangelism Hub",
      "Welfare Ministry"
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Service & Talents",
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ObsidianTheme.textVibrant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Select the departments you are inspired to join, and detail any vocational skills.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        
        Text(
          "DEPARTMENTS OF INTEREST",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ObsidianTheme.secondaryGold),
        ),
        const SizedBox(height: 10),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ministries.map((m) {
            final isSelected = app.selectedMinistries.contains(m);
            return FilterChip(
              showCheckmark: false,
              label: Text(m),
              selected: isSelected,
              selectedColor: ObsidianTheme.secondaryGold.withOpacity(0.2),
              backgroundColor: ObsidianTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? ObsidianTheme.secondaryGold : ObsidianTheme.borderHairline,
                  width: 0.8,
                ),
              ),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isSelected ? ObsidianTheme.secondaryGold : ObsidianTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) {
                provider.toggleMinistry(m);
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        TextFormField(
          controller: _talentsController,
          maxLines: 3,
          style: const TextStyle(color: ObsidianTheme.textVibrant),
          decoration: const InputDecoration(
            labelText: "Talents, Skills, & Artistic Gifts",
            hintText: "E.g., instrument playing, graphic design...",
          ),
          onChanged: (val) {
            provider.updateTalents(val);
          },
        ),
      ],
    );
  }

  Widget _buildVerificationStep(ApplicationProvider provider) {
    final app = provider.application;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Covenant Solemnization",
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ObsidianTheme.textVibrant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Review our local church covenants. Personal agreement and signature are required.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ObsidianTheme.borderHairline, width: 1.0),
          ),
          child: SingleChildScrollView(
            child: Text(
              "Foundational Covenants:\n\n"
              "1. WE BELIEVE in the Holy Scripture as the complete inspiration of the Holy Spirit.\n\n"
              "2. WE COVENANT to walk together in Christian love, striving for the advancement of this church.\n\n"
              "3. WE SOLMENLY COMMIT to support the ministry of the church through regular attendance and tithing.\n\n"
              "4. WE AGREE to submit to the pastoral leadership appointed to guide this congregation.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: ObsidianTheme.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        CheckboxListTile(
          title: Text(
            "I solemnly pledge and agree to the covenants.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          value: app.covenantsAgreed,
          activeColor: ObsidianTheme.secondaryGold,
          checkColor: ObsidianTheme.backgroundDark,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) {
            provider.updateCovenantAgreement(val ?? false);
          },
        ),
        
        const Divider(color: ObsidianTheme.borderHairline, height: 24),
        
        DigitalSignaturePad(
          onSignatureChanged: (points) {
            provider.updateSignature(points);
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(int activeStep, ApplicationProvider provider) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceDark.withOpacity(0.8),
        border: const Border(top: BorderSide(color: ObsidianTheme.borderHairline, width: 0.5)),
      ),
      child: Row(
        children: [
          if (activeStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _saveCurrentStepData(activeStep, provider);
                  provider.prevStep();
                },
                child: const Text("BACK"),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: activeStep < 3
                ? ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveCurrentStepData(activeStep, provider);
                        provider.nextStep();
                      }
                    },
                    child: const Text("NEXT STEP"),
                  )
                : ElevatedButton(
                    onPressed: () => _handleSubmit(provider),
                    child: provider.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("SUBMIT COVENANTS"),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(ApplicationProvider provider) {
    final app = provider.application;
    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ObsidianTheme.backgroundDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle_outline, size: 42, color: Colors.greenAccent),
                    ),
                  ),
                )
                .animate()
                .scaleXY(begin: 0.85, end: 1.0, duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  "Covenant Sealed",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ObsidianTheme.textVibrant,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "Your membership application has been successfully filed in local ministry records.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                const SizedBox(height: 35),
                
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderType: GlassBorderType.gold,
                  child: Column(
                    children: [
                      Text(
                        "Redeemed Transformation Chapel".toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: ObsidianTheme.secondaryGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Covenant Membership Verification",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      const Divider(color: ObsidianTheme.borderHairline, height: 24),
                      Text(
                        app.fullName.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: ObsidianTheme.textVibrant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Member Code: #RTCI-26-${app.fullName.hashCode.abs() % 10000}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10.5),
                      ),
                      const Divider(color: ObsidianTheme.borderHairline, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SEAL DATE",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 8.5),
                              ),
                              Text("2026-05-31", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "STATUS",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 8.5),
                              ),
                              Text("CERTIFIED", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("PDF saved as: ${provider.pdfExportPath}"),
                        backgroundColor: ObsidianTheme.secondaryGold,
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text("Download PDF Receipt"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.primaryCrimson,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ENTER DASHBOARD"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
