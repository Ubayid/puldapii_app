part of 'prayer_bloc.dart';

@immutable
sealed class PrayerState {}

final class PrayerInitial extends PrayerState {}

final class PrayerLoading extends PrayerState {
  final String locationName;

  PrayerLoading({this.locationName = 'Memuat lokasi...'});
}

final class PrayerLoaded extends PrayerState {
  final String locationName;
  final Map<String, String> prayerTimes;
  final String currentPrayerName;
  final String currentPrayerTime;
  final int remainingMinutes;

  PrayerLoaded({
    required this.locationName,
    required this.prayerTimes,
    required this.currentPrayerName,
    required this.currentPrayerTime,
    required this.remainingMinutes,
  });

  PrayerLoaded copyWith({
    String? locationName,
    Map<String, String>? prayerTimes,
    String? currentPrayerName,
    String? currentPrayerTime,
    int? remainingMinutes,
  }) {
    return PrayerLoaded(
      locationName: locationName ?? this.locationName,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      currentPrayerName: currentPrayerName ?? this.currentPrayerName,
      currentPrayerTime: currentPrayerTime ?? this.currentPrayerTime,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
    );
  }
}

final class PrayerError extends PrayerState {
  final String message;
  final String locationName;

  PrayerError({
    required this.message,
    this.locationName = 'Gagal mendapatkan lokasi',
  });
}
