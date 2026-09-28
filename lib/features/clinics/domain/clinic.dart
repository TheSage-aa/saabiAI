class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    this.type,
    this.state,
    this.lga,
    this.address,
    this.phone,
    this.services = const [],
    this.isConfidential,
    this.costDescription,
    this.openingHours,
  });

  final String id;
  final String name;
  final String? type;
  final String? state;
  final String? lga;
  final String? address;
  final String? phone;
  final List<String> services;
  final bool? isConfidential;
  final String? costDescription;
  final String? openingHours;

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      state: json['state'] as String?,
      lga: json['lga'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isConfidential: json['is_confidential'] as bool?,
      costDescription: json['cost_description'] as String?,
      openingHours: json['opening_hours'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'state': state,
      'lga': lga,
      'address': address,
      'phone': phone,
      'services': services,
      'is_confidential': isConfidential,
      'cost_description': costDescription,
      'opening_hours': openingHours,
    };
  }
}
