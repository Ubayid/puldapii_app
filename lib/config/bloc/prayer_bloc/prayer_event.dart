part of 'prayer_bloc.dart';

@immutable
sealed class PrayerEvent {}

final class LoadPrayerSchedule extends PrayerEvent {}

final class RefreshPrayerSchedule extends PrayerEvent {}

final class PrayerTicked extends PrayerEvent {}
