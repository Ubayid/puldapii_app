part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {}

class ProfileImagePicked extends ProfileEvent {}

class ProfilePhotoRemoved extends ProfileEvent {}

class ProfileSubmitted extends ProfileEvent {
  final String name;
  final String email;
  final String phone;

  final bool isUstadz;
  final String? title;
  final String? gender;
  final String? birthPlace;
  final String? birthDate;
  final String? address;
  final String? city;
  final String? mainTheme;
  final String? languages;
  final String? mosqueReference;

  const ProfileSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    this.isUstadz = false,
    this.title,
    this.gender,
    this.birthPlace,
    this.birthDate,
    this.address,
    this.city,
    this.mainTheme,
    this.languages,
    this.mosqueReference,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    isUstadz,
    title,
    gender,
    birthPlace,
    birthDate,
    address,
    city,
    mainTheme,
    languages,
    mosqueReference,
  ];
}
