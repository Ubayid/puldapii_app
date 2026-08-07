import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/account_bloc/account_bloc.dart';
import 'package:puldapii/config/bloc/profile_bloc/profile_bloc.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  static const Color primaryColor = Colors.teal;
  static const Color yellowColor = Color.fromRGBO(251, 205, 76, 1);

  final _formKey = GlobalKey<FormState>();

  // user
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // ustadz
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mainThemeController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _mosqueReferenceController =
      TextEditingController();

  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    _titleController.dispose();
    _genderController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _mainThemeController.dispose();
    _languagesController.dispose();
    _mosqueReferenceController.dispose();

    super.dispose();
  }

  void _fillForm(ProfileState state) {
    if (_isFormFilled) return;

    final data = state.user;
    if (data == null) return;

    final type = data['type']?.toString();
    final isUstadz = type == 'ustadz';

    if (isUstadz) {
      final user = data['user'] as Map<String, dynamic>?;
      final ustadz = data['ustadz'] as Map<String, dynamic>?;

      _nameController.text = user?['name']?.toString() ?? '';
      _emailController.text = user?['email']?.toString() ?? '';
      _phoneController.text =
          user?['phone']?.toString() ??
          ustadz?['contact_number']?.toString() ??
          '';

      _titleController.text = ustadz?['title']?.toString() ?? '';
      _genderController.text = ustadz?['gender']?.toString() ?? '';
      _birthPlaceController.text = ustadz?['birth_place']?.toString() ?? '';
      _birthDateController.text = ustadz?['birth_date']?.toString() ?? '';
      _addressController.text = ustadz?['address']?.toString() ?? '';
      _cityController.text = ustadz?['city']?.toString() ?? '';
      _mainThemeController.text = ustadz?['main_theme']?.toString() ?? '';
      _languagesController.text = ustadz?['languages']?.toString() ?? '';
      _mosqueReferenceController.text =
          ustadz?['mosque_reference']?.toString() ?? '';
    } else {
      _nameController.text = data['name']?.toString() ?? '';
      _emailController.text = data['email']?.toString() ?? '';
      _phoneController.text = data['phone']?.toString() ?? '';
    }

    _isFormFilled = true;
  }

  bool _isUstadz(ProfileState state) {
    final data = state.user;
    if (data == null) return false;

    return data['type']?.toString() == 'ustadz' ||
        data['role']?.toString() == 'ustadz';
  }

  ImageProvider? _getProfileImage(ProfileState state) {
    if (state.selectedImageBytes != null) {
      return MemoryImage(state.selectedImageBytes!);
    }

    final data = state.user;
    String? imageUrl;

    if (data?['type'] == 'ustadz') {
      final ustadz = data?['ustadz'] as Map<String, dynamic>?;
      imageUrl = ustadz?['image_url']?.toString();
    } else {
      imageUrl = state.profilePhotoUrl;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    }

    return null;
  }

  void _saveProfile(ProfileState state) {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final isUstadz = _isUstadz(state);

    context.read<ProfileBloc>().add(
      ProfileSubmitted(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),

        // khusus ustadz
        isUstadz: isUstadz,
        title: _titleController.text.trim(),
        gender: _genderController.text.trim(),
        birthPlace: _birthPlaceController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        mainTheme: _mainThemeController.text.trim(),
        languages: _languagesController.text.trim(),
        mosqueReference: _mosqueReferenceController.text.trim(),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F4),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        title: const Text(
          'Ubah Profile',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          _fillForm(state);

          if (state.errorMessage != null) {
            _showSnackBar(state.errorMessage!, isError: true);
          }

          if (state.successMessage != null) {
            _showSnackBar(state.successMessage!);
          }

          if (state.isSuccessUpdate) {
            final updatedUser = state.updatedUser;

            debugPrint('UPDATED USER FROM PROFILE PAGE: $updatedUser');

            if (updatedUser != null) {
              context.read<AccountBloc>().add(
                AccountProfileUpdated(updatedUser),
              );
            }

            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final isUstadz = _isUstadz(state);
          final profileImage = _getProfileImage(state);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _ProfilePhotoCard(
                    imageProvider: profileImage,
                    title: isUstadz ? 'Foto Ustadz' : 'Foto Profile',
                    subtitle: isUstadz
                        ? 'Foto ini akan tampil di profile ustadz'
                        : 'Pilih foto terbaik untuk akun kamu',
                    onPickImage: () {
                      context.read<ProfileBloc>().add(ProfileImagePicked());
                    },
                    onRemoveImage: () {
                      context.read<ProfileBloc>().add(ProfilePhotoRemoved());
                    },
                  ),

                  const SizedBox(height: 18),

                  _SectionTitle(title: isUstadz ? 'Data Akun' : 'Data Profile'),

                  const SizedBox(height: 10),

                  _FormCard(
                    children: [
                      _ProfileTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      _ProfileTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Masukkan email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }

                          if (!value.contains('@')) {
                            return 'Email tidak valid';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      _ProfileTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        hintText: 'Masukkan nomor telepon',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  if (isUstadz) ...[
                    const SizedBox(height: 18),

                    const _SectionTitle(title: 'Data Ustadz'),

                    const SizedBox(height: 10),

                    _FormCard(
                      children: [
                        _ProfileTextField(
                          controller: _titleController,
                          label: 'Gelar / Sapaan',
                          hintText: 'Contoh: Ustadz, KH, Dr.',
                          icon: Icons.badge_outlined,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _genderController,
                          label: 'Jenis Kelamin',
                          hintText: 'Laki-laki / Perempuan',
                          icon: Icons.wc_rounded,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _birthPlaceController,
                          label: 'Tempat Lahir',
                          hintText: 'Masukkan tempat lahir',
                          icon: Icons.location_city_outlined,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _birthDateController,
                          label: 'Tanggal Lahir',
                          hintText: 'YYYY-MM-DD',
                          icon: Icons.calendar_month_outlined,
                          keyboardType: TextInputType.datetime,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _cityController,
                          label: 'Kota',
                          hintText: 'Masukkan kota domisili',
                          icon: Icons.location_on_outlined,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _addressController,
                          label: 'Alamat',
                          hintText: 'Masukkan alamat',
                          icon: Icons.home_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const _SectionTitle(title: 'Keahlian Dakwah'),

                    const SizedBox(height: 10),

                    _FormCard(
                      children: [
                        _ProfileTextField(
                          controller: _mainThemeController,
                          label: 'Tema Utama',
                          hintText: 'Contoh: Fiqih, Aqidah, Keluarga',
                          icon: Icons.menu_book_outlined,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _languagesController,
                          label: 'Bahasa',
                          hintText: 'Contoh: Indonesia, Sunda, Arab',
                          icon: Icons.translate_outlined,
                        ),

                        const SizedBox(height: 14),

                        _ProfileTextField(
                          controller: _mosqueReferenceController,
                          label: 'Referensi Masjid',
                          hintText: 'Masukkan referensi masjid',
                          icon: Icons.mosque_outlined,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.isSaving
                          ? null
                          : () => _saveProfile(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellowColor,
                        foregroundColor: primaryColor,
                        disabledBackgroundColor: yellowColor.withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: primaryColor,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: state.isSaving
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B1B1B),
          ),
        ),
      ],
    );
  }
}

class _ProfilePhotoCard extends StatelessWidget {
  final ImageProvider? imageProvider;
  final String title;
  final String subtitle;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _ProfilePhotoCard({
    required this.imageProvider,
    required this.title,
    required this.subtitle,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color yellowColor = Color.fromRGBO(251, 205, 76, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.teal.withOpacity(0.12),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 54,
                        color: Colors.teal,
                      )
                    : null,
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: yellowColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1B),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Pilih Foto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemoveImage,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.45)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B1B1B),
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.teal),
            filled: true,
            fillColor: const Color(0xFFF8F9F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryColor, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
