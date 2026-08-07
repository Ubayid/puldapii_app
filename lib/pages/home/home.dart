import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/account_bloc/account_bloc.dart';
import 'package:puldapii/config/bloc/quran_mushaf_image_bloc/quran_mushaf_image_bloc.dart';
import 'package:puldapii/pages/account/account_page.dart';
import 'package:puldapii/pages/article/article_list.dart';
import 'package:puldapii/pages/home/pages/layanan/dakwah/kajian_list.dart';
import 'package:puldapii/pages/home/pages/dakwah_sdm/imam_muadzin_page.dart';
import 'package:puldapii/pages/home/pages/dakwah_sdm/khatib_page.dart';
import 'package:puldapii/pages/home/pages/dakwah_sdm/pemateri_page.dart';
import 'package:puldapii/pages/home/pages/dakwah_sdm/relawan_page.dart';
import 'package:puldapii/pages/home/pages/ibadah/dzikir_doa/dzikir_doa_list_page.dart';
import 'package:puldapii/pages/home/pages/ibadah/hadist/hadist_books_page.dart';
import 'package:puldapii/pages/home/pages/ibadah/jadwal_sholat/pray_schedule.dart';
import 'package:puldapii/pages/home/pages/ibadah/quran/quran_img_page.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_distribution_page.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_page.dart';
import 'package:puldapii/pages/home/pages/layanan/poster/poster_list_page.dart';
import 'package:puldapii/utils/helper/prayer_info.dart';
import 'package:puldapii/utils/services/home/dzikir_pp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dzikirPpService = DzikirPpService(Dio());

  int _carouselIndex = 0;

  final List<String> carouselImages = const [
    'assets/images/slide_1.png',
    'assets/images/slide_2.png',
    'assets/images/slide_3.png',
    'assets/images/slide_4.png',
  ];

  Future<void> _openKonsultasiPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silahkan login terlebih dahulu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConsultPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final topSafe = MediaQuery.paddingOf(context).top;

    final isTablet = screenWidth >= 700;
    final isDesktop = screenWidth >= 1100;

    final heroHeight = isTablet ? 260.0 : 230.0;
    final carouselHeight = isDesktop
        ? 140.0
        : isTablet
        ? 130.0
        : 120.0;

    final carouselOverlap = carouselHeight / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: Column(
          children: [
            SizedBox(
              height: heroHeight + carouselOverlap + 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroHeight,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(16, topSafe + 16, 16, 70),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        image: DecorationImage(
                          image: AssetImage('assets/images/herobg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/images/app_logo_ic.png",
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      Text(
                                        'Puldapii App',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 2
                                            ..color = Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'Puldapii App',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(24, 100, 80, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  const Text(
                                    'by PULDAPII',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              BlocBuilder<AccountBloc, AccountState>(
                                builder: (context, state) {
                                  String? photoUrl;
                                  String userName = "Login";

                                  if (state is AccountLoaded) {
                                    final user = state.user;

                                    if (user['type']?.toString() == 'ustadz') {
                                      final ustadz = user['ustadz'] is Map
                                          ? Map<String, dynamic>.from(
                                              user['ustadz'],
                                            )
                                          : null;

                                      photoUrl = ustadz?['image_url']
                                          ?.toString();
                                      userName =
                                          ustadz?['name']?.toString() ??
                                          user['name']?.toString() ??
                                          "Ustadz";
                                    } else {
                                      photoUrl = user['profile_photo_url']
                                          ?.toString();
                                      userName =
                                          user['name']?.toString() ??
                                          "Pengguna";
                                    }
                                  }

                                  final hasPhoto =
                                      photoUrl != null &&
                                      photoUrl.isNotEmpty &&
                                      photoUrl != 'null';

                                  final isLoggedIn = state is AccountLoaded;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AccountPage(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 90,
                                          ),
                                          child: Text(
                                            userName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromRGBO(
                                                24,
                                                100,
                                                80,
                                                1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 42,
                                          height: 42,
                                          child: hasPhoto
                                              ? ClipOval(
                                                  child: Image.network(
                                                    photoUrl,
                                                    width: 42,
                                                    height: 42,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) {
                                                      return const CircleAvatar(
                                                        radius: 21,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Icon(
                                                          Icons.person_rounded,
                                                          color: Color.fromRGBO(
                                                            24,
                                                            100,
                                                            80,
                                                            1,
                                                          ),
                                                          size: 26,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : const CircleAvatar(
                                                  radius: 21,
                                                  backgroundColor: Colors.white,
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    color: Color.fromRGBO(
                                                      24,
                                                      100,
                                                      80,
                                                      1,
                                                    ),
                                                    size: 26,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Platform Dakwah &\nPendidikan Islam Terpadu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(32, 86, 91, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    top: heroHeight - carouselOverlap,
                    child: _HomeCarousel(
                      images: carouselImages,
                      currentIndex: _carouselIndex,
                      onPageChanged: (index) {
                        setState(() {
                          _carouselIndex = index;
                        });
                      },
                      onTap: (index) {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ArticleList(),
                            ),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TebarBukuPage(),
                            ),
                          );
                        } else if (index == 2) {
                          _openKonsultasiPage();
                        } else if (index == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KajianListPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // lanjut section Ibadah, Dakwah, Layanan, dst...
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/icon_ibadah.png",
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Ibadah",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: menuItem(
                          "quran.png",
                          "Al-Qur'an",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<QuranMushafImageBloc>(),
                                  child: const QuranMushafImagePage(
                                    mushafId: 1,
                                    initialPage: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: menuItem(
                          "hadits.png",
                          "Hadist",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HadistBooksPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: menuItem(
                          "dzikir.png",
                          "Dzikir & Doa",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DzikirPpMenuPage(service: dzikirPpService),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: menuItem(
                          "jadwal_sholat.png",
                          "Jadwal Sholat",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrayerSchedulePage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/icon_dakwah.png",
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Dakwah & SDM",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: menuItem(
                                "khatib.png",
                                "Data Khatib",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const KhatibPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: menuItem(
                                "pemateri.png",
                                "Pemateri Kajian",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PemateriKajianPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: menuItem(
                                "imam.png",
                                "Imam & Muadzin",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ImamMuadzinPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: menuItem(
                                "relawan.png",
                                "Relawan",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RelawanPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/icon_lay2.png",
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Layanan & Konsultasi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: menuItem(
                          "konsultasi.png",
                          "Konsultasi",
                          onTap: _openKonsultasiPage,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: menuItem(
                          "lokasi.png",
                          "Lokasi Kajian",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KajianListPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: menuItem(
                          "poster_dakwah.png",
                          "Poster Dakwah",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PosterDakwahPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: menuItem(
                          "buku.png",
                          "Tebar Buku",
                          // onTap: _showComingSoonNotification,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TebarBukuPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                image: const DecorationImage(
                  image: AssetImage('assets/images/jadwalbg.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const PrayerInfo(),
            ),
          ],
        ),
      ),
    );
  }
}

Widget menuItem(
  String icon,
  String title, {
  double height = 80,
  VoidCallback? onTap,
}) {
  return _MenuItemBounce(
    icon: icon,
    title: title,
    height: height,
    onTap: onTap,
  );
}

class _MenuItemBounce extends StatefulWidget {
  final String icon;
  final String title;
  final double height;
  final VoidCallback? onTap;

  const _MenuItemBounce({
    required this.icon,
    required this.title,
    required this.height,
    this.onTap,
  });

  @override
  State<_MenuItemBounce> createState() => _MenuItemBounceState();
}

class _MenuItemBounceState extends State<_MenuItemBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut, // efek bounce
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _controller.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) {
        _controller.forward(); // ngecil
      },
      onTapUp: (_) {
        _controller.reverse(); // bounce balik
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/${widget.icon}", width: 35, height: 35),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onTap;

  const _HomeCarousel({
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
    this.onTap,
  });

  int _visibleItemCount(double width) {
    if (width >= 1100) return 4;
    if (width >= 700) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final visibleItemCount = _visibleItemCount(screenWidth);

    final viewportFraction = 1 / visibleItemCount;

    final carouselHeight = visibleItemCount == 1
        ? 120.0
        : visibleItemCount == 2
        ? 130.0
        : 140.0;

    final pageCount = (images.length / visibleItemCount).ceil();
    final activePageIndex = (currentIndex / visibleItemCount).floor();

    final showDots = pageCount > 1;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                onTap?.call(index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: carouselHeight,
            viewportFraction: viewportFraction,
            enableInfiniteScroll: images.length > visibleItemCount,
            autoPlay: images.length > visibleItemCount,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            enlargeCenterPage: false,
            padEnds: false,
            onPageChanged: (index, reason) {
              onPageChanged(index);
            },
          ),
        ),

        if (showDots) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              final isActive = activePageIndex == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color.fromRGBO(24, 100, 80, 1)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
