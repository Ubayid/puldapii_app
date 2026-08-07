class SurahOption {
  final int id;
  final int surahNumber;
  final String name;
  final int startPage;
  final int totalAyah;

  const SurahOption({
    required this.id,
    required this.surahNumber,
    required this.name,
    required this.startPage,
    required this.totalAyah,
  });
}

class AyahOption {
  final int ayahNumber;
  final int page;

  const AyahOption({required this.ayahNumber, required this.page});
}
