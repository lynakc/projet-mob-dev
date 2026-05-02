class Surah {
  final int id;
  final String nameAr;
  final String nameEn;

  Surah({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: _parseInt(json['id']),
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}