import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/clinic.dart';

final clinicsRepositoryProvider = Provider<ClinicsRepository>((ref) {
  return ClinicsRepository(Supabase.instance.client);
});

class ClinicsRepository {
  ClinicsRepository(this._client);
  final SupabaseClient _client;

  /// Fetch all active clinics. Filtering is done client-side to minimise
  /// round-trips for users on limited data.
  Future<List<Clinic>> getClinics() async {
    final data = await _client
        .from('clinics')
        .select()
        .eq('is_active', true)
        .order('name');
    return (data as List).map((e) => _fromRow(e)).toList();
  }

  Clinic _fromRow(Map<String, dynamic> row) {
    return Clinic(
      id: row['id'] as String,
      name: row['name'] as String,
      type: row['type'] as String?,
      state: row['state'] as String?,
      lga: row['lga'] as String?,
      address: row['address'] as String?,
      phone: row['phone'] as String?,
      services: (row['services'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
      isConfidential: row['is_confidential'] as bool?,
      costDescription: row['cost_description'] as String?,
      openingHours: row['opening_hours'] as String?,
    );
  }
}
