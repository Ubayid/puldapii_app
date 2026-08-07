import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puldapii/models/book_taawun_model.dart';
import 'package:puldapii/pages/home/pages/layanan/books/_bank_account.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_taawun_detail_page.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/book_taawun_bloc/book_taawun_bloc.dart';
import 'package:puldapii/utils/services/home/book_taawun_service.dart';

class TaawunPage extends StatefulWidget {
  const TaawunPage({
    super.key,
    required this.bookId,
    this.title = 'Panduan Sholat Sesuai Sunnah',
    this.category = 'Fiqih Ibadah',
    this.coverUrl = '',
    this.targetQuantity = 1000,
    this.collectedQuantity = 420,
  });

  final int bookId;
  final String title;
  final String category;
  final String coverUrl;
  final int targetQuantity;
  final int collectedQuantity;

  @override
  State<TaawunPage> createState() => _TaawunPageState();
}

class _TaawunPageState extends State<TaawunPage> {
  static const Color primary = Color(0xFF009E96);

  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController(text: 'Rp100.000');
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  final List<int> _nominalOptions = const [
    50000,
    100000,
    150000,
    250000,
    500000,
    1000000,
  ];

  bool _anonymous = false;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _setAmount(int amount) {
    setState(() {
      _amountController.text = _formatRupiah(amount);
    });
  }

