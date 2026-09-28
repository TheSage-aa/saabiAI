import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/clinics_repository.dart';
import '../domain/clinic.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedStateProvider = StateProvider<String?>((ref) => null);

final _clinicsProvider = FutureProvider<List<Clinic>>((ref) {
  return ref.watch(clinicsRepositoryProvider).getClinics();
});

class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(_clinicsProvider);
    final query = ref.watch(_searchQueryProvider);
    final selectedState = ref.watch(_selectedStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Find Care')),
      body: clinicsAsync.when(
        loading: () => const SaabiLoadingIndicator(),
        error: (e, _) => SaabiErrorBanner(
          message: 'Could not load clinics. Check your connection.',
          onRetry: () => ref.invalidate(_clinicsProvider),
        ),
        data: (clinics) {
          // Client-side filtering — single fetch saves data
          final states = clinics
              .where((c) => c.state != null)
              .map((c) => c.state!)
              .toSet()
              .toList()
            ..sort();

          final filtered = clinics.where((c) {
            final matchesQuery = query.isEmpty ||
                c.name.toLowerCase().contains(query.toLowerCase()) ||
                (c.state?.toLowerCase().contains(query.toLowerCase()) ?? false);
            final matchesState =
                selectedState == null || c.state == selectedState;
            return matchesQuery && matchesState;
          }).toList();

          return Column(
            children: [
              _SearchBar(
                onChanged: (v) =>
                    ref.read(_searchQueryProvider.notifier).state = v,
              ),
              _StateFilterChips(
                states: states,
                selected: selectedState,
                onSelect: (s) =>
                    ref.read(_selectedStateProvider.notifier).state = s,
              ),
              Expanded(
                child: filtered.isEmpty
                    ? SaabiEmptyState(
                        icon: Icons.location_off_outlined,
                        message: 'No clinics found.\nTry a different search.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(SaabiSpacing.md),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: SaabiSpacing.sm),
                        itemBuilder: (_, i) => _ClinicCard(clinic: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          SaabiSpacing.md, SaabiSpacing.md, SaabiSpacing.md, 0),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search clinics or state...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

class _StateFilterChips extends StatelessWidget {
  const _StateFilterChips({
    required this.states,
    required this.selected,
    required this.onSelect,
  });
  final List<String> states;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: SaabiSpacing.md, vertical: SaabiSpacing.xs),
        children: [
          FilterChip(
            label: const Text('All states'),
            selected: selected == null,
            onSelected: (_) => onSelect(null),
          ),
          ...states.map((s) => Padding(
                padding: const EdgeInsets.only(left: SaabiSpacing.sm),
                child: FilterChip(
                  label: Text(s),
                  selected: selected == s,
                  onSelected: (_) => onSelect(selected == s ? null : s),
                ),
              )),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({required this.clinic});
  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/clinics/${clinic.id}'),
        borderRadius: BorderRadius.circular(SaabiRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(SaabiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(clinic.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (clinic.isConfidential == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SaabiColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SaabiRadius.full),
                      ),
                      child: const Text('Confidential',
                          style: TextStyle(
                              fontSize: 11,
                              color: SaabiColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: SaabiSpacing.xs),
              if (clinic.state != null || clinic.type != null)
                Text(
                  [clinic.type, clinic.state].whereType<String>().join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (clinic.costDescription != null) ...[
                const SizedBox(height: SaabiSpacing.xs),
                Text('Cost: ${clinic.costDescription}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SaabiColors.success,
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
