import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/clinics_repository.dart';
import '../domain/clinic.dart';

final _clinicDetailProvider =
    FutureProvider.family<Clinic?, String>((ref, clinicId) async {
  final clinics = await ref.watch(clinicsRepositoryProvider).getClinics();
  try {
    return clinics.firstWhere((c) => c.id == clinicId);
  } catch (_) {
    return null;
  }
});

class ClinicDetailScreen extends ConsumerWidget {
  const ClinicDetailScreen({super.key, required this.clinicId});
  final String clinicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicAsync = ref.watch(_clinicDetailProvider(clinicId));

    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Details')),
      body: clinicAsync.when(
        loading: () => const SaabiLoadingIndicator(),
        error: (_, __) =>
            const SaabiErrorBanner(message: 'Could not load clinic details.'),
        data: (clinic) => clinic == null
            ? const SaabiEmptyState(message: 'Clinic not found.')
            : _ClinicDetail(clinic: clinic),
      ),
    );
  }
}

class _ClinicDetail extends StatelessWidget {
  const _ClinicDetail({required this.clinic});
  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SaabiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(clinic.name, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: SaabiSpacing.sm),
          if (clinic.isConfidential == true)
            _Badge(label: '🔒 Confidential', color: SaabiColors.primary),
          if (clinic.type != null)
            _Badge(label: clinic.type!, color: SaabiColors.accent),
          const SizedBox(height: SaabiSpacing.lg),
          _DetailRow(icon: Icons.location_on_outlined, label: 'Location',
              value: [clinic.lga, clinic.state].whereType<String>().join(', '),
              fallback: 'Location not yet verified'),
          _DetailRow(icon: Icons.phone_outlined, label: 'Phone',
              value: clinic.phone, fallback: 'Not yet available'),
          _DetailRow(icon: Icons.attach_money, label: 'Cost',
              value: clinic.costDescription, fallback: 'Not yet verified'),
          _DetailRow(icon: Icons.schedule_outlined, label: 'Hours',
              value: clinic.openingHours, fallback: 'Not yet available'),
          if (clinic.services.isNotEmpty) ...[
            const SizedBox(height: SaabiSpacing.md),
            Text('Services', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: SaabiSpacing.sm),
            Wrap(
              spacing: SaabiSpacing.sm,
              runSpacing: SaabiSpacing.sm,
              children: clinic.services
                  .map((s) => _Badge(label: s, color: SaabiColors.info))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.fallback,
  });
  final IconData icon;
  final String label;
  final String? value;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: SaabiColors.textSecondary),
          const SizedBox(width: SaabiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  value ?? fallback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: value == null ? SaabiColors.textHint : null,
                        fontStyle:
                            value == null ? FontStyle.italic : FontStyle.normal,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SaabiRadius.full),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
