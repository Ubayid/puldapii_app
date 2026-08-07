import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/prayer_bloc/prayer_bloc.dart';

class PrayerInfo extends StatelessWidget {
  const PrayerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jadwal Sholat",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(32, 86, 91, 1),
              ),
            ),
            Row(
              children: [
                if (state is PrayerInitial || state is PrayerLoading)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Memuat data...",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(32, 86, 91, 1),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(22, 23, 23, 1),
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  )
                else if (state is PrayerLoaded)
                  Row(
                    children: [
                      Text(
                        "${state.currentPrayerName} ${state.currentPrayerTime}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(32, 86, 91, 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        PrayerBloc.formatRemainingTime(state.remainingMinutes),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(24, 100, 80, 1),
                        ),
                      ),
                    ],
                  )
                else if (state is PrayerError)
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color.fromRGBO(251, 205, 76, 1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state is PrayerLoaded
                          ? state.locationName
                          : state is PrayerError
                          ? "Gagal mendapatkan lokasi"
                          : "Memuat lokasi...",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(24, 100, 80, 1),
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      context.read<PrayerBloc>().add(RefreshPrayerSchedule());
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.autorenew_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
