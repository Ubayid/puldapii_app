import 'package:flutter/material.dart';

class FilterOption {
  final int id;
  final String name;

  const FilterOption({required this.id, required this.name});
}

class FilterSection extends StatelessWidget {
  const FilterSection({
    super.key,
    required this.options,
    required this.selectedIds,
    required this.onApply,
    required this.onRemoveTag,
    this.buttonLabel = 'Filter',
    this.sheetTitle = 'Pilih Filter',
    this.applyText = 'Terapkan',
    this.loadingText = 'Memuat tag...',
    this.columns = 4,
  });

  final List<FilterOption> options;
  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onApply;
  final ValueChanged<int> onRemoveTag;

  final String buttonLabel;
  final String sheetTitle;
  final String applyText;
  final String loadingText;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final selectedOptions = options
        .where((e) => selectedIds.contains(e.id))
        .toList();

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: selectedOptions.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: false,
                    physics: const BouncingScrollPhysics(),
                    primary: false,
                    itemCount: selectedOptions.length,
                    itemBuilder: (context, index) {
                      final item =
                          selectedOptions[selectedOptions.length - 1 - index];
                      return _SelectedTagChip(
                        text: item.name,
                        onClear: () => onRemoveTag(item.id),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 32,
          child: InkWell(
            onTap: () => _openFilterSheet(context),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(251, 205, 76, 1),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tune,
                    size: 16,
                    color: Color.fromRGBO(24, 100, 80, 1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(24, 100, 80, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final tempSelected = <int>{...selectedIds};

    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    sheetTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (options.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(loadingText),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.55,
                      ),
                      child: SingleChildScrollView(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 10.0;
                            const runSpacing = 10.0;
                            const chipHeight = 38.0;

                            final itemWidth =
                                (constraints.maxWidth -
                                    (spacing * (columns - 1))) /
                                columns;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: runSpacing,
                              children: options.map((opt) {
                                final checked = tempSelected.contains(opt.id);

                                return ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                    width: itemWidth,
                                    height: chipHeight,
                                  ),
                                  child: FilterChip(
                                    selected: checked,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: Colors.white,
                                    selectedColor: Colors.blue,
                                    showCheckmark: false,
                                    checkmarkColor: Colors.transparent,
                                    side: BorderSide(
                                      color: checked
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                    label: Center(
                                      child: Text(
                                        opt.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: checked
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onSelected: (v) {
                                      if (v) {
                                        tempSelected.add(opt.id);
                                      } else {
                                        tempSelected.remove(opt.id);
                                      }
                                      setModalState(() {});
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, tempSelected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(251, 205, 76, 1),
                      ),
                      child: Text(
                        applyText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 100, 80, 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      onApply(result);
    }
  }
}

class _SelectedTagChip extends StatelessWidget {
  const _SelectedTagChip({required this.text, required this.onClear});

  final String text;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 100, 80, 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(24, 100, 80, 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(24, 100, 80, 1),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClear,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 14,
                color: Color.fromRGBO(24, 100, 80, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
