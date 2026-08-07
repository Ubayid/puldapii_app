import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/book_bloc/book_bloc.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_recipient_page.dart';
import 'package:puldapii/pages/home/pages/layanan/books/catalog_section.dart';
import 'package:puldapii/pages/home/pages/layanan/books/submission_section.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_taawun_page.dart';
import 'package:puldapii/pages/home/pages/layanan/books/taawun_section.dart';
import 'package:puldapii/utils/services/home/book_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TebarBukuPage extends StatelessWidget {
  const TebarBukuPage({super.key});

  static const int perPage = 20;
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BookBloc(BookService())
            ..add(FetchBooks(page: 1, perPage: TebarBukuPage.perPage)),
      child: const _TebarBukuView(),
    );
  }
}

class _TebarBukuView extends StatefulWidget {
  const _TebarBukuView();

  @override
  State<_TebarBukuView> createState() => _TebarBukuViewState();
}

class _TebarBukuViewState extends State<_TebarBukuView> {
  int _selectedTab = 0;
  int _page = 1;
  bool _showPager = false;

  int _pengajuanReloadKey = 0;
  int _pengajuanPage = 1;
  int _pengajuanTotalPage = 1;

  int _taawunReloadKey = 0;
  int _taawunPage = 1;
  int _taawunTotalPage = 1;

  static const int _taawunPerPage = 5;

  String? _authToken;
  bool _authChecked = false;

  bool get _isLoggedIn => (_authToken ?? '').trim().isNotEmpty;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  Future<void> _loadLoginStatus() async {
    final token = await _getToken();

    if (!mounted) return;

    setState(() {
      _authToken = token;
      _authChecked = true;
    });
  }

  void _changePengajuanPage(int newPage) {
    if (newPage < 1 || newPage == _pengajuanPage) return;
    if (newPage > _pengajuanTotalPage) return;

    setState(() {
      _pengajuanPage = newPage;
    });
  }

  void _updatePengajuanTotalPage(int totalPage) {
    final safeTotalPage = totalPage < 1 ? 1 : totalPage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_pengajuanTotalPage == safeTotalPage &&
          _pengajuanPage <= safeTotalPage) {
        return;
      }

