import 'package:puldapii/models/quran_mushaf_model.dart';

class QuranPageModel {
  final int pageNumber;
  final List<QuranAyahModel> ayahs;

  const QuranPageModel({required this.pageNumber, required this.ayahs});
}
