import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puldapii/utils/services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  final ImagePicker imagePicker;

  ProfileBloc({required this.profileService, required this.imagePicker})
    : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileImagePicked>(_onImagePicked);
    on<ProfilePhotoRemoved>(_onPhotoRemoved);
    on<ProfileSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearMessage: true,
        isSuccessUpdate: false,
        clearUpdatedUser: true,
      ),
    );

    try {
      final response = await profileService.getProfile();

      final data = response['data'];

      if (data is! Map) {
        throw Exception('Data profile tidak valid');
      }

      final user = Map<String, dynamic>.from(data);

      final bool isUstadz = user['type']?.toString() == 'ustadz';

      String? photoUrl;

      if (isUstadz) {
        final ustadz = user['ustadz'] is Map
            ? Map<String, dynamic>.from(user['ustadz'])
            : null;

        photoUrl = ustadz?['image_url']?.toString();
      } else {
        photoUrl = user['profile_photo_url']?.toString();
      }

      emit(
        state.copyWith(
          isLoading: false,
          user: user,
          profilePhotoUrl: photoUrl,
          removePhoto: false,
          clearImage: true,
          clearMessage: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _cleanError(e)));
    }
  }

  Future<void> _onImagePicked(
    ProfileImagePicked event,
    Emitter<ProfileState> emit,
  ) async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 55,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    final sizeInMb = bytes.length / (1024 * 1024);

    if (sizeInMb > 1.5) {
      emit(
        state.copyWith(
          errorMessage: 'Ukuran foto terlalu besar. Maksimal 1.5MB.',
          clearMessage: false,
        ),
      );
      return;
    }

    String fileName = pickedFile.name.toLowerCase();

    if (!fileName.endsWith('.jpg') &&
        !fileName.endsWith('.jpeg') &&
        !fileName.endsWith('.png')) {
      fileName = 'profile_photo.jpg';
    }

    emit(
      state.copyWith(
        selectedImageBytes: bytes,
        selectedImageName: fileName,
        removePhoto: false,
        clearMessage: true,
      ),
    );
  }

  void _onPhotoRemoved(ProfilePhotoRemoved event, Emitter<ProfileState> emit) {
    emit(
      state.copyWith(removePhoto: true, clearImage: true, clearMessage: true),
    );
  }

  Future<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    final name = event.name.trim();
    final email = event.email.trim();
    final phone = event.phone.trim();

    if (name.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Nama tidak boleh kosong',
          clearMessage: false,
        ),
      );
      return;
    }

    if (email.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Email tidak boleh kosong',
          clearMessage: false,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      emit(
        state.copyWith(errorMessage: 'Email tidak valid', clearMessage: false),
      );
      return;
    }

    emit(
      state.copyWith(
        isSaving: true,
        clearMessage: true,
        isSuccessUpdate: false,
        clearUpdatedUser: true,
      ),
    );

    try {
      final response = await profileService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        profilePhotoBytes: state.selectedImageBytes,
        profilePhotoFileName: state.selectedImageName,
        removeProfilePhoto: state.removePhoto,
        isUstadz: event.isUstadz,
        title: event.title,
        gender: event.gender,
        birthPlace: event.birthPlace,
        birthDate: event.birthDate,
        address: event.address,
        city: event.city,
        mainTheme: event.mainTheme,
        languages: event.languages,
        mosqueReference: event.mosqueReference,
      );

      final data = response['data'];

      final updatedUser = data is Map
          ? Map<String, dynamic>.from(data)
          : Map<String, dynamic>.from(response);

      String? photoUrl;

      if (updatedUser['type']?.toString() == 'ustadz') {
        final ustadz = updatedUser['ustadz'] is Map
            ? Map<String, dynamic>.from(updatedUser['ustadz'])
            : null;

        photoUrl = ustadz?['image_url']?.toString();
      } else {
        photoUrl = updatedUser['profile_photo_url']?.toString();
      }

      emit(
        state.copyWith(
          isSaving: false,
          successMessage:
              response['message']?.toString() ?? 'Profile berhasil diperbarui',
          isSuccessUpdate: true,
          updatedUser: updatedUser,
          user: updatedUser,
          profilePhotoUrl: photoUrl,
          removePhoto: false,
          clearImage: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: _cleanError(e)));
    }
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
