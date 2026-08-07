import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puldapii/config/api_client.dart';

import 'package:puldapii/config/bloc/account_bloc/account_bloc.dart';
import 'package:puldapii/config/bloc/auth_bloc/auth_bloc.dart';
import 'package:puldapii/config/bloc/book_bloc/book_bloc.dart';
import 'package:puldapii/config/bloc/book_recipient_bloc/book_recipient_bloc.dart';
import 'package:puldapii/config/bloc/consultation_bloc/consultation_bloc.dart';
import 'package:puldapii/config/bloc/hadist_bloc/hadist_bloc.dart';
import 'package:puldapii/config/bloc/kajian_bloc/kajian_bloc.dart';
import 'package:puldapii/config/bloc/poster_template/poster_template_bloc.dart';
import 'package:puldapii/config/bloc/prayer_bloc/prayer_bloc.dart';
import 'package:puldapii/config/bloc/quran_mushaf/quran_mushaf_bloc.dart';
import 'package:puldapii/config/bloc/quran_mushaf_image_bloc/quran_mushaf_image_bloc.dart';
import 'package:puldapii/config/bloc/ustadz_bloc/ustadz_bloc.dart';

import 'package:puldapii/config/cubit/institution_cubit/institution_cubit.dart';
import 'package:puldapii/config/cubit/new_cubit/new_cubit.dart';
import 'package:puldapii/config/cubit/notification_cubit/notification_cubit.dart';

import 'package:puldapii/firebase_options.dart';

import 'package:puldapii/pages/article/article_list.dart';
import 'package:puldapii/pages/home/home.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_distribution_page.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_detail_page.dart';
import 'package:puldapii/pages/home/pages/layanan/dakwah/kajian_list.dart';
import 'package:puldapii/pages/home/pages/layanan/poster/poster_list_page.dart';
import 'package:puldapii/pages/institute/institute_main_page.dart';
import 'package:puldapii/pages/news/news_index.dart';
import 'package:puldapii/pages/product/product.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:puldapii/utils/services/auth_service.dart';
import 'package:puldapii/utils/services/firebase_notification_service.dart';
import 'package:puldapii/utils/services/home/book_service.dart';
import 'package:puldapii/utils/services/home/consultation_service.dart';
import 'package:puldapii/utils/services/home/dakwah_service.dart';
import 'package:puldapii/utils/services/home/expertise_service.dart';
import 'package:puldapii/utils/services/home/hadist_service.dart';
import 'package:puldapii/utils/services/home/poster_template_service.dart';
import 'package:puldapii/utils/services/home/prayer_background_service.dart';
import 'package:puldapii/utils/services/home/quran_mushaf_service.dart';
import 'package:puldapii/utils/services/home/ustadz_service.dart';
import 'package:puldapii/utils/services/institute/institution_service.dart';
import 'package:puldapii/utils/services/new/new_service.dart';
import 'package:puldapii/utils/services/notification_service.dart';
import 'package:puldapii/utils/services/notification_topic_service.dart';
import 'package:puldapii/utils/services/profile_service.dart';

