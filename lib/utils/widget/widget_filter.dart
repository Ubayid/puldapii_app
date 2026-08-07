import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.flexMap,
    this.width,
    this.height = 30,
    this.margin,
    this.backgroundColor = const Color.fromRGBO(229, 230, 234, 1),
    this.activeColor = const Color.fromRGBO(90, 178, 173, 1),
    this.inactiveColor = Colors.transparent,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = const Color.fromRGBO(80, 83, 88, 1),
    this.fontSize = 13,
    this.borderRadius = 20,
    this.itemRadius = 16,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// contoh: {0: 2, 1: 1, 2: 1}
  final Map<int, int>? flexMap;

  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;

  final double fontSize;
  final double borderRadius;
  final double itemRadius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final isActive = selectedIndex == index;

            return Flexible(
              flex: flexMap?[index] ?? 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(itemRadius),
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : inactiveColor,
                    borderRadius: BorderRadius.circular(itemRadius),
                  ),
                  child: Text(
                    items[index],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isActive ? activeTextColor : inactiveTextColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
