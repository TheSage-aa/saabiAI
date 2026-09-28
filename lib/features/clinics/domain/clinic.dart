import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinic.freezed.dart';
part 'clinic.g.dart';

@freezed
class Clinic with _$Clinic {
  const factory Clinic({
    required String id,
    required String name,
    String? type,
    String? state,
    String? lga,
    String? address,
    String? phone,
    @Default([]) List<String> services,
    bool? isConfidential,
    String? costDescription,
    String? openingHours,
  }) = _Clinic;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
}
