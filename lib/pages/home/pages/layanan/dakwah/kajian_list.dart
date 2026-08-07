import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/kajian_bloc/kajian_bloc.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/card_kajian.dart';
import 'package:puldapii/utils/widget/widget_filter.dart';
import 'package:puldapii/utils/widget/widget_filter_all.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';

class KajianListPage extends StatefulWidget {
  const KajianListPage({super.key});

  @override
  State<KajianListPage> createState() => _KajianListPageState();
}

class _KajianListPageState extends State<KajianListPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> filters = ['Terbaru', 'Terdekat', 'Segera'];

  final Map<int, int> flexMap = {0: 2, 1: 2, 2: 2};

  bool _showPager = false;

  void _setShowPager(bool value) {
    if (!mounted || _showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<KajianBloc, KajianState>(
        builder: (context, state) {
          // Pager hanya aktif jika ada halaman sebelumnya
          // atau masih ada halaman berikutnya.
          final bool hasPagination = state.page > 1 || state.hasNextPage;

          final bool shouldShowPager = _showPager && hasPagination;

          return Column(
            children: [
              AppHeader(
                onChatTap: () {
                  debugPrint('Chat tapped');
                },
              ),

              Expanded(
                child: GradientPage(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: hasPagination
                                ? () {
                                    _setShowPager(!_showPager);
                                  }
                                : null,
                            child: NotificationListener<UserScrollNotification>(
                              onNotification: (notification) {
                                if (!hasPagination) {
                                  return false;
                                }

                                if (notification.metrics.axis !=
                                    Axis.vertical) {
                                  return false;
                                }

                                if (notification.direction ==
                                    ScrollDirection.reverse) {
                                  // Scroll ke bawah,
                                  // tampilkan floating pager.
                                  _setShowPager(true);
                                } else if (notification.direction ==
                                    ScrollDirection.forward) {
                                  // Scroll ke atas,
                                  // sembunyikan floating pager.
                                  _setShowPager(false);
                                }

                                return false;
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    // Konten minimal setinggi layar.
                                    // Jadi ketika data sedikit,
                                    // area Stack tetap penuh.
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: AppSearchBar(
                                          controller: _searchController,
                                          hintText: 'Cari Kajian...',
                                          onChanged: (value) {
                                            context.read<KajianBloc>().add(
                                              UpdateKajianSearch(value),
                                            );
                                          },
                                          onClear: () {
                                            _searchController.clear();

                                            context.read<KajianBloc>().add(
                                              UpdateKajianSearch(''),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      FilterWidget(
                                        items: filters,
                                        selectedIndex: state.selectedFilter,
                                        flexMap: flexMap,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.75,
                                        margin: const EdgeInsets.only(left: 16),
                                        onChanged: (index) {
                                          context.read<KajianBloc>().add(
                                            UpdateKajianMainFilter(index),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 10),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: FilterSection(
                                          options: state.tagOptions
                                              .map(
                                                (tag) => FilterOption(
                                                  id: tag.id,
                                                  name: tag.name,
                                                ),
                                              )
                                              .toList(),
                                          selectedIds: state.selectedTagIds,
                                          onApply: (selected) {
                                            context.read<KajianBloc>().add(
                                              UpdateKajianTags(
                                                Set<int>.from(selected),
                                              ),
                                            );
                                          },
                                          onRemoveTag: (id) {
                                            context.read<KajianBloc>().add(
                                              RemoveKajianTag(id),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          8,
                                          8,
                                          120,
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            if (state.isLoading &&
                                                state.rawItems.isEmpty) {
                                              return const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            }

                                            if (state.errorMessage != null) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Text(
                                                  state.errorMessage!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }

                                            if (state.filteredItems.isEmpty) {
                                              return const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Center(
                                                  child: Text(
                                                    'Kajian tidak ditemukan.',
                                                  ),
                                                ),
                                              );
                                            }

                                            return Column(
                                              children: state.filteredItems
                                                  .map(
                                                    (item) => dakwahItemFromApi(
                                                      item,
                                                      context,
                                                    ),
                                                  )
                                                  .toList(),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          FloatingPager(
                            showPager: shouldShowPager,
                            page: state.page,
                            isLoading: state.isLoading,
                            hasNextPage: state.hasNextPage,
                            onPageChanged: (newPage) {
                              context.read<KajianBloc>().add(
                                ChangeKajianPage(newPage),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
