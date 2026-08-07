import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/ustadz_bloc/ustadz_bloc.dart';
import 'package:puldapii/utils/services/home/ustadz_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/card_ustadz.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_filter.dart';
import 'package:puldapii/utils/widget/widget_filter_all.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';

class RelawanPage extends StatelessWidget {
  const RelawanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          UstadzBloc(UstadzService(), roleSlugs: ['relawan'])
            ..add(FetchUstadzList()),
      child: const RelawanView(),
    );
  }
}

class RelawanView extends StatefulWidget {
  const RelawanView({super.key});

  @override
  State<RelawanView> createState() => _RelawanViewState();
}

class _RelawanViewState extends State<RelawanView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showPager = false;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

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
      body: Column(
        children: [
          AppHeader(
            onChatTap: () {
              print("Chat tapped");
            },
          ),
          Expanded(
            child: GradientPage(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    BlocBuilder<UstadzBloc, UstadzState>(
                      builder: (context, state) {
                        final searchText = state is UstadzListLoaded
                            ? state.searchQuery
                            : '';

                        if (_searchController.text != searchText) {
                          _searchController.value = TextEditingValue(
                            text: searchText,
                            selection: TextSelection.collapsed(
                              offset: searchText.length,
                            ),
                          );
                        }

                        return Column(
                          children: [
                            AppSearchBar(
                              controller: _searchController,
                              hintText: 'Cari relawan...',
                              onChanged: (value) {
                                context.read<UstadzBloc>().add(
                                  UpdateUstadzSearch(value),
                                );
                              },
                              onClear: () {
                                _searchController.clear();
                                context.read<UstadzBloc>().add(
                                  UpdateUstadzSearch(''),
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            FilterWidget(
                              width:
                                  (MediaQuery.of(context).size.width - 32) *
                                  2 /
                                  3,
                              height: 34,
                              items: const ['Semua', 'Aktif', 'Nonaktif'],
                              selectedIndex: state is UstadzListLoaded
                                  ? state.selectedStatusIndex
                                  : 0,
                              flexMap: const {0: 2, 1: 2, 2: 3},
                              onChanged: (index) {
                                context.read<UstadzBloc>().add(
                                  UpdateUstadzStatusFilter(index),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            FilterSection(
                              options: state is UstadzListLoaded
                                  ? state.expertiseOptions
                                  : const [],
                              selectedIds: state is UstadzListLoaded
                                  ? state.selectedExpertiseIds
                                  : <int>{},
                              onApply: (selected) {
                                context.read<UstadzBloc>().add(
                                  UpdateUstadzExpertiseFilter(selected),
                                );
                              },
                              onRemoveTag: (id) {
                                context.read<UstadzBloc>().add(
                                  RemoveUstadzExpertiseFilter(id),
                                );
                              },
                              buttonLabel: 'Keahlian',
                              sheetTitle: 'Pilih Keahlian',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocBuilder<UstadzBloc, UstadzState>(
                        builder: (context, state) {
                          if (state is UstadzLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is UstadzError) {
                            return Center(child: Text(state.message));
                          }

                          if (state is UstadzListLoaded) {
                            if (state.filteredItems.isEmpty) {
                              return const Center(
                                child: Text('Tidak ada relawan yang tercatat'),
                              );
                            }

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _showPager = !_showPager;
                                });
                              },
                              child: Stack(
                                children: [
                                  NotificationListener<UserScrollNotification>(
                                    onNotification: (notification) {
                                      if (notification.metrics.axis ==
                                          Axis.vertical) {
                                        if (notification.direction ==
                                            ScrollDirection.reverse) {
                                          // Scroll ke bawah, pager muncul
                                          _setShowPager(true);
                                        } else if (notification.direction ==
                                            ScrollDirection.forward) {
                                          // Scroll ke atas, pager hilang
                                          _setShowPager(false);
                                        }
                                      }

                                      return false;
                                    },
                                    child: ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        25,
                                      ),
                                      itemCount: state.pagedItems.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final ustadz = state.pagedItems[index];
                                        return UstadzListCard(ustadz: ustadz);
                                      },
                                    ),
                                  ),
                                  FloatingPager(
                                    showPager:
                                        _showPager && state.totalPages > 1,
                                    page: state.currentPage,
                                    isLoading: false,
                                    hasNextPage: state.hasNextPage,
                                    onPageChanged: (newPage) {
                                      context.read<UstadzBloc>().add(
                                        ChangeUstadzPage(newPage),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
