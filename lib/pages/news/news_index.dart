import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/cubit/new_cubit/new_cubit.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/card_news.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  bool _showPager = false;
  bool _showPagerOnScroll = false;

  static const List<String> _categories = ['Semua', 'Berita', 'Info'];

  static const List<int> _categoryFlex = [2, 2, 2];

  @override
  void initState() {
    super.initState();

    final currentState = context.read<NewsCubit>().state;

    _searchController.text = currentState.search;

    if (currentState.listStatus == NewsListStatus.initial) {
      context.read<NewsCubit>().fetchNews();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<NewsCubit>().searchNews(value.trim());
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();

    context.read<NewsCubit>().searchNews('');
  }

  void _setPagerByScroll(bool value) {
    if (_showPagerOnScroll == value) {
      return;
    }

    setState(() {
      _showPagerOnScroll = value;
    });
  }

  void _togglePager() {
    setState(() {
      _showPager = !_showPager;
    });
  }

  int _getSelectedCategoryIndex(String category) {
    final normalizedCategory = category.trim().toLowerCase();

    final index = _categories.indexWhere(
      (item) => item.toLowerCase() == normalizedCategory,
    );

    return index == -1 ? 0 : index;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewsCubit, NewsState>(
      listener: (context, state) {
        if (state.listStatus == NewsListStatus.failure &&
            state.news.isNotEmpty &&
            state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));

          context.read<NewsCubit>().clearMessage();
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state.listStatus == NewsListStatus.loading ||
            state.listStatus == NewsListStatus.loadingMore;

        final int selectedCategoryIndex = _getSelectedCategoryIndex(
          state.category,
        );

        return Scaffold(
          body: Column(
            children: [
              AppHeader(onChatTap: () {}),

              Expanded(
                child: GradientPage(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Cari Berita...',
                          onChanged: _onSearchChanged,
                          onClear: _clearSearch,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _filterBar(
                        context: context,
                        selectedCategoryIndex: selectedCategoryIndex,
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _togglePager,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child:
                                    NotificationListener<
                                      UserScrollNotification
                                    >(
                                      onNotification: (notification) {
                                        if (notification.metrics.axis ==
                                            Axis.vertical) {
                                          if (notification.direction ==
                                              ScrollDirection.reverse) {
                                            _setPagerByScroll(true);
                                          } else if (notification.direction ==
                                              ScrollDirection.forward) {
                                            _setPagerByScroll(false);
                                          }
                                        }

                                        return false;
                                      },
                                      child: _buildBody(context, state),
                                    ),
                              ),

                              FloatingPager(
                                showPager:
                                    state.news.isNotEmpty &&
                                    (_showPager || _showPagerOnScroll),
                                page: state.currentPage,
                                isLoading: isLoading,
                                hasNextPage: state.hasMorePages,
                                onPageChanged: (newPage) {
                                  context.read<NewsCubit>().fetchNewsPage(
                                    newPage,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterBar({
    required BuildContext context,
    required int selectedCategoryIndex,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        width: MediaQuery.of(context).size.width * 0.65,
        height: 30,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 230, 234, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: List.generate(_categories.length, (index) {
            final bool isActive = selectedCategoryIndex == index;

            return Flexible(
              flex: _categoryFlex[index],
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (isActive) {
                    return;
                  }

                  context.read<NewsCubit>().filterByCategory(
                    _categories[index],
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color.fromRGBO(90, 178, 173, 1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive
                          ? Colors.white
                          : const Color.fromRGBO(80, 83, 88, 1),
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

  Widget _buildBody(BuildContext context, NewsState state) {
    if (state.listStatus == NewsListStatus.loading && state.news.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.listStatus == NewsListStatus.failure && state.news.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          Icon(
            Icons.error_outline_rounded,
            size: 50,
            color: Colors.grey.shade500,
          ),

          const SizedBox(height: 12),

          Text(
            state.message ?? 'Gagal memuat berita.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<NewsCubit>().fetchNews();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(90, 178, 173, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    if (state.news.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 110),

          Icon(Icons.newspaper_outlined, size: 52, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          const Text('Berita tidak ditemukan', textAlign: TextAlign.center),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.news.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final news = state.news[index];

        return NewsCard(news: news);
      },
    );
  }
}
