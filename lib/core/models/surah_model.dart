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
      id: int.parse(json['id']),
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
    );
  }
}