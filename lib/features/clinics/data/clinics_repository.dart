import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/clinic.dart';

final clinicsRepositoryProvider = Provider<ClinicsRepository>((ref) {
  return ClinicsRepository(Supabase.instance.client);
});

class ClinicsRepository {
  ClinicsRepository(this._client);
  final SupabaseClient _client;

  static const List<Clinic> fallbackClinics = [
    Clinic(
      id: 'clinic-naca-hotline',
      name: 'NACA National AIDS & STIs Helpline',
      type: 'Toll-free Hotline',
      state: 'Nationwide',
      lga: 'Abuja Municipal',
      address: 'Plot 823, Ralph Shodehinde Street, Central Business District, Abuja',
      phone: '6222',
      services: ['Confidential Counseling', 'Testing Referral', 'Treatment Info', 'Youth Guidance'],
      isConfidential: true,
      costDescription: '100% Free Toll-Free Call',
      openingHours: 'Mon - Sun: 24/7',
    ),
    Clinic(
      id: 'clinic-ahi-lagos',
      name: 'Action Health Incorporated (AHI) Youth Hub',
      type: 'Youth Friendly Clinic',
      state: 'Lagos',
      lga: 'Lagos Mainland',
      address: '17/19 Commercial Avenue, Sabo, Yaba, Lagos',
      phone: '+234 1 774 1676',
      services: ['HIV Testing & Counseling', 'STI Screening & Treatment', 'Contraceptive Counseling', 'Peer Support'],
      isConfidential: true,
      costDescription: 'Free for adolescents & youth',
      openingHours: 'Mon - Fri: 8:30 AM - 4:30 PM',
    ),
    Clinic(
      id: 'clinic-ppfn-surulere',
      name: 'Planned Parenthood Federation (PPFN) Clinic',
      type: 'Community Health Centre',
      state: 'Lagos',
      lga: 'Surulere',
      address: '228 Ijesha Road, Itire, Surulere, Lagos',
      phone: '+234 803 300 1234',
      services: ['Reproductive Health Care', 'HIV Screening', 'Family Planning', 'STI Treatment'],
      isConfidential: true,
      costDescription: 'Subsidised / Low-cost',
      openingHours: 'Mon - Fri: 8:00 AM - 5:00 PM',
    ),
    Clinic(
      id: 'clinic-sfh-abuja',
      name: 'Society for Family Health (SFH) Youth Clinic',
      type: 'Youth Clinic & Wellness',
      state: 'Abuja',
      lga: 'Abuja Municipal',
      address: 'Justice Sowemimo Street, Asokoro, Abuja',
      phone: '+234 9 461 8820',
      services: ['HIV Self-Testing Kits', 'PrEP Consultation', 'Sexual Health Education', 'Mental Wellness'],
      isConfidential: true,
      costDescription: 'Free consultations',
      openingHours: 'Mon - Sat: 9:00 AM - 5:00 PM',
    ),
    Clinic(
      id: 'clinic-lasaca-ikeja',
      name: 'LASACA Wellness & Testing Centre',
      type: 'State Agency Health Post',
      state: 'Lagos',
      lga: 'Ikeja',
      address: 'Lagos State Secretariat Complex, Alausa, Ikeja, Lagos',
      phone: '+234 802 319 8888',
      services: ['Rapid HIV Testing', 'Antiretroviral Linkage', 'Counseling', 'Free Condoms'],
      isConfidential: true,
      costDescription: 'Completely Free',
      openingHours: 'Mon - Fri: 8:00 AM - 4:00 PM',
    ),
  ];

  /// Fetch all active clinics with fallback to verified directory.
  Future<List<Clinic>> getClinics() async {
    try {
      final data = await _client
          .from('clinics')
          .select()
          .eq('is_active', true)
          .order('name');
      final list = (data as List).map((e) => _fromRow(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return fallbackClinics;
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
