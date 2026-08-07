import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/hadist_bloc/hadist_bloc.dart';
import 'package:puldapii/config/bloc/hadist_detail_bloc/hadist_detail_bloc.dart';
import 'package:puldapii/models/hadist_model.dart';
import 'package:puldapii/pages/home/pages/ibadah/hadist/hadist_detail_page.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';

class HadistListPage extends StatefulWidget {
  final String book;

  const HadistListPage({super.key, required this.book});

  @override
  State<HadistListPage> createState() => _HadistListPageState();
}

class _HadistListPageState extends State<HadistListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _showPager = false;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadistBloc>().add(
        FetchHadistList(book: widget.book, page: 1, perPage: 10, query: ''),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _formatBookName(String value) {
    return value
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<HadistBloc>().add(UpdateHadistSearch(value));
    });
  }

  String _readNumber(HadistModel item) => item.id.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(onChatTap: () {}),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<HadistBloc, HadistState>(
                builder: (context, state) {
                  final isLoading = state is HadistLoading;
                  final loaded = state is HadistLoaded ? state : null;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(Icons.arrow_back, size: 18),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatBookName(widget.book),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Cari hadist...',
                          onChanged: _onSearchChanged,
                          onClear: () {
                            _searchController.clear();
                            setState(() {});
                            context.read<HadistBloc>().add(
                              UpdateHadistSearch(''),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: Builder(
                          builder: (_) {
                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is HadistError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(state.message),
                                ),
                              );
                            }

                            if (loaded == null || loaded.data.items.isEmpty) {
                              return const Center(
                                child: Text('Data hadist kosong'),
                              );
                            }

                            final currentPage = loaded.data.currentPage;
                            final hasNextPage =
                                currentPage < loaded.data.lastPage;

                            return Stack(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _showPager = !_showPager;
                                    });
                                  },
                                  child: NotificationListener<UserScrollNotification>(
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
                                        16,
                                        0,
                                        16,
                                        100,
                                      ),
                                      itemCount: loaded.data.items.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final item = loaded.data.items[index];
                                        final number = _readNumber(item);

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BlocProvider(
                                                  create: (context) =>
                                                      HadistDetailBloc(
                                                        context
                                                            .read<HadistBloc>()
                                                            .service,
                                                      ),
                                                  child: HadistDetailPage(
                                                    book: widget.book,
                                                    id: item.id,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.92,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 42,
                                                  height: 42,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal
                                                        .withOpacity(0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    number,
                                                    style: const TextStyle(
                                                      color: Colors.teal,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.arab,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.right,
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontSize: 15,
                                                              height: 1.8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        item.terjemah, // atau item.arti, sesuaikan model
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: Colors
                                                                  .grey[700],
                                                              height: 1.5,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                FloatingPager(
                                  showPager: _showPager,
                                  page: currentPage,
                                  isLoading: isLoading,
                                  hasNextPage: hasNextPage,
                                  onPageChanged: (newPage) {
                                    FocusScope.of(context).unfocus();
                                    context.read<HadistBloc>().add(
                                      ChangeHadistPage(newPage),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