  void _submit(BuildContext blocContext) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final amount = _parseRupiah(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal taawun wajib diisi.')),
      );
      return;
    }

    final donorEmail = _emailController.text.trim();

    blocContext.read<BookTaawunBloc>().add(
      BookTaawunCreated(
        bookId: widget.bookId,
        donorName: _anonymous ? 'Hamba Allah' : _nameController.text.trim(),
        donorWhatsapp: _whatsappController.text.trim(),
        donorEmail: donorEmail.isEmpty ? null : donorEmail,
        amount: amount,
      ),
    );
  }

  Future<BookTaawunModel?> _getLatestTaawun() async {
    try {
      final response = await BookTaawunService().getTaawuns(
        page: 1,
        perPage: 1,
      );

      final pagination = BookTaawunPaginationModel.fromJson(response);

      if (pagination.data.isEmpty) return null;

      return pagination.data.first;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.targetQuantity == 0
        ? 0.0
        : (widget.collectedQuantity / widget.targetQuantity).clamp(0.0, 1.0);

    final percent = (progress * 100).round();
    final selectedAmount = _parseRupiah(_amountController.text);

    return BlocProvider(
      create: (_) => BookTaawunBloc(service: BookTaawunService()),
      child: BlocConsumer<BookTaawunBloc, BookTaawunState>(
        listenWhen: (previous, current) {
          return previous.errorMessage != current.errorMessage ||
              previous.successMessage != current.successMessage;
        },
        listener: (context, state) async {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );

            context.read<BookTaawunBloc>().add(
              const BookTaawunMessageCleared(),
            );
          }

          if (state.successMessage != null) {
            final submittedAmount = _parseRupiah(_amountController.text);

            Map<String, dynamic>? bankAccount;
            BookTaawunModel? latestTaawun;

            try {
              final response = await BookTaawunService().getBankAccount();
              final data = response['data'];

              if (data is Map<String, dynamic>) {
                bankAccount = data;
              }
            } catch (_) {
              bankAccount = null;
            }

            latestTaawun = await _getLatestTaawun();

            if (!mounted) return;

            context.read<BookTaawunBloc>().add(
              const BookTaawunMessageCleared(),
            );

            await TaawunBankAccountDialog.show(
              context,
              bankAccount: bankAccount,
              amount: submittedAmount,
              primary: primary,
              onUnderstand: () {
                if (!mounted) return;

                if (latestTaawun == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data taawun berhasil dibuat, tetapi detail belum bisa dibuka.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          BookTaawunBloc(service: BookTaawunService()),
                      child: BookTaawunDetailPage(item: latestTaawun!),
                    ),
                  ),
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  SecondaryHeader(title: "Pendataan Bantuan"),

                  Expanded(
                    child: GradientPage(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _BookCard(
                              title: widget.title,
                              category: widget.category,
                              coverUrl: widget.coverUrl,
                              targetQuantity: widget.targetQuantity,
                              collectedQuantity: widget.collectedQuantity,
                              percent: percent,
                              progress: progress,
                            ),

                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                18,
                                16,
                                18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _SectionTitle(
                                      title: 'Nominal Taawun',
                                    ),

                                    const SizedBox(height: 14),

                                    SizedBox(
                                      height: 42,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: _nominalOptions.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final amount = _nominalOptions[index];

                                          return _NominalChip(
                                            amount: amount,
                                            selected: selectedAmount == amount,
                                            onTap: state.isSubmitting
                                                ? null
                                                : () => _setAmount(amount),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    TextFormField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      enabled: !state.isSubmitting,
                                      inputFormatters: [RupiahInputFormatter()],
                                      decoration: _inputDecoration(
                                        hintText: 'Nominal Taawun',
                                      ),
                                      validator: (value) {
                                        final amount = _parseRupiah(
                                          value ?? '',
                                        );

                                        if (amount <= 0) {
                                          return 'Nominal taawun wajib diisi.';
                                        }

                                        return null;
                                      },
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                    ),

                                    const SizedBox(height: 18),

                                    const _SectionTitle(title: 'Data Donatur'),

                                    const SizedBox(height: 14),

                                    TextFormField(
                                      controller: _nameController,
                                      enabled:
                                          !_anonymous && !state.isSubmitting,
                                      textInputAction: TextInputAction.next,
                                      decoration: _inputDecoration(
                                        hintText: 'Nama Donatur',
                                      ),
                                      validator: (value) {
                                        if (_anonymous) return null;

                                        if ((value ?? '').trim().isEmpty) {
                                          return 'Nama donatur wajib diisi.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    TextFormField(
                                      controller: _whatsappController,
                                      enabled: !state.isSubmitting,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      decoration: _inputDecoration(
                                        hintText: 'No. WhatsApp',
                                      ),
                                      validator: (value) {
                                        if ((value ?? '').trim().isEmpty) {
                                          return 'No. WhatsApp wajib diisi.';
                                        }

                                        if ((value ?? '').trim().length < 9) {
                                          return 'No. WhatsApp tidak valid.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    TextFormField(
                                      controller: _emailController,
                                      enabled: !state.isSubmitting,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      decoration: _inputDecoration(
                                        hintText: 'Email (opsional)',
                                      ),
                                      validator: (value) {
                                        final email = (value ?? '').trim();

                                        if (email.isEmpty) return null;

                                        final validEmail = RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+$',
                                        ).hasMatch(email);

                                        if (!validEmail) {
                                          return 'Email tidak valid.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 34,
                                          height: 34,
                                          child: Checkbox(
                                            value: _anonymous,
                                            activeColor: primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            onChanged: state.isSubmitting
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      _anonymous =
                                                          value ?? false;

                                                      if (_anonymous) {
                                                        _nameController.clear();
                                                      }
                                                    });
                                                  },
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Expanded(
                                          child: Text(
                                            'Tampilkan sebagai hamba Allah',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF444444),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE4F7F5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Text(
                                        'Kontribusi Anda akan membantu biaya cetak dan distribusi buku.',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF245B58),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => _submit(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primary,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: primary
                                              .withOpacity(0.55),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: state.isSubmitting
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text(
                                                'Lanjutkan Taawun',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.title,
    required this.category,
    required this.coverUrl,
    required this.targetQuantity,
    required this.collectedQuantity,
    required this.percent,
    required this.progress,
  });

  final String title;
  final String category;
  final String coverUrl;
  final int targetQuantity;
  final int collectedQuantity;
  final int percent;
  final double progress;

  static const Color primary = Color(0xFF009E96);
  static const Color darkTeal = Color(0xFF006B67);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCover(coverUrl: coverUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: darkTeal,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(Icons.sell_outlined, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF555555),
                          ),
                          children: [
                            const TextSpan(text: 'Kategori: '),
                            TextSpan(
                              text: category,
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: _SmallInfo(
                        icon: Icons.track_changes,
                        text: 'Target: ${_formatNumber(targetQuantity)} buku',
                      ),
                    ),
                    Expanded(
                      child: _SmallInfo(
                        icon: Icons.groups_outlined,
                        text:
                            'Terkumpul: ${_formatNumber(collectedQuantity)} buku',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progress,
                          backgroundColor: const Color(0xFFE6E6E6),
                          valueColor: const AlwaysStoppedAnimation(primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF0D6B51),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: Text(
                  'PANDUAN\nSHOLAT\nSESUAI\nSUNNAH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          : Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Icon(Icons.menu_book, color: Colors.white, size: 34),
                );
              },
            ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Color(0xFF666666)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  static const Color darkTeal = Color(0xFF006B67);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        color: darkTeal,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _NominalChip extends StatelessWidget {
  const _NominalChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback? onTap;

  static const Color primary = Color(0xFF009E96);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? primary : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? primary : const Color(0xFFE0E0E0),
              width: 1.2,
            ),
          ),
          child: Text(
            _formatRupiah(amount),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = int.tryParse(digits) ?? 0;
    final text = _formatRupiah(value);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String _formatRupiah(int value) {
  return 'Rp${_formatNumber(value)}';
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final position = text.length - i;

    buffer.write(text[i]);

    if (position > 1 && position % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

int _parseRupiah(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

  if (digits.isEmpty) return 0;

  return int.tryParse(digits) ?? 0;
}
