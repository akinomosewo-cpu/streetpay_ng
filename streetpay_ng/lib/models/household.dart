import 'package:equatable/equatable.dart';

/// The category of resident a household belongs to. Landlords and tenants
/// are charged different monthly security levies per the street's rules.
enum ResidentType { landlord, tenant }

extension ResidentTypeX on ResidentType {
  String get label => this == ResidentType.landlord ? 'Landlord' : 'Tenant';

  static ResidentType fromName(String name) =>
      ResidentType.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ResidentType.tenant,
      );
}

/// A registered household on the street that owes a monthly security levy.
class Household extends Equatable {
  final String id;
  final String occupantName;
  final String houseNumber;
  final ResidentType type;
  final String phone;

  /// Monthly due in naira. Defaults are applied at creation time
  /// (₦2,500 landlord / ₦500 tenant) but can be overridden per household.
  final int monthlyDue;
  final DateTime createdAt;

  const Household({
    required this.id,
    required this.occupantName,
    required this.houseNumber,
    required this.type,
    required this.monthlyDue,
    this.phone = '',
    required this.createdAt,
  });

  static const int defaultLandlordDue = 2500;
  static const int defaultTenantDue = 500;

  static int defaultDueFor(ResidentType type) =>
      type == ResidentType.landlord ? defaultLandlordDue : defaultTenantDue;

  Household copyWith({
    String? occupantName,
    String? houseNumber,
    ResidentType? type,
    String? phone,
    int? monthlyDue,
  }) {
    return Household(
      id: id,
      occupantName: occupantName ?? this.occupantName,
      houseNumber: houseNumber ?? this.houseNumber,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      monthlyDue: monthlyDue ?? this.monthlyDue,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'occupantName': occupantName,
        'houseNumber': houseNumber,
        'type': type.name,
        'phone': phone,
        'monthlyDue': monthlyDue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Household.fromMap(Map<dynamic, dynamic> map) => Household(
        id: map['id'] as String,
        occupantName: map['occupantName'] as String? ?? '',
        houseNumber: map['houseNumber'] as String? ?? '',
        type: ResidentTypeX.fromName(map['type'] as String? ?? 'tenant'),
        phone: map['phone'] as String? ?? '',
        monthlyDue: (map['monthlyDue'] as num?)?.toInt() ??
            defaultDueFor(ResidentTypeX.fromName(map['type'] as String? ?? 'tenant')),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, occupantName, houseNumber, type, phone, monthlyDue, createdAt];
}
