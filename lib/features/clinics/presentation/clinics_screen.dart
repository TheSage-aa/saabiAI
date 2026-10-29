import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// NOTE: `lib/features/profile/presentation/profile_screen.dart` already
/// linked to `/profile/clinics`, but no clinic/resource directory data
/// exists anywhere in this Drive project -- the brief lists "existing
/// clinic and resource data" as one of the things to get from Adebare
/// before this ships for real. This is scaffolding with a handful of
/// clearly-placeholder entries so the route works and the UI pattern is
/// set; swap `placeholderClinics` for the real, maintained directory
/// before launch. Do not treat the entries below as verified.
class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.services,
    required this.youthFriendly,
  });

  final String id;
  final String name;
  final String city;
  final String state;
  final List<String> services;
  final bool youthFriendly;
}

const placeholderClinics = <Clinic>[
  Clinic(
    id: 'placeholder-1',
    name: '[Placeholder] Community Health Center',
    city: 'Lagos',
    state: 'Lagos',
    services: ['HIV testing', 'Family planning', 'Counseling'],
    youthFriendly: true,
  ),
  Clinic(
    id: 'placeholder-2',
    name: '[Placeholder] Youth Friendly Clinic',
    city: 'Ibadan',
    state: 'Oyo',
    services: ['HIV testing', 'STI treatment'],
    youthFriendly: true,
  ),
  Clinic(
    id: 'placeholder-3',
    name: '[Placeholder] Primary Health Centre',
    city: 'Abuja',
    state: 'FCT',
    services: ['General health', 'Mental health referral'],
    youthFriendly: true,
  ),
];

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = placeholderClinics.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.city.toLowerCase().contains(q) ||
          c.state.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        title: const Text('Find Care & Clinics'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(SaabiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(SaabiSpacing.md),
                  decoration: BoxDecoration(
                    color: SaabiColors.disclaimerBg,
                    borderRadius: BorderRadius.circular(SaabiRadius.md),
                  ),
                  child: Text(
                    'This directory is a placeholder while the real, verified clinic list is put together. '
                    'Please confirm details directly with a facility before visiting.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SaabiColors.disclaimerText,
                        ),
                  ),
                ),
                const SizedBox(height: SaabiSpacing.md),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search by city or state...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
                const SizedBox(height: SaabiSpacing.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: SaabiSpacing.sm),
                    itemBuilder: (_, i) {
                      final clinic = results[i];
                      return InkWell(
                        onTap: () => context.go('/profile/clinics/${clinic.id}'),
                        borderRadius: BorderRadius.circular(SaabiRadius.lg),
                        child: Container(
                          padding: const EdgeInsets.all(SaabiSpacing.md),
                          decoration: BoxDecoration(
                            color: SaabiColors.surface,
                            borderRadius: BorderRadius.circular(SaabiRadius.lg),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_hospital_outlined,
                                  color: SaabiColors.primary),
                              const SizedBox(width: SaabiSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(clinic.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w700)),
                                    Text('${clinic.city}, ${clinic.state}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: SaabiColors.textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: SaabiColors.textHint),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
