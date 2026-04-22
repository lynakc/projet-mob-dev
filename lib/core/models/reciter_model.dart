class Reciter {
  final int id;
  final String nameAr;
  final String nameEn;

  Reciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: int.parse(json['reciter_id']),
      nameAr: json['reciter_name'],
      nameEn: json['reciter_short_name'],
    );
  }
}