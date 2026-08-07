import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/config/bloc/consultation_bloc/consultation_bloc.dart';
import 'package:puldapii/utils/services/home/consultation_service.dart';
import 'package:puldapii/utils/services/home/expertise_service.dart';
import 'package:puldapii/utils/services/profile_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class ConsultForm extends StatelessWidget {
  const ConsultForm({super.key});

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color yellowColor = Color.fromRGBO(251, 205, 76, 1);

  @override
  Widget build(BuildContext context) {
    final dio = ApiClient.dio;

    return BlocProvider(
      create: (_) => ConsultationBloc(
        profileService: ProfileService(),
        expertiseService: ExpertiseService(dio),
        consultationService: ConsultationService(dio),
      )..add(const ConsultationStarted()),
      child: const Scaffold(
        backgroundColor: Color(0xFFF7F8F4),
        appBar: SecondaryHeader(
          title: 'Ajukan Konsultasi',
          centerTitle: true,
          elevation: 0,
        ),
        body: GradientPage(child: _ConsultFormView()),
      ),
    );
  }
}

class _ConsultFormView extends StatefulWidget {
  const _ConsultFormView();

  @override
  State<_ConsultFormView> createState() => _ConsultFormViewState();
}

class _ConsultFormViewState extends State<_ConsultFormView> {
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color yellowColor = Color.fromRGBO(251, 205, 76, 1);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _pesanController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _judulController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _submitKonsultasi(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<ConsultationBloc>().add(
      ConsultationSubmitted(
        title: _judulController.text.trim(),
        question: _pesanController.text.trim(),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
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
    return BlocConsumer<ConsultationBloc, ConsultationState>(
      listener: (context, state) {
        _namaController.text = state.name;
        _phoneController.text = state.phone;

        if (state.status == ConsultationStatus.success) {
          _showSnackBar(
            context,
            state.message ?? 'Konsultasi berhasil dikirim',
          );

          _judulController.clear();
          _pesanController.clear();
        }

        if (state.status == ConsultationStatus.failure &&
            state.message != null) {
          _showSnackBar(context, state.message!, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ConsultationStatus.loading;
        final isSaving = state.status == ConsultationStatus.submitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _FormCard(
                  children: [
                    _ConsultTextField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      hintText: isLoading
                          ? 'Mengambil nama...'
                          : 'Nama dari profile',
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama profile belum tersedia';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _ConsultTextField(
                      controller: _phoneController,
                      label: 'Nomor WhatsApp',
                      hintText: isLoading
                          ? 'Mengambil nomor WhatsApp...'
                          : 'Silahkan isi di profil',
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor WhatsApp profile belum tersedia';
                        }

                        if (value.trim().length < 10) {
                          return 'Nomor WhatsApp tidak valid';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _ConsultDropdownField(
                      label: 'Kategori Konsultasi',
                      hintText: isLoading
                          ? 'Mengambil kategori...'
                          : 'Pilih kategori konsultasi',
                      value: state.selectedExpertiseId,
                      items: state.expertises,
                      onChanged: isLoading || isSaving
                          ? null
                          : (value) {
                              context.read<ConsultationBloc>().add(
                                ConsultationExpertiseChanged(value),
                              );
                            },
                    ),

                    const SizedBox(height: 14),

                    _ConsultTextField(
                      controller: _judulController,
                      label: 'Judul Konsultasi',
                      hintText: 'Masukkan judul konsultasi',
                      readOnly: isSaving,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _ConsultTextField(
                      controller: _pesanController,
                      label: 'Isi Konsultasi',
                      hintText: 'Tuliskan isi konsultasi',
                      maxLines: 5,
                      readOnly: isSaving,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Isi konsultasi tidak boleh kosong';
                        }

                        if (value.trim().length < 10) {
                          return 'Isi konsultasi terlalu pendek';
                        }

                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () => _submitKonsultasi(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      foregroundColor: primaryColor,
                      disabledBackgroundColor: yellowColor.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: primaryColor,
                            ),
                          )
                        : const Text(
                            'Kirim Konsultasi',
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

class _ConsultTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final String? Function(String?)? validator;

  const _ConsultTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.validator,
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
          maxLines: maxLines,
          validator: validator,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
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

class _ConsultDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final int? value;
  final List<Map<String, dynamic>> items;
  final ValueChanged<int?>? onChanged;

  const _ConsultDropdownField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
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
        DropdownButtonFormField<int>(
          value: value,
          items: items.map((item) {
            final id = item['id'];
            final expertiseId = id is int ? id : int.tryParse(id.toString());
            final name = item['name']?.toString() ?? '-';

            return DropdownMenuItem<int>(value: expertiseId, child: Text(name));
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Kategori tidak boleh kosong';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
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
