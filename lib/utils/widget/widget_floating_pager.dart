import 'package:flutter/material.dart';

class FloatingPager extends StatelessWidget {
  final bool showPager;
  final int page;
  final bool isLoading;
  final bool hasNextPage;
  final ValueChanged<int> onPageChanged;

  const FloatingPager({
    super.key,
    required this.showPager,
    required this.page,
    required this.isLoading,
    required this.hasNextPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget circleButton({required Widget child, VoidCallback? onTap}) {
      return Material(
        color: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 52, height: 52, child: Center(child: child)),
        ),
      );
    }

    void prev() {
      if (page > 1 && !isLoading) {
        onPageChanged(page - 1);
      }
    }

    void next() {
      if (hasNextPage && !isLoading) {
        onPageChanged(page + 1);
      }
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: showPager ? 16 : -90,
      child: IgnorePointer(
        ignoring: !showPager,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            circleButton(
              onTap: (page > 1 && !isLoading) ? prev : null,
              child: Icon(
                Icons.keyboard_arrow_left,
                color: (page > 1 && !isLoading) ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(width: 14),
            circleButton(
              child: Text(
                '$page',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            circleButton(
              onTap: (hasNextPage && !isLoading) ? next : null,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: (hasNextPage && !isLoading) ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
