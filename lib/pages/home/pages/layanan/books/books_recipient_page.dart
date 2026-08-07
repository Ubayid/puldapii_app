import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:puldapii/config/bloc/book_recipient_bloc/book_recipient_bloc.dart';
import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class BookRecipientPage extends StatefulWidget {
  final String token;
  final List<BookModel> books;
  final BookModel? initialBook;

  const BookRecipientPage({
    super.key,
    required this.token,
    required this.books,
    this.initialBook,
  });

  @override
  State<BookRecipientPage> createState() => _BookRecipientPageState();
}

class _BookRecipientPageState extends State<BookRecipientPage> {
  static const Color primaryColor = Color.fromRGBO(22, 184, 172, 1);
  static const Color darkGreen = Color.fromRGBO(0, 82, 87, 1);
  static const Color yellowColor = Color.fromRGBO(255, 188, 24, 1);

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _responsibleNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _requestedQuantityController = TextEditingController();
  final _peopleCountController = TextEditingController();
  final _reasonController = TextEditingController();

  late final List<BookModel> _bookOptions;

  int? _selectedBookId;
  String? _selectedInstitutionType;
  File? _selectedImage;
  bool _isConfirmed = false;

  final List<String> _institutionTypes = const [
    'Masjid',
    'Pesantren',
    'Sekolah',
    'TPA / TPQ',
    'Majelis Taklim',
    'Komunitas',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    _bookOptions = List<BookModel>.from(widget.books);

    if (widget.initialBook != null &&
        !_bookOptions.any((book) => book.id == widget.initialBook!.id)) {
      _bookOptions.insert(0, widget.initialBook!);
    }

    _selectedBookId =
        widget.initialBook?.id ??
        (_bookOptions.isNotEmpty ? _bookOptions.first.id : null);

    _selectedInstitutionType = 'Masjid';
  }

  @override
  void dispose() {
    _cityController.dispose();
    _provinceController.dispose();
    _institutionNameController.dispose();
    _responsibleNameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _requestedQuantityController.dispose();
    _peopleCountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }

  int? _parseNullableInt(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_isConfirmed) {
      _showSnackBar('Konfirmasi data wajib dicentang.');
      return;
    }

    if (_selectedBookId == null) {
      _showSnackBar('Buku wajib dipilih.');
      return;
    }

