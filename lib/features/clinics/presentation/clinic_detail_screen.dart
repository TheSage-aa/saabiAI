import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'clinics_screen.dart';

class ClinicDetailScreen extends StatelessWidget {
  const ClinicDetailScreen({super.key, required this.clinicId});
  final String clinicId;

  @override
  Widget build(BuildContext context) {
    Clinic? clinic;
    for (final c in placeholderClinics) {
      if (c.id == clinicId) {
        clinic = c;
        break;
      }
    }

    if (clinic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text("We couldn't find that clinic.")),
      );
    }

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        title: Text(clinic.name),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(SaabiSpacing.lg),
            children: [
              if (clinic.youthFriendly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SaabiColors.greenLight,
                    borderRadius: BorderRadius.circular(SaabiRadius.full),
                  ),
                  child: const Text(
                    'Youth Friendly',
                    style: TextStyle(
                        color: SaabiColors.green, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              const SizedBox(height: SaabiSpacing.md),
              Text('${clinic.city}, ${clinic.state}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: SaabiSpacing.lg),
              Text('Services', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: SaabiSpacing.sm),
              Wrap(
                spacing: SaabiSpacing.sm,
                runSpacing: SaabiSpacing.sm,
                children: clinic.services
                    .map((s) => Chip(label: Text(s), backgroundColor: SaabiColors.primaryLight))
                    .toList(),
              ),
              const SizedBox(height: SaabiSpacing.xl),
              Container(
                padding: const EdgeInsets.all(SaabiSpacing.md),
                decoration: BoxDecoration(
                  color: SaabiColors.disclaimerBg,
                  borderRadius: BorderRadius.circular(SaabiRadius.md),
                ),
                child: Text(
                  'This is placeholder data. Contact details, hours and exact services need to '
                  'come from a verified clinic directory before this is shown to real users.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: SaabiColors.disclaimerText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
