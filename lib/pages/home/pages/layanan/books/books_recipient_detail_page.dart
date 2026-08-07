import 'package:flutter/material.dart';
import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/models/book_recipient_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class BookRecipientDetailPage extends StatelessWidget {
  const BookRecipientDetailPage({
    super.key,
    required this.item,
    this.catalogBook,
  });

  final BookRecipientModel item;
  final BookModel? catalogBook;

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color accentColor = Color(0xFF12A99C);

  @override
  @override
  Widget build(BuildContext context) {
    final book = _bestBook(item: item, catalogBook: catalogBook);

    final title = book?.title.trim().isNotEmpty == true
        ? book!.title
        : item.bookTitle;

    final coverUrl = book?.coverUrl.trim() ?? '';

    final institutionName = item.institutionName.trim().isNotEmpty
        ? item.institutionName
        : 'Lembaga penerima';

    final date = item.formattedCreatedAt.isNotEmpty
        ? item.formattedCreatedAt
        : 'Tanggal tidak tersedia';

    return SafeArea(
      child: Column(
        children: [
          SecondaryHeader(title: "Detail Pengajuan"),

          Expanded(
            child: GradientPage(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _HeaderCard(
                      title: title,
                      coverUrl: coverUrl,
                      institutionName: institutionName,
                      date: date,
                      status: item.status,
                    ),

                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'Informasi Pengajuan',
                      children: [
                        _InfoRow(
                          icon: Icons.menu_book_outlined,
                          label: 'Buku',
                          value: title,
                        ),
                        _InfoRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Jumlah Diajukan',
                          value: '${formatNumber(item.requestedQuantity)} buku',
                        ),
                        if (item.peopleCount != null && item.peopleCount! > 0)
                          _InfoRow(
                            icon: Icons.people_alt_outlined,
                            label: 'Jumlah Jamaah',
                            value: '${formatNumber(item.peopleCount!)} jamaah',
                          ),
                        _InfoRow(
                          icon: Icons.verified_user_outlined,
                          label: 'Konfirmasi',
                          value: item.isConfirmed
                              ? 'Sudah dikonfirmasi'
                              : 'Belum dikonfirmasi',
                        ),
                        _InfoRow(
                          icon: Icons.calendar_month_outlined,
                          label: 'Tanggal Pengajuan',
                          value: date,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'Data Lembaga',
                      children: [
                        _InfoRow(
                          icon: Icons.account_balance_rounded,
                          label: 'Nama Lembaga',
                          value: institutionName,
                        ),
                        _InfoRow(
                          icon: Icons.groups_rounded,
                          label: 'Jenis Lembaga',
                          value: _safeText(item.institutionType),
                        ),
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Penanggung Jawab',
                          value: _safeText(item.responsibleName),
                        ),
                        _InfoRow(
                          icon: Icons.call_outlined,
                          label: 'Nomor WhatsApp',
                          value: _safeText(item.whatsappNumber),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'Alamat',
                      children: [
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat Lengkap',
                          value: _safeText(item.address),
                        ),
                        _InfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'Kota / Kabupaten',
                          value: _safeText(item.city),
                        ),
                        _InfoRow(
                          icon: Icons.map_outlined,
                          label: 'Provinsi',
                          value: _safeText(item.province),
                        ),
                      ],
                    ),

                    if (item.reason != null &&
                        item.reason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Alasan Pengajuan',
                        children: [
                          Text(
                            item.reason!,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Color(0xFF3E4D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (item.institutionPhotoUrl != null &&
                        item.institutionPhotoUrl!.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _InstitutionPhotoCard(
                        imageUrl: item.institutionPhotoUrl!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.coverUrl,
    required this.institutionName,
    required this.date,
    required this.status,
  });

  final String title;
  final String coverUrl;
  final String institutionName;
  final String date;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookCover(title: title, coverUrl: coverUrl),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusChip(status: status),

                  const SizedBox(height: 9),

                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: BookRecipientDetailPage.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        size: 15,
                        color: BookRecipientDetailPage.accentColor,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          institutionName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.25,
                            color: BookRecipientDetailPage.accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 15,
                        color: Color(0xFF6D7476),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3E4D4F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.title, required this.coverUrl});

  final String title;
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 122,
      decoration: BoxDecoration(
        color: const Color(0xFF2F7468),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _DefaultBookCover(title: title);
              },
            )
          : _DefaultBookCover(title: title),
    );
  }
}

class _DefaultBookCover extends StatelessWidget {
  const _DefaultBookCover({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 7,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.16),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(9),
              ),
            ),
          ),
        ),
        Positioned(
          right: -14,
          bottom: -8,
          child: Icon(
            Icons.fact_check_outlined,
            size: 74,
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.08,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: BookRecipientDetailPage.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BookRecipientDetailPage.accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: BookRecipientDetailPage.accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7A8385),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Color(0xFF263638),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionPhotoCard extends StatelessWidget {
  const _InstitutionPhotoCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto Lembaga',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: BookRecipientDetailPage.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: const Color(0xFFECEFF0),
                    child: const Text(
                      'Foto tidak dapat dimuat',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6D7476),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final String label;
    final Color color;
    final IconData icon;

    if (normalized == 'approved' ||
        normalized == 'disetujui' ||
        normalized == 'diterima') {
      label = 'Disetujui';
      color = BookRecipientDetailPage.accentColor;
      icon = Icons.check_circle_rounded;
    } else if (normalized == 'rejected' || normalized == 'ditolak') {
      label = 'Ditolak';
      color = Colors.redAccent;
      icon = Icons.cancel_rounded;
    } else if (normalized == 'process' ||
        normalized == 'processing' ||
        normalized == 'diproses') {
      label = 'Diproses';
      color = Colors.orange;
      icon = Icons.timelapse_rounded;
    } else {
      label = 'Menunggu';
      color = Colors.blueGrey;
      icon = Icons.hourglass_bottom_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

BookModel? _bestBook({
  required BookRecipientModel item,
  required BookModel? catalogBook,
}) {
  final itemBook = item.book;

  if (itemBook != null && itemBook.coverUrl.trim().isNotEmpty) {
    return itemBook;
  }

  if (catalogBook != null && catalogBook.coverUrl.trim().isNotEmpty) {
    return catalogBook;
  }

  return itemBook ?? catalogBook;
}

String _safeText(String value) {
  final text = value.trim();

  if (text.isEmpty) return '-';

  return text;
}

String formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