    context.read<BookRecipientBloc>().add(
      SubmitBookRecipient(
        token: widget.token,
        bookId: _selectedBookId!,
        institutionName: _institutionNameController.text.trim(),
        responsibleName: _responsibleNameController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        institutionType: _selectedInstitutionType!,
        requestedQuantity: int.parse(_requestedQuantityController.text.trim()),
        peopleCount: _parseNullableInt(_peopleCountController.text),
        reason: _reasonController.text.trim(),
        institutionPhoto: _selectedImage,
        isConfirmed: _isConfirmed,
      ),
    );
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? primaryColor : Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookRecipientBloc, BookRecipientState>(
      listener: (context, state) {
        if (state is BookRecipientSuccess) {
          _showSnackBar(state.message, success: true);

          Navigator.of(context).pop();
        }

        if (state is BookRecipientError) {
          _showSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is BookRecipientLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8F4),
          body: Column(
            children: [
              const SecondaryHeader(title: "Pengajuan Buku"),

              Expanded(
                child: GradientPage(
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pengajuan Buku',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildInfoBanner(),
                          const SizedBox(height: 16),
                          _buildFormCard(),
                          const SizedBox(height: 16),
                          _buildSubmitButton(isLoading),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 252, 244, 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(255, 232, 172, 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: yellowColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Text(
              'Ajukan buku untuk masjid, pesantren,\nsekolah, dan komunitas.',
              style: TextStyle(
                color: Color.fromRGBO(42, 48, 59, 1),
                fontSize: 15.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _fieldLine(
              label: 'Nama lembaga / penerima',
              child: _textInput(
                controller: _institutionNameController,
                hintText: 'Masjid Nurul Hidayah',
                validatorText: 'Nama lembaga wajib diisi.',
              ),
            ),

            _fieldLine(
              label: 'Nama penanggung jawab',
              child: _textInput(
                controller: _responsibleNameController,
                hintText: 'Ahmad Faizal',
                validatorText: 'Nama penanggung jawab wajib diisi.',
              ),
            ),

            _fieldLine(
              label: 'No. WhatsApp',
              child: _textInput(
                controller: _whatsappController,
                hintText: '0812 3456 7890',
                keyboardType: TextInputType.phone,
                validatorText: 'Nomor WhatsApp wajib diisi.',
              ),
            ),

            _fieldLine(
              label: 'Alamat lengkap',
              child: _textInput(
                controller: _addressController,
                hintText:
                    'Jl. Melati No. 10, Kel. Gilingan, Kec. Banjarsari, Kota Surakarta, Jawa Tengah',
                maxLines: 3,
                validatorText: 'Alamat lengkap wajib diisi.',
              ),
            ),

            _fieldLine(
              label: 'Kota / Kabupaten',
              child: _textInput(
                controller: _cityController,
                hintText: 'Kota Surakarta',
                validatorText: 'Kota wajib diisi.',
              ),
            ),

            _fieldLine(
              label: 'Provinsi',
              child: _textInput(
                controller: _provinceController,
                hintText: 'Jawa Tengah',
                validatorText: 'Provinsi wajib diisi.',
              ),
            ),

            _fieldLine(
              label: 'Jenis lembaga',
              child: _dropdown<String>(
                value: _selectedInstitutionType,
                hintText: 'Pilih jenis lembaga',
                items: _institutionTypes,
                onChanged: (value) {
                  setState(() => _selectedInstitutionType = value);
                },
                validatorText: 'Jenis lembaga wajib dipilih.',
              ),
            ),

            _fieldLine(label: 'Buku yang diajukan', child: _bookDropdown()),

            _fieldLine(
              label: 'Jumlah buku',
              child: _textInput(
                controller: _requestedQuantityController,
                hintText: '100',
                keyboardType: TextInputType.number,
                validatorText: 'Jumlah buku wajib diisi.',
                numberOnly: true,
              ),
            ),

            _fieldLine(
              label: 'Jumlah jamaah / santri',
              child: _textInput(
                controller: _peopleCountController,
                hintText: '250',
                keyboardType: TextInputType.number,
                numberOnly: true,
                requiredField: false,
              ),
            ),

            _fieldLine(
              label: 'Alasan pengajuan',
              child: _textInput(
                controller: _reasonController,
                hintText:
                    'Untuk melengkapi koleksi buku di masjid dan mendukung kegiatan pembelajaran fiqih ibadah bagi jamaah.',
                maxLines: 2,
                requiredField: false,
              ),
            ),

            _fieldLine(
              label: 'Upload foto lembaga (opsional)',
              child: _uploadBox(),
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: Checkbox(
                    value: _isConfirmed,
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (value) {
                      setState(() => _isConfirmed = value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Saya memastikan data yang diisi benar',
                    style: TextStyle(
                      color: Color.fromRGBO(44, 48, 58, 1),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLine({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_label(label), const SizedBox(height: 6), child],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromRGBO(34, 39, 49, 1),
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String hintText,
    String? validatorText,
    bool requiredField = true,
    bool numberOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color.fromRGBO(37, 42, 52, 1),
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(hintText),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (requiredField && text.isEmpty) {
          return validatorText ?? 'Field wajib diisi.';
        }

        if (numberOnly && text.isNotEmpty && int.tryParse(text) == null) {
          return 'Harus berupa angka.';
        }

        if (numberOnly && requiredField) {
          final number = int.tryParse(text);
          if (number == null || number < 1) {
            return 'Minimal 1.';
          }
        }

        return null;
      },
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hintText,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String validatorText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color.fromRGBO(70, 78, 88, 1),
      ),
      style: const TextStyle(
        fontSize: 14.5,
        color: Color.fromRGBO(37, 42, 52, 1),
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(hintText),
      hint: Text(hintText),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString(), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) return validatorText;
        return null;
      },
    );
  }

  Widget _bookDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedBookId,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color.fromRGBO(70, 78, 88, 1),
      ),
      style: const TextStyle(
        fontSize: 14.5,
        color: Color.fromRGBO(37, 42, 52, 1),
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration('Pilih buku'),
      hint: const Text('Pilih buku'),
      items: _bookOptions.map((book) {
        return DropdownMenuItem<int>(
          value: book.id,
          child: Text(book.title.toString(), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedBookId = value);
      },
      validator: (value) {
        if (value == null) return 'Buku wajib dipilih.';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color.fromRGBO(80, 85, 95, 0.75),
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      errorStyle: const TextStyle(fontSize: 11.5, height: 0.9),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color.fromRGBO(218, 218, 218, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }

  Widget _uploadBox() {
    final hasImage = _selectedImage != null;

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(14),
      child: CustomPaint(
        painter: DashedBorderPainter(color: primaryColor, radius: 14),
        child: Container(
          width: double.infinity,
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: hasImage
              ? Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedImage!.path.split(Platform.pathSeparator).last,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: darkGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Klik untuk upload foto',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Format JPG/PNG, maks. 5MB',
                      style: TextStyle(
                        color: Color.fromRGBO(100, 105, 112, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: yellowColor,
          disabledBackgroundColor: yellowColor.withOpacity(0.6),
          foregroundColor: darkGreen,
          elevation: 4,
          shadowColor: yellowColor.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: darkGreen,
                ),
              )
            : const Text(
                'Kirim Pengajuan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 7.0;
    const dashSpace = 5.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rRect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;

      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance.clamp(0, metric.length),
        );

        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
