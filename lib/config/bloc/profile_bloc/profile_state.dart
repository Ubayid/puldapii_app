part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool removePhoto;
  final Map<String, dynamic>? user;
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final String? profilePhotoUrl;
  final String? errorMessage;
  final String? successMessage;
  final bool isSuccessUpdate;
  final Map<String, dynamic>? updatedUser;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.removePhoto = false,
    this.user,
    this.selectedImageBytes,
    this.selectedImageName,
    this.profilePhotoUrl,
    this.errorMessage,
    this.successMessage,
    this.isSuccessUpdate = false,
    this.updatedUser,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? removePhoto,
    Map<String, dynamic>? user,
    Uint8List? selectedImageBytes,
    String? selectedImageName,
    String? profilePhotoUrl,
    String? errorMessage,
    String? successMessage,
    bool? isSuccessUpdate,
    Map<String, dynamic>? updatedUser,
    bool clearImage = false,
    bool clearMessage = false,
    bool clearUpdatedUser = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      removePhoto: removePhoto ?? this.removePhoto,
      user: user ?? this.user,
      selectedImageBytes: clearImage
          ? null
          : selectedImageBytes ?? this.selectedImageBytes,
      selectedImageName: clearImage
          ? null
          : selectedImageName ?? this.selectedImageName,
      profilePhotoUrl: clearImage
          ? null
          : profilePhotoUrl ?? this.profilePhotoUrl,
      errorMessage: clearMessage ? null : errorMessage,
      successMessage: clearMessage ? null : successMessage,
      isSuccessUpdate: isSuccessUpdate ?? this.isSuccessUpdate,
      updatedUser: clearUpdatedUser ? null : updatedUser ?? this.updatedUser,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    removePhoto,
    user,
    selectedImageBytes,
    selectedImageName,
    profilePhotoUrl,
    errorMessage,
    successMessage,
    isSuccessUpdate,
    updatedUser,
  ];
}
