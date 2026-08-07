import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/prayer_bloc/prayer_bloc.dart';
import 'package:puldapii/utils/services/home/prayer_notification_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

const kPrimaryTeal = Color.fromRGBO(90, 178, 173, 1);

class PrayerSchedulePage extends StatelessWidget {
  const PrayerSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrayerBloc()..add(LoadPrayerSchedule()),
      child: const _PrayerScheduleView(),
    );
  }
}

class _PrayerScheduleView extends StatelessWidget {
  const _PrayerScheduleView();

  static const List<Map<String, String>> prayerOrder = [
    {'name': 'Subuh', 'key': 'Fajr', 'icon': 'wb_twilight'},
    {'name': 'Dzuhur', 'key': 'Dhuhr', 'icon': 'light_mode'},
    {'name': 'Asar', 'key': 'Asr', 'icon': 'partly_cloudy_day'},
    {'name': 'Maghrib', 'key': 'Maghrib', 'icon': 'nightlight_round'},
    {'name': 'Isya', 'key': 'Isha', 'icon': 'dark_mode'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SecondaryHeader(
            title: 'Jadwal Sholat',
            actions: [
              IconButton(
                onPressed: () {
                  context.read<PrayerBloc>().add(RefreshPrayerSchedule());
                },
                icon: const Icon(Icons.autorenew_rounded),
              ),
              IconButton(
                tooltip: 'Tes notifikasi',
                onPressed: () async {
                  final allowed =
                      await PrayerNotificationService.requestPermission();

                  if (!allowed) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Izin notifikasi belum diberikan.'),
                      ),
                    );

                    return;
                  }

                  await PrayerNotificationService.showScheduledTestNotification();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tes dijadwalkan. Tunggu sekitar 1–5 menit.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
              ),
            ],
          ),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state is PrayerInitial || state is PrayerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimaryTeal),
                    );
                  }

                  if (state is PrayerError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _SectionCard(
                          title: 'Gagal Memuat',
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              state.message,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<PrayerBloc>().add(
                                    RefreshPrayerSchedule(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryTeal,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is PrayerLoaded) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _NextPrayerCard(state: state),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Jadwal Hari Ini',
                          children: prayerOrder.map((item) {
                            final name = item['name']!;
                            final key = item['key']!;
                            final time =
                                state.prayerTimes[key]?.split(' ').first ??
                                '--:--';
                            final isActive = state.currentPrayerName == name;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PrayerRowCard(
                                name: name,
                                time: time,
                                isActive: isActive,
                                icon: _mapIcon(item['icon']!),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _mapIcon(String key) {
    switch (key) {
      case 'wb_twilight':
        return Icons.wb_twilight_outlined;
      case 'light_mode':
        return Icons.light_mode_outlined;
      case 'partly_cloudy_day':
        return Icons.wb_sunny_outlined;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'dark_mode':
        return Icons.dark_mode_outlined;
      default:
        return Icons.access_time_rounded;
    }
  }
}

class _NextPrayerCard extends StatelessWidget {
  final PrayerLoaded state;

  const _NextPrayerCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Sholat Berikutnya',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: kPrimaryTeal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: kPrimaryTeal,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.currentPrayerName} ${state.currentPrayerTime}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color.fromRGBO(32, 86, 91, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PrayerBloc.formatRemainingTime(state.remainingMinutes),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(24, 100, 80, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color.fromRGBO(251, 205, 76, 1),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          state.locationName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(24, 100, 80, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrayerRowCard extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;
  final IconData icon;

  const _PrayerRowCard({
    required this.name,
    required this.time,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? kPrimaryTeal.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? kPrimaryTeal
              : Theme.of(context).dividerColor.withOpacity(0.8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? kPrimaryTeal.withOpacity(0.14)
                  : Colors.grey.withOpacity(0.08),
            ),
            child: Icon(icon, size: 18, color: kPrimaryTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: const Color.fromRGBO(32, 86, 91, 1),
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? kPrimaryTeal : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SectionCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final hasTitle = (title ?? '').trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}
