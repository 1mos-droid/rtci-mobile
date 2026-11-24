import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
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

  @override
  void initState() {
    super.initState();
    final provider = ref.read(applicationProvider);
    final app = provider.application;

    _nameController.text = app.fullName;
    _emailController.text = app.email;
    _phoneController.text = app.phone;
    _birthDateController.text = app.birthDate;
    _addressController.text = app.address;
    _conversionDateController.text = app.conversionDate;
    _prevChurchController.text = app.previousChurch;
    _talentsController.text = app.talentsAndSkills;
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
    if (provider.isLoading) return;
    if (provider.application.covenantsAgreed) {
      final success = await provider.submitApplication();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Application submitted successfully to church archives!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We couldn’t submit your application. Your information is still here. Please try again.',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please agree to the covenants before submitting."),
          backgroundColor: ObsidianTheme.primaryCrimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(applicationProvider);
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
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            onPressed: () {
              _saveCurrentStepData(step, provider);
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Covenant Membership",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
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
              final stepTitles = [
                "Identity",
                "Spiritual",
                "Service",
                "Covenant",
              ];
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
                          : (isCurrent
                                ? ObsidianTheme.primaryCrimson
                                : Theme.of(context).colorScheme.surface),
                      border: Border.all(
                        color: isCurrent || isCompleted
                            ? ObsidianTheme.secondaryGold
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 12,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            )
                          : Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepTitles[index],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrent || isCompleted
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1.0,
            color: Theme.of(context).colorScheme.outlineVariant,
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
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Full Legal Name",
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? "Name is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Contact Email",
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (val) => val == null || !val.contains('@')
              ? "Valid email is required"
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Mobile Connection",
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? "Phone number is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _birthDateController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Date of Birth",
            prefixIcon: Icon(Icons.cake_outlined),
            hintText: "YYYY-MM-DD",
          ),
          validator: (val) =>
              val == null || val.isEmpty ? "Birth date is required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Residential Address",
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? "Address is required" : null,
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
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Conversion Date",
            prefixIcon: Icon(Icons.favorite_border),
            hintText: "YYYY-MM-DD (Approximate OK)",
          ),
          validator: (val) =>
              val == null || val.isEmpty ? "Conversion date is required" : null,
        ),
        const SizedBox(height: 20),

        SwitchListTile(
          title: Text(
            "Fully Baptized by Water?",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: const Text("Full immersion baptism by water."),
          value: app.isWaterBaptized,
          activeThumbColor: ObsidianTheme.secondaryGold,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) {
            provider.updateSpiritualJourney(isWaterBaptized: val);
          },
        ),
        Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          height: 24,
        ),

        SwitchListTile(
          title: Text(
            "Baptized with the Holy Ghost?",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: const Text("Baptism of the Holy Spirit with gifts."),
          value: app.isHolyGhostBaptized,
          activeThumbColor: ObsidianTheme.secondaryGold,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) {
            provider.updateSpiritualJourney(isHolyGhostBaptized: val);
          },
        ),
        Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          height: 24,
        ),

        TextFormField(
          controller: _prevChurchController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
      "Welfare Ministry",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Service & Talents",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: ObsidianTheme.secondaryGold),
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
              selectedColor: ObsidianTheme.secondaryGold.withValues(alpha: 0.2),
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? ObsidianTheme.secondaryGold
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: 0.8,
                ),
              ),
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: isSelected
                    ? ObsidianTheme.secondaryGold
                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Review our local church covenants. Personal agreement is required.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),

        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1.0,
            ),
          ),
          child: SingleChildScrollView(
            child: Text(
              "Foundational Covenants:\n\n"
              "1. WE BELIEVE in the Holy Scripture as the complete inspiration of the Holy Spirit.\n\n"
              "2. WE COVENANT to walk together in Christian love, striving for the advancement of this church.\n\n"
              "3. WE SOLMENLY COMMIT to support the ministry of the church through regular attendance and tithing.\n\n"
              "4. WE AGREE to submit to the pastoral leadership appointed to guide this congregation.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        CheckboxListTile(
          title: Text(
            "I solemnly pledge and agree to the covenants.",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          value: app.covenantsAgreed,
          activeColor: ObsidianTheme.secondaryGold,
          checkColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) {
            provider.updateCovenantAgreement(val ?? false);
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(int activeStep, ApplicationProvider provider) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("SUBMIT COVENANTS"),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(ApplicationProvider provider) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Application received')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Thank you, ${provider.application.fullName}.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your membership application has been submitted for review. The church will contact you about the next steps.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  if (provider.submissionReference != null) ...[
                    SelectableText(
                      'Reference: ${provider.submissionReference}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy submission reference'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await Clipboard.setData(
                            ClipboardData(text: provider.submissionReference!),
                          );
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Submission reference copied.'),
                              ),
                            );
                          }
                        } catch (_) {
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'The reference could not be copied. Please select it above.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