      setState(() {
        _pengajuanTotalPage = safeTotalPage;

        if (_pengajuanPage > safeTotalPage) {
          _pengajuanPage = safeTotalPage;
        }
      });
    });
  }

  void _changeTaawunPage(int newPage) {
    if (newPage < 1 || newPage == _taawunPage) return;
    if (newPage > _taawunTotalPage) return;

    setState(() {
      _taawunPage = newPage;
    });
  }

  void _updateTaawunTotalPage(int totalPage) {
    final safeTotalPage = totalPage < 1 ? 1 : totalPage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_taawunTotalPage == safeTotalPage && _taawunPage <= safeTotalPage) {
        return;
      }

      setState(() {
        _taawunTotalPage = safeTotalPage;

        if (_taawunPage > safeTotalPage) {
          _taawunPage = safeTotalPage;
        }
      });
    });
  }

  Future<void> _openTaawunPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _showOverlayMessage(context, 'Silahkan login terlebih dahulu');
      return;
    }

    final state = context.read<BookBloc>().state;

    if (state is! BooksLoaded || state.books.isEmpty) {
      _showOverlayMessage(
        context,
        'Data buku belum tersedia. Silakan coba lagi.',
      );
      return;
    }

    final book = state.books.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaawunPage(
          bookId: book.id,
          title: book.title,
          category: book.category?.name ?? '-',
          coverUrl: book.coverImageUrl,
          targetQuantity: book.targetQuantity,
          collectedQuantity: book.collectedQuantity,
        ),
      ),
    );
  }

  Future<void> _openBookRecipientPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _showOverlayMessage(context, 'Silahkan login terlebih dahulu');
      return;
    }

    final state = context.read<BookBloc>().state;

    if (state is! BooksLoaded || state.books.isEmpty) {
      _showOverlayMessage(
        context,
        'Data buku belum tersedia. Silakan coba lagi.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookRecipientPage(
          token: token,
          books: state.books,
          initialBook: state.books.first,
        ),
      ),
    );
  }

  void _changePage(int newPage) {
    if (newPage < 1 || newPage == _page) return;

    setState(() {
      _page = newPage;
      _showPager = false;
    });

    context.read<BookBloc>().add(
      FetchBooks(page: newPage, perPage: TebarBukuPage.perPage),
    );
  }

  void _handleScrollDirection(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) {
      // Scroll ke bawah, pager muncul
      _setShowPager(true);
    } else if (direction == ScrollDirection.forward) {
      // Scroll ke atas, pager hilang
      _setShowPager(false);
    }
  }

  void _toggleFloatingPager() {
    setState(() => _showPager = !_showPager);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppHeader(onChatTap: () {}),

                Expanded(
                  child: GradientPage(
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        _handleScrollDirection(notification.direction);
                        return false;
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleFloatingPager,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 110),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TebarBukuTab(
                                selectedIndex: _selectedTab,
                                onTap: (index) {
                                  setState(() {
                                    _selectedTab = index;
                                    _showPager = false;

                                    if (index == 1) {
                                      _taawunReloadKey++;
                                      _taawunPage = 1;
                                    }
                                    if (index == 2) {
                                      _pengajuanReloadKey++;
                                      _pengajuanPage = 1;
                                    }
                                  });
                                },
                              ),

                              const SizedBox(height: 14),

                              if (_selectedTab == 0) ...[
                                CatalogPage(
                                  onShowMessage: (message) {
                                    _showOverlayMessage(context, message);
                                  },
                                ),
                              ] else if (_selectedTab == 1) ...[
                                if (!_authChecked)
                                  const _CheckingLoginView()
                                else if (!_isLoggedIn)
                                  const _LoginRequiredView()
                                else
                                  TaawunSection(
                                    refreshKey: _taawunReloadKey,
                                    page: _taawunPage,
                                    perPage: _taawunPerPage,
                                    onTotalPageChanged: _updateTaawunTotalPage,
                                    onShowMessage: (message) {
                                      _showOverlayMessage(context, message);
                                    },
                                  ),
                              ] else if (_selectedTab == 2) ...[
                                if (!_authChecked)
                                  const _CheckingLoginView()
                                else if (!_isLoggedIn)
                                  const _LoginRequiredView()
                                else
                                  SubmissionSection(
                                    refreshKey: _pengajuanReloadKey,
                                    page: _pengajuanPage,
                                    perPage: 5,
                                    onTotalPageChanged:
                                        _updatePengajuanTotalPage,
                                    onShowMessage: (message) {
                                      _showOverlayMessage(context, message);
                                    },
                                  ),
                              ],

                              const SizedBox(height: 4),

                              _ActionButtonSection(
                                onTaawunTap: _openTaawunPage,
                                onPengajuanTap: _openBookRecipientPage,
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_selectedTab == 1)
              FloatingPager(
                showPager: _showPager,
                page: _taawunPage,
                isLoading: false,
                hasNextPage: _taawunPage < _taawunTotalPage,
                onPageChanged: _changeTaawunPage,
              )
            else if (_selectedTab == 2)
              FloatingPager(
                showPager: _showPager,
                page: _pengajuanPage,
                isLoading: false,
                hasNextPage: _pengajuanPage < _pengajuanTotalPage,
                onPageChanged: _changePengajuanPage,
              )
            else
              BlocBuilder<BookBloc, BookState>(
                builder: (context, state) {
                  final isLoading = state is BookLoading;

                  final hasNextPage =
                      state is BooksLoaded &&
                      state.books.length >= TebarBukuPage.perPage;

                  return FloatingPager(
                    showPager: _selectedTab == 0 && _showPager,
                    page: _page,
                    isLoading: isLoading,
                    hasNextPage: hasNextPage,
                    onPageChanged: _changePage,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TebarBukuTab extends StatelessWidget {
  const _TebarBukuTab({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tabs = ['Katalog', 'Taawun Saya', 'Pengajuan Saya'];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = selectedIndex == index;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(index),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      tabs[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? TebarBukuPage.primaryColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF12A99C)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActionButtonSection extends StatelessWidget {
  const _ActionButtonSection({
    required this.onTaawunTap,
    required this.onPengajuanTap,
  });

  final VoidCallback onTaawunTap;
  final VoidCallback onPengajuanTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionCard(
          color: const Color(0xFF12A99C),
          icon: Icons.print_rounded,
          title: 'Taawun Pencetakan Buku',
          subtitle: 'Dukung biaya cetak buku',
          textColor: Colors.white,
          onTap: onTaawunTap,
        ),

        const SizedBox(height: 10),

        _ActionCard(
          color: const Color(0xFFFFB91D),
          icon: Icons.groups_rounded,
          title: 'Pengajuan Penerima Buku',
          subtitle: 'Ajukan sebagai penerima',
          textColor: Colors.black,
          onTap: onPengajuanTap,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkText = textColor == Colors.black;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 27),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkText
                            ? Colors.black.withOpacity(0.72)
                            : Colors.white.withOpacity(0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: textColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

void _showOverlayMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 20,
        right: 20,
        bottom: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: TebarBukuPage.primaryColor,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Login terlebih dahulu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: TebarBukuPage.primaryColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Silakan login untuk melihat data taawun dan pengajuan kamu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF657174),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckingLoginView extends StatelessWidget {
  const _CheckingLoginView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: CircularProgressIndicator(color: TebarBukuPage.primaryColor),
      ),
    );
  }
}
