import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/dzikir_pp_bloc/dzikir_pp_bloc.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';

class DzikirPpDetailPage extends StatefulWidget {
  final DzikirPpCategory category;

  const DzikirPpDetailPage({super.key, required this.category});

  @override
  State<DzikirPpDetailPage> createState() => _DzikirPpDetailPageState();
}

class _DzikirPpDetailPageState extends State<DzikirPpDetailPage> {
  bool _showPager = false;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(onChatTap: () {}),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<DzikirPpBloc, DzikirPpState>(
                builder: (context, state) {
                  final item = state.currentItem;

                  if (state.isLoading && item == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage != null && item == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(state.errorMessage!),
                      ),
                    );
                  }

                  if (item == null) {
                    return const Center(
                      child: Text('Data dzikir tidak ditemukan'),
                    );
                  }

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
                                widget.category.label,
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
                      Expanded(
                        child: Stack(
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
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    100,
                                  ),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.92),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
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
                                                  '${state.page}',
                                                  style: const TextStyle(
                                                    color: Colors.teal,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.title,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      item.slug,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Colors.grey,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.withOpacity(
                                                0.06,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              item.arabic,
                                              textAlign: TextAlign.right,
                                              textDirection: TextDirection.rtl,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    height: 2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),

                                          const SizedBox(height: 18),

                                          Text(
                                            'Arti',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item.arti,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(height: 1.7),
                                          ),

                                          if (item.penjelasan
                                              .trim()
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 18),
                                            Text(
                                              'Penjelasan',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.penjelasan,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(height: 1.7),
                                            ),
                                          ],

                                          const SizedBox(height: 18),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              'Waktu: ${item.waktu}',
                                              style: const TextStyle(
                                                color: Colors.teal,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            FloatingPager(
                              showPager: _showPager,
                              page: state.page,
                              isLoading: state.isLoading,
                              hasNextPage: state.hasNextPage,
                              onPageChanged: (newPage) {
                                context.read<DzikirPpBloc>().add(
                                  ChangeDzikirPpPage(newPage),
                                );
                              },
                            ),
                          ],
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
