import 'package:puldapii/models/mushaf_dropdown_option.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';

class MushafImageHelper {
  static String getMushafSlug(QuranMushafModel mushaf) {
    final url = mushaf.imagesPng?.isNotEmpty == true
        ? mushaf.imagesPng!
        : (mushaf.images ?? '');

    if (url.isEmpty) return 'hafs';

    final filename = Uri.parse(url).pathSegments.last;
    return filename.replaceAll('.zip', '');
  }

  static String getMushafPageUrl(QuranMushafModel mushaf, int page) {
    final slug = getMushafSlug(mushaf);
    return 'https://layanan.puldapii.or.id/api/quran/mushaf-page/$slug/$page';
  }

  static int? getPageFromJuz(int juz) {
    const juzStartPages = {
      1: 1,
      2: 22,
      3: 42,
      4: 62,
      5: 82,
      6: 102,
      7: 121,
      8: 142,
      9: 162,
      10: 182,
      11: 201,
      12: 222,
      13: 242,
      14: 262,
      15: 282,
      16: 302,
      17: 322,
      18: 342,
      19: 362,
      20: 382,
      21: 402,
      22: 422,
      23: 442,
      24: 462,
      25: 482,
      26: 502,
      27: 522,
      28: 542,
      29: 562,
      30: 582,
    };

    return juzStartPages[juz];
  }

  static List<SurahOption> buildSurahOptions(QuranMushafModel mushaf) {
    return mushaf.surahs.map((surah) {
      final ayahs = surah.ayahs;
      final startPage = ayahs.isNotEmpty ? ayahs.first.pageNumber : 1;

      return SurahOption(
        id: surah.id,
        surahNumber: surah.surahNumber,
        name: surah.name,
        startPage: startPage,
        totalAyah: ayahs.length,
      );
    }).toList();
  }

  static List<AyahOption> buildAyahOptions(
    QuranMushafModel mushaf,
    int surahId,
  ) {
    final QuranSurahModel? surah = mushaf.surahs
        .cast<QuranSurahModel?>()
        .firstWhere((item) => item?.id == surahId, orElse: () => null);

    if (surah == null) return [];

    return surah.ayahs.map((ayah) {
      return AyahOption(ayahNumber: ayah.number, page: ayah.pageNumber);
    }).toList();
  }

  static int? findCurrentSurahIdFromPage(
    QuranMushafModel mushaf,
    List<QuranAyahModel> currentPageAyahs,
  ) {
    if (currentPageAyahs.isEmpty) return null;

    final currentSurahNumber = currentPageAyahs.first.surah;

    final QuranSurahModel? match = mushaf.surahs
        .cast<QuranSurahModel?>()
        .firstWhere(
          (surah) =>
              surah?.surahNumber == currentSurahNumber ||
              surah?.id == currentSurahNumber,
          orElse: () => null,
        );

    return match?.id;
  }
}