import 'package:puldapii/utils/widget/widget_no_internet_exit.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseNotificationService.initializeLocalNotifications();

  final type = message.data['type']?.toString();

  if (type == 'dakwah_ongoing') {
    await FirebaseNotificationService.showOngoingDakwahNotification(
      message.data,
    );
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Jangan menunggu inisialisasi notifikasi salat,
  // timezone, topic, dan permission sebelum runApp().
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              UstadzBloc(UstadzService(), roleSlugs: [])
                ..add(FetchUstadzList()),
        ),
        BlocProvider(
          create: (_) => KajianBloc(DakwahService())..add(FetchKajianData()),
        ),
        BlocProvider(create: (_) => PrayerBloc()),
        BlocProvider(
          create: (_) =>
              HadistBloc(HadistService(Dio()))..add(FetchHadistBooks()),
        ),
        BlocProvider(create: (_) => QuranMushafBloc(QuranMushafService(Dio()))),
        BlocProvider(
          create: (_) => QuranMushafImageBloc(QuranMushafService(Dio())),
        ),
        BlocProvider(
          create: (_) => AccountBloc(
            authService: AuthService(),
            profileService: ProfileService(),
          )..add(AccountStarted()),
        ),
        BlocProvider(create: (_) => AuthBloc(authService: AuthService())),
        BlocProvider(
          create: (_) => ConsultationBloc(
            profileService: ProfileService(),
            expertiseService: ExpertiseService(ApiClient.dio),
            consultationService: ConsultationService(ApiClient.dio),
          ),
        ),
        BlocProvider(
          create: (_) =>
              NotificationCubit(NotificationService())..loadUnreadCount(),
        ),
        BlocProvider(
          create: (_) =>
              PosterTemplateBloc(PosterTemplateService())
                ..add(FetchPosterTemplateHomeData()),
        ),
        BlocProvider(create: (_) => BookBloc(BookService())),
        BlocProvider(create: (_) => BookRecipientBloc()),
        BlocProvider(
          create: (_) =>
              InstitutionCubit(InstitutionService())..fetchInstitutions(),
        ),
        BlocProvider(
          create: (_) => NewsCubit(newsService: NewsService())..fetchNews(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      builder: (context, child) {
        return NoInternetExitGuard(
          navigatorKey: rootNavigatorKey,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static _MainPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainPageState>();
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _accessInitializationStarted = false;

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  Future<void> _initializeAccessAfterAppOpened() async {
    if (_accessInitializationStarted) return;

    _accessInitializationStarted = true;

    try {
      await initializeDateFormatting('id_ID', null);

      await FirebaseNotificationService.initializeLocalNotifications();

      await FirebaseNotificationService.init();

      await NotificationTopicService.initializeTopics();
    } catch (error, stackTrace) {
      debugPrint('Inisialisasi Firebase gagal: $error');

      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) return;

    try {
      // Workmanager harus aktif terlebih dahulu.
      await PrayerBackgroundService.initialize();

      if (!mounted) return;

      // Setelah itu ambil lokasi dan jadwalkan 30 hari.
      context.read<PrayerBloc>().add(LoadPrayerSchedule());
    } catch (error, stackTrace) {
      debugPrint('Inisialisasi jadwal sholat gagal: $error');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseNotificationService.setNotificationTapHandler(
      _handleLocalNotificationClick,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (!mounted) return;

      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }

      Future<void>.delayed(const Duration(milliseconds: 1200), () async {
        if (!mounted) return;

        await _initializeAccessAfterAppOpened();
      });
    });
  }

  @override
  void dispose() {
    FirebaseNotificationService.removeNotificationTapHandler();

    super.dispose();
  }

  void _handleLocalNotificationClick(Map<String, dynamic> data) {
    final type = data['type']?.toString();

    final rawId = data['consultation_id'] ?? data['dakwah_id'] ?? data['id'];

    final id = int.tryParse(rawId?.toString() ?? '');

    debugPrint('LOCAL NOTIF DIKLIK');
    debugPrint('type: $type');
    debugPrint('id: $id');

    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Widget? page;

      if (type == 'poster_dakwah') {
        page = const PosterDakwahPage();
      } else if (type == 'tebar_buku') {
        page = const TebarBukuPage();
      } else if (type == 'kajian' || type == 'dakwah_ongoing') {
        page = const KajianListPage();
      } else if (type == 'consultation_answered') {
        if (id == null) {
          return;
        }

        page = ConsultDetailPage(consultationId: id);
      }

      if (page == null) {
        return;
      }

      final navigator = _navKey.currentState;

      if (navigator == null) {
        debugPrint('Nested navigator belum siap.');

        return;
      }

      navigator.push(MaterialPageRoute(builder: (_) => page!));
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    final type = message.data['type']?.toString();

    final rawId =
        message.data['consultation_id'] ??
        message.data['dakwah_id'] ??
        message.data['id'];

    final id = int.tryParse(rawId?.toString() ?? '');

    debugPrint('NOTIF DIKLIK');
    debugPrint('type: $type');
    debugPrint('rawId: $rawId');
    debugPrint('id: $id');

    if (!mounted) return;

    Widget? page;

    if (type == 'poster_dakwah') {
      page = const PosterDakwahPage();
    } else if (type == 'tebar_buku') {
      page = const TebarBukuPage();
    } else if (type == 'kajian' || type == 'dakwah_ongoing') {
      page = const KajianListPage();
    } else if (type == 'consultation_answered') {
      if (id == null) {
        debugPrint('ID konsultasi kosong atau tidak valid.');

        return;
      }

      page = ConsultDetailPage(consultationId: id);
    }

    if (page == null) {
      debugPrint('Tidak ada halaman untuk type: $type');

      return;
    }

    _navKey.currentState?.push(MaterialPageRoute(builder: (_) => page!));
  }

  Widget _rootPageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomePage();

      case 1:
        return const ArticleList();

      case 2:
        return const NewsPage();

      case 3:
        return const ProductPage();

      case 4:
        return const InstituteMainPage();

      default:
        return const HomePage();
    }
  }

  Future<void> _refreshCurrentPage() async {
    if (!mounted) return;

    switch (_currentIndex) {
      case 0:
        // Refresh Home
        context.read<UstadzBloc>().add(FetchUstadzList());

        context.read<KajianBloc>().add(FetchKajianData());

        context.read<PrayerBloc>().add(LoadPrayerSchedule());

        context.read<PosterTemplateBloc>().add(FetchPosterTemplateHomeData());

        context.read<BookBloc>().add(FetchBookCategories());

        context.read<BookBloc>().add(FetchFeaturedBooks());

        context.read<NotificationCubit>().loadUnreadCount();

        await context.read<InstitutionCubit>().fetchInstitutions();

        break;

      case 1:
        // Refresh Artikel
        _rebuildCurrentRootPage();
        break;

      case 2:
        // Refresh Berita
        await context.read<NewsCubit>().refreshNews();
        break;

      case 3:
        // Refresh Produk
        _rebuildCurrentRootPage();
        break;

      case 4:
        // Refresh Lembaga
        await context.read<InstitutionCubit>().fetchInstitutions();

        break;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _rebuildCurrentRootPage() {
    _navKey.currentState?.pushAndRemoveUntil(
      _noAnimRoute(_rootPageForIndex(_currentIndex)),
      (route) => false,
    );
  }

  void switchTabNoAnim(int index) {
    if (index == _currentIndex) {
      _navKey.currentState?.popUntil((route) => route.isFirst);

      return;
    }

    setState(() {
      _currentIndex = index;
    });

    _navKey.currentState?.pushAndRemoveUntil(
      _noAnimRoute(_rootPageForIndex(index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final navigator = _navKey.currentState;

        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }

        if (_currentIndex != 0) {
          switchTabNoAnim(0);
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: RefreshIndicator(
          color: const Color.fromRGBO(24, 100, 80, 1),
          onRefresh: _refreshCurrentPage,
          child: Navigator(
            key: _navKey,
            onGenerateRoute: (_) {
              return MaterialPageRoute(
                builder: (_) {
                  return _rootPageForIndex(_currentIndex);
                },
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: switchTabNoAnim,
          selectedItemColor: const Color.fromRGBO(251, 205, 76, 1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: 'Artikel',
            ),

            // NAVIGASI BERITA SETELAH ARTIKEL
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_rounded),
              label: 'Berita',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment_rounded),
              label: 'Lembaga',
            ),
          ],
        ),
      ),
    );
  }
}

Route<T> _noAnimRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
