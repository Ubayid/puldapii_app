import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:puldapii/config/cubit/institution_cubit/institution_cubit.dart';
import 'package:puldapii/config/cubit/institution_cubit/institution_state.dart';
import 'package:puldapii/models/institution_model.dart';

class InstitutionDetailPage extends StatefulWidget {
  final int institutionId;
  final InstitutionModel? initialInstitution;

  const InstitutionDetailPage({
    super.key,
    required this.institutionId,
    this.initialInstitution,
  });

  @override
  State<InstitutionDetailPage> createState() => _InstitutionDetailPageState();
}

class _InstitutionDetailPageState extends State<InstitutionDetailPage> {
  static const Color primary = Color(0xFF07977F);
  static const Color dark = Color(0xFF151922);
  static const Color muted = Color(0xFF7B8491);

  late final InstitutionCubit _cubit;

  int _selectedTab = 0;

  final List<String> _tabs = const ['Profil', 'Program', 'Kontak', 'Galeri'];

  @override
  void initState() {
    super.initState();

    _cubit = context.read<InstitutionCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cubit.fetchInstitutionDetail(widget.institutionId);
    });
  }

  @override
  void dispose() {
    _cubit.clearDetail();
    super.dispose();
  }

  String _textOrStrip(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  String _logoInitial(InstitutionModel data) {
    final name = data.name?.trim();

    if (name == null || name.isEmpty) return '-';

    final words = name
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => word.trim())
        .toList();

    if (words.isEmpty) return '-';

    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return words.take(3).map((word) => word[0]).join().toUpperCase();
  }

  String _locationText(InstitutionModel data) {
    final city = data.city?.trim();
    final province = data.province?.trim();

    if ((city == null || city.isEmpty) &&
        (province == null || province.isEmpty)) {
      return '-';
    }

    if (city == null || city.isEmpty) return province!;
    if (province == null || province.isEmpty) return city;

    return '$city, $province';
  }

  bool _isVerified(InstitutionModel data) {
    final value = data.verificationStatus?.toLowerCase().trim();
    return value == 'verified' || value == 'terverifikasi';
  }

  String _verificationText(InstitutionModel data) {
    final value = data.verificationStatus?.trim();

    if (value == null || value.isEmpty) return '-';

    final lower = value.toLowerCase();

    if (lower == 'verified' || lower == 'terverifikasi') {
      return 'Terverifikasi';
    }

    if (lower == 'unverified' ||
        lower == 'belum verifikasi' ||
        lower == 'belum terverifikasi') {
      return 'Belum Verifikasi';
    }

    return value;
  }

  bool _isActive(InstitutionModel data) {
    final status = data.status?.toLowerCase().trim();
    return data.isActive || status == 'active' || status == 'aktif';
  }

  String _statusText(InstitutionModel data) {
    final status = data.status?.trim();

    if (status != null && status.isNotEmpty) {
      final lower = status.toLowerCase();

      if (lower == 'active' || lower == 'aktif') return 'Aktif';
      if (lower == 'inactive' || lower == 'tidak aktif') return 'Tidak Aktif';

      return status;
    }

    if (data.isActive) return 'Aktif';

    return '-';
  }

  String _memberStatusText(InstitutionModel data) {
    final status = _statusText(data);

    if (status == '-') return '-';
    if (_isActive(data)) return 'Anggota Aktif';

    return 'Tidak Aktif';
  }

  String _fieldText(InstitutionModel data) {
    return '-';
  }

  String _joinedYearText(InstitutionModel data) {
    if (data.joinedYear == null || data.joinedYear == 0) return '-';
    return data.joinedYear.toString();
  }

  String _addressText(InstitutionModel data) {
    final address = data.address?.trim();
    if (address != null && address.isNotEmpty) return address;
    return '-';
  }

  Future<void> _openUrl(String? value) async {
    if (value == null || value.trim().isEmpty || value.trim() == '-') {
      _showSnack('Data belum tersedia');
      return;
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null) {
      _showSnack('Link tidak valid');
      return;
    }

    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!success) {
      _showSnack('Tidak bisa membuka link');
    }
  }

  Future<void> _openWhatsapp(String? value) async {
    final raw = value?.trim();

    if (raw == null || raw.isEmpty) {
      _showSnack('Nomor WhatsApp belum tersedia');
      return;
    }

    var number = raw.replaceAll(RegExp(r'[^0-9]'), '');

    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    }

    if (number.isEmpty) {
      _showSnack('Nomor WhatsApp tidak valid');
      return;
    }

    await _openUrl('https://wa.me/$number');
  }

  Future<void> _openEmail(String? value) async {
    final email = value?.trim();

    if (email == null || email.isEmpty) {
      _showSnack('Email belum tersedia');
      return;
    }

    await _openUrl('mailto:$email');
  }

  Future<void> _openWebsite(String? value) async {
    final website = value?.trim();

    if (website == null || website.isEmpty) {
      _showSnack('Website belum tersedia');
      return;
    }

    final fixedUrl =
        website.startsWith('http://') || website.startsWith('https://')
        ? website
        : 'https://$website';

    await _openUrl(fixedUrl);
  }

  Future<void> _openLocation(InstitutionModel data) async {
    final locationUrl = data.locationUrl?.trim();

    if (locationUrl != null && locationUrl.isNotEmpty) {
      await _openUrl(locationUrl);
      return;
    }

    final query = [
      data.address,
      data.city,
      data.province,
      data.name,
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    if (query.isEmpty) {
      _showSnack('Lokasi belum tersedia');
      return;
    }

    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';

    await _openUrl(mapsUrl);
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstitutionCubit, InstitutionState>(
      builder: (context, state) {
        final apiDetail = state.detail?.id == widget.institutionId
            ? state.detail
            : null;

        final data = apiDetail ?? widget.initialInstitution;

        if (state.isDetailLoading && data == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F8FA),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (data == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FA),
            appBar: AppBar(
              title: const Text('Detail Lembaga'),
              backgroundColor: Colors.white,
              foregroundColor: dark,
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.errorMessage ?? 'Data lembaga tidak ditemukan.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                SecondaryHeader(title: "Detail Lembaga"),
                if (state.isDetailLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: primary,
                    backgroundColor: Color(0xFFE8F7F4),
                  ),
                Expanded(
                  child: DefaultTabController(
                    length: _tabs.length,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _heroWithTabs(data),
                          _selectedTabContent(data),
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
    );
  }

  Widget _heroWithTabs(InstitutionModel data) {
    const double heroHeight = 175;
    const double tabHeight = 68;
    const double overlap = 36;

    return SizedBox(
      height: heroHeight + tabHeight - overlap,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: _heroSection(data),
          ),

          Positioned(
            top: heroHeight - overlap,
            left: 0,
            right: 0,
            child: _tabsWidget(),
          ),
        ],
      ),
    );
  }

  Widget _heroSection(InstitutionModel data) {
    final hasLogo = data.logoUrl != null && data.logoUrl!.trim().isNotEmpty;
    final hasCover =
        data.coverImageUrl != null && data.coverImageUrl!.trim().isNotEmpty;

    return SizedBox(
      height: 175,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasCover
                ? Image.network(
                    data.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        'assets/images/herobg.png',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset('assets/images/herobg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE7FFFB).withOpacity(0.84),
                    const Color(0xFFC5F4EB).withOpacity(0.74),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasLogo
                      ? Image.network(
                          data.logoUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return _LogoFallback(initial: _logoInitial(data));
                          },
                        )
                      : _LogoFallback(initial: _logoInitial(data)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _textOrStrip(data.name),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18.5,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 17,
                              color: primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _locationText(data),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w600,
                                  color: dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _StatusChip(
                              text: _verificationText(data),
                              bgColor: _isVerified(data)
                                  ? primary
                                  : const Color(0xFFF2F3F5),
                              textColor: _isVerified(data)
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                            _StatusChip(
                              text: _memberStatusText(data),
                              bgColor: _isActive(data)
                                  ? const Color(0xFFE9FFD7)
                                  : const Color(0xFFF2F3F5),
                              textColor: _isActive(data)
                                  ? const Color(0xFF236B43)
                                  : const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabsWidget() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: TabBar(
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        labelColor: primary,
        unselectedLabelColor: dark,
        indicatorColor: primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: _tabs.map((e) => Tab(text: e)).toList(),
      ),
    );
  }

  Widget _selectedTabContent(InstitutionModel data) {
    switch (_selectedTab) {
      case 1:
        return _programTab(data);
      case 2:
        return _contactTab(data);
      case 3:
        return _galleryTab(data);
      case 0:
      default:
        return _profileTab(data);
    }
  }

  Widget _profileTab(InstitutionModel data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Lembaga',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: dark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _textOrStrip(data.description),
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: dark,
            ),
          ),
          const SizedBox(height: 22),
          _infoCard(data),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _infoCard(InstitutionModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9DEE7), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Lembaga',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: dark,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.account_balance_outlined,
            label: 'Nama Lembaga',
            value: _textOrStrip(data.name),
            active: true,
          ),
          _InfoRow(
            icon: Icons.groups_2_outlined,
            label: 'Jenis Lembaga',
            value: _textOrStrip(data.institutionType),
          ),
          _InfoRow(
            icon: Icons.work_outline_rounded,
            label: 'Bidang',
            value: _fieldText(data),
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Provinsi',
            value: _textOrStrip(data.province),
          ),
          _InfoRow(
            icon: Icons.home_work_outlined,
            label: 'Kota/Kabupaten',
            value: _textOrStrip(data.city),
          ),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Tahun Bergabung',
            value: _joinedYearText(data),
          ),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Status',
            value: _statusText(data),
          ),
          _InfoRow(
            icon: Icons.shield_outlined,
            label: 'Verifikasi',
            value: _verificationText(data),
            active: true,
          ),
        ],
      ),
    );
  }

  Widget _programTab(InstitutionModel data) {
    final programs = data.programs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: programs.isEmpty
          ? _emptyCard('Program belum tersedia')
          : Column(
              children: programs.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProgramCard(program: item),
                );
              }).toList(),
            ),
    );
  }

  Widget _contactTab(InstitutionModel data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD9DEE7), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kontak Lembaga',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: dark,
              ),
            ),
            const SizedBox(height: 18),
            _ContactRow(
              icon: Icons.phone_in_talk_rounded,
              label: 'WhatsApp',
              value: _textOrStrip(data.whatsapp),
              onTap: () => _openWhatsapp(data.whatsapp),
            ),
            _ContactRow(
              icon: Icons.email_rounded,
              label: 'Email',
              value: _textOrStrip(data.email),
              onTap: () => _openEmail(data.email),
            ),
            _ContactRow(
              icon: Icons.language_rounded,
              label: 'Website',
              value: _textOrStrip(data.website),
              onTap: () => _openWebsite(data.website),
            ),
            _ContactRow(
              icon: Icons.location_on_rounded,
              label: 'Alamat',
              value: _addressText(data),
              onTap: () => _openLocation(data),
            ),
            _ContactRow(
              icon: Icons.map_rounded,
              label: 'Link Lokasi',
              value: _textOrStrip(data.locationUrl),
              onTap: () => _openLocation(data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _galleryTab(InstitutionModel data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: _galleryPreview(data, showAll: true),
    );
  }

  Widget _galleryPreview(InstitutionModel data, {bool showAll = false}) {
    final galleries = showAll
        ? data.galleries
        : data.galleries.take(6).toList();

    if (galleries.isEmpty) {
      return _emptyCard('Galeri belum tersedia');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Galeri Kegiatan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: dark,
                  ),
                ),
              ),
              if (!showAll)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = 3;
                    });
                  },
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: galleries.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              return _GalleryCard(gallery: galleries[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 38, color: primary),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _StatusChip({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final safeText = text.trim().isEmpty ? '-' : text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        safeText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 11.2,
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final String initial;

  const _LogoFallback({required this.initial});

  @override
  Widget build(BuildContext context) {
    final safeInitial = initial.trim().isEmpty ? '-' : initial.trim();

    return Container(
      color: const Color(0xFFF2FBF8),
      alignment: Alignment.center,
      child: Text(
        safeInitial,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _InstitutionDetailPageState.primary,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool active;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? _InstitutionDetailPageState.primary
        : _InstitutionDetailPageState.muted;

    final safeValue = value.trim().isEmpty ? '-' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _InstitutionDetailPageState.dark,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              safeValue,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _InstitutionDetailPageState.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim().isEmpty ? '-' : value.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: _InstitutionDetailPageState.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _InstitutionDetailPageState.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    safeValue,
                    style: const TextStyle(
                      color: _InstitutionDetailPageState.dark,
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB3BAC4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final InstitutionProgramModel program;

  const _ProgramCard({required this.program});

  String _textOrStrip(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        program.imageUrl != null && program.imageUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F7F4),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    program.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.menu_book_rounded,
                        color: _InstitutionDetailPageState.primary,
                        size: 34,
                      );
                    },
                  )
                : const Icon(
                    Icons.menu_book_rounded,
                    color: _InstitutionDetailPageState.primary,
                    size: 34,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textOrStrip(program.title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _InstitutionDetailPageState.dark,
                    fontSize: 15.5,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _textOrStrip(program.description),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _InstitutionDetailPageState.muted,
                    fontSize: 12.8,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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

class _GalleryCard extends StatelessWidget {
  final InstitutionGalleryModel gallery;

  const _GalleryCard({required this.gallery});

  String _textOrStrip(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        gallery.imageUrl != null && gallery.imageUrl!.trim().isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F7F4),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    gallery.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.image_rounded,
                        size: 34,
                        color: _InstitutionDetailPageState.primary,
                      );
                    },
                  )
                : const Icon(
                    Icons.image_rounded,
                    size: 34,
                    color: _InstitutionDetailPageState.primary,
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _textOrStrip(gallery.title),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _InstitutionDetailPageState.dark,
          ),
        ),
      ],
    );
  }
}
