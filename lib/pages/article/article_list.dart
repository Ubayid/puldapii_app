import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/article_bloc/article_bloc.dart';
import 'package:puldapii/utils/services/article/article_service.dart';
import 'package:puldapii/utils/widget/card_article.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_filter_all.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({super.key, this.categoryIds});

  final List<int>? categoryIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArticleBloc(service: ArticleService())
            ..add(ArticleInitialized(initialCategoryIds: categoryIds)),
      child: const _ArticleListView(),
    );
  }
}

class _ArticleListView extends StatefulWidget {
  const _ArticleListView();

  @override
  State<_ArticleListView> createState() => __ArticleListViewState();
}

class __ArticleListViewState extends State<_ArticleListView> {
  final TextEditingController _searchController = TextEditingController();

  bool _showPagerOnScroll = false;

  void _setPagerByScroll(bool value) {
    if (_showPagerOnScroll == value) return;

    setState(() {
      _showPagerOnScroll = value;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        final current = state is ArticleLoaded ? state : const ArticleLoaded();

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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Cari Artikel...',
                          onChanged: (value) {
                            context.read<ArticleBloc>().add(
                              ArticleSearchChanged(value),
                            );
                          },
                          onClear: () {
                            _searchController.clear();
                            context.read<ArticleBloc>().add(
                              const ArticleSearchCleared(),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilterSection(
                          options: current.categoryOptions,
                          selectedIds: current.selectedCategoryIds,
                          onApply: (selected) {
                            context.read<ArticleBloc>().add(
                              ArticleCategoriesApplied(selected),
                            );
                          },
                          onRemoveTag: (id) {
                            context.read<ArticleBloc>().add(
                              ArticleCategoryRemoved(id),
                            );
                          },
                          buttonLabel: 'Kategori',
                          sheetTitle: 'Pilih Kategori',
                        ),
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            context.read<ArticleBloc>().add(
                              const ArticlePagerToggled(),
                            );
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: NotificationListener<UserScrollNotification>(
                                  onNotification: (notification) {
                                    if (notification.metrics.axis ==
                                        Axis.vertical) {
                                      if (notification.direction ==
                                          ScrollDirection.reverse) {
                                        // Scroll ke bawah, pager muncul
                                        _setPagerByScroll(true);
                                      } else if (notification.direction ==
                                          ScrollDirection.forward) {
                                        // Scroll ke atas, pager disembunyikan lagi
                                        _setPagerByScroll(false);
                                      }
                                    }

                                    return false;
                                  },
                                  child: _buildBody(context, current),
                                ),
                              ),

                              FloatingPager(
                                showPager:
                                    current.showPager || _showPagerOnScroll,
                                page: current.page,
                                isLoading: current.isLoading,
                                hasNextPage: current.hasNextPage,
                                onPageChanged: (newPage) {
                                  context.read<ArticleBloc>().add(
                                    ArticleFetched(page: newPage),
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

  Widget _buildBody(BuildContext context, ArticleLoaded state) {
    if (state.isLoading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Gagal memuat artikel\n${state.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.articles.isEmpty) {
      return const Center(child: Text('Artikel tidak ditemukan'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final article = state.articles[index];
        return ArticleCard(article: article);
      },
    );
  }
}
