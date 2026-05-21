class MembershipTier {
  final String id;
  final String name;
  final String price;
  final String? adminFee;
  final String? description;
  final List<String> features;
  final String? color;
  final String? duration;
  final String? actuallyPrice;

  MembershipTier({
    required this.id,
    required this.name,
    required this.price,
    this.adminFee,
    this.description,
    required this.features,
    this.color,
    this.duration,
    this.actuallyPrice,
  });

  factory MembershipTier.fromJson(Map<String, dynamic> json) {
    return MembershipTier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      adminFee: json['adminFee']?.toString(),
      description: json['description'],
      features: List<String>.from(json['features'] ?? []),
      color: json['color'],
      duration: json['duration'],
      actuallyPrice: json['actuallyPrice']?.toString(),
    );
  }
}
