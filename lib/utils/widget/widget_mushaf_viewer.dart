import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';
import 'package:puldapii/utils/helper/mushaf_image_helper.dart';
import 'card_container.dart';

class MushafImageViewer extends StatelessWidget {
  final QuranMushafModel mushaf;
  final PageController pageController;
  final int totalPages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;

  const MushafImageViewer({
    super.key,
    required this.mushaf,
    required this.pageController,
    required this.totalPages,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 520,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: totalPages,
                  reverse: true,
                  onPageChanged: (index) => onPageChanged(index + 1),
                  itemBuilder: (context, index) {
                    final page = index + 1;

                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: SvgPicture.network(
                        MushafImageHelper.getMushafPageUrl(mushaf, page),
                        key: ValueKey('mushaf-page-$page'),
                        fit: BoxFit.contain,
                        placeholderBuilder: (_) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentPage',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
