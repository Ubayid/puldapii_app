import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:puldapii/config/bloc/consultation_bloc/consultation_bloc.dart';
import 'package:puldapii/utils/widget/background.dart';

class ConsultAnswerPage extends StatefulWidget {
  final Map<String, dynamic> konsultasi;

  const ConsultAnswerPage({super.key, required this.konsultasi});

  @override
  State<ConsultAnswerPage> createState() => _ConsultAnswerPageState();
}

class _ConsultAnswerPageState extends State<ConsultAnswerPage> {
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color yellowColor = Color.fromRGBO(251, 205, 76, 1);

  late final TextEditingController _jawabanController;

  @override
  void initState() {
    super.initState();
    _jawabanController = TextEditingController(
      text: widget.konsultasi['jawaban']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _jawabanController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<ConsultationBloc>().add(
      ConsultationAnswerSubmitted(
        consultationId: widget.konsultasi['id'] as int,
        answer: _jawabanController.text,
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

  String _formatTanggal(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return DateFormat('dd MMMM yyyy', 'id_ID').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final konsultasi = widget.konsultasi;

    final bool sudahDijawab =
        konsultasi['status']?.toString() == 'Sudah Dijawab';

    return BlocConsumer<ConsultationBloc, ConsultationState>(
      listenWhen: (previous, current) {
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.status == ConsultationStatus.answerSuccess) {
          Navigator.pop(context);
          return;
        }
        if (state.status == ConsultationStatus.failure &&
            state.message != null) {
          _showSnackBar(state.message!, isError: true);
        }
      },
      builder: (context, state) {
        final bool isSending =
            state.status == ConsultationStatus.answering &&
            state.answeringConsultationId == konsultasi['id'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F8F4),
            elevation: 0,
            iconTheme: const IconThemeData(color: primaryColor),
            title: const Text(
              'Jawab Konsultasi',
              style: TextStyle(
                color: Color(0xFF1B1B1B),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          body: GradientPage(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            konsultasi['judul']?.toString() ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(
                          status: konsultasi['status']?.toString() ?? '-',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _WhiteCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Nama Penanya',
                          value: konsultasi['nama']?.toString() ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Nomor WhatsApp',
                          value: konsultasi['phone']?.toString() ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: konsultasi['email']?.toString() ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.category_outlined,
                          label: 'Kategori',
                          value: konsultasi['kategori']?.toString() ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal',
                          value: _formatTanggal(konsultasi['tanggal']),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Isi Pertanyaan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          konsultasi['pesan']?.toString() ?? '-',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jawaban Ustadz',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _jawabanController,
                          readOnly: sudahDijawab || isSending,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: sudahDijawab
                                ? 'Jawaban sudah dikirim'
                                : 'Tulis jawaban konsultasi di sini...',
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: primaryColor,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (!sudahDijawab)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellowColor,
                          foregroundColor: primaryColor,
                          disabledBackgroundColor: yellowColor.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: primaryColor,
                                ),
                              )
                            : const Text(
                                'Kirim Jawaban',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool done = status == 'Sudah Dijawab';
    final Color color = done ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
