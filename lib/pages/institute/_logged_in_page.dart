import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puldapii/config/cubit/institution_cubit/institution_cubit.dart';
import 'package:puldapii/config/cubit/institution_cubit/institution_state.dart';
import 'package:puldapii/models/institution_model.dart';
import 'package:puldapii/pages/institute/institute_detail_page.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';

class InstituteLoggedInPage extends StatefulWidget {
  const InstituteLoggedInPage({super.key});

  @override
  State<InstituteLoggedInPage> createState() => _InstituteLoggedInPageState();
}

class _InstituteLoggedInPageState extends State<InstituteLoggedInPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  String _searchQuery = '';

  int selectedFilter = 0;
  bool _showPager = false;
  static const int _perPage = 10;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  final List<String> filters = [
    'Semua',
    'Terverifikasi',
    'Pesantren',
    'Yayasan',
    'Dakwah',
  ];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final cubit = context.read<InstitutionCubit>();

      if (cubit.state.totalInstitutions == 0 && !cubit.state.isStatsLoading) {
        cubit.fetchInstitutionStats();
      }

      if (cubit.state.institutions.isEmpty && !cubit.state.isListLoading) {
        cubit.fetchInstitutions();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!mounted) return;

    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      _setShowPager(true);
    } else if (direction == ScrollDirection.forward) {
      _setShowPager(false);
    }
  }

  void _onFilterTap(int index) {
    if (selectedFilter == index && _searchQuery.isEmpty) return;

    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      selectedFilter = index;
      _searchQuery = '';
      _showPager = false;
    });

    context.read<InstitutionCubit>().fetchInstitutions(
      q: _filterQuery(index),
      page: 1,
      perPage: _perPage,
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    setState(() {
      _searchQuery = value.trim();
      _showPager = false;

      if (_searchQuery.isNotEmpty) {
        selectedFilter = 0;
      }
    });

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<InstitutionCubit>().fetchInstitutions(
        q: _searchQuery,
        page: 1,
        perPage: _perPage,
      );
    });
  }

  void _onClearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    setState(() {
      _searchQuery = '';
      selectedFilter = 0;
      _showPager = false;
    });

    context.read<InstitutionCubit>().fetchInstitutions(
      q: '',
      page: 1,
      perPage: _perPage,
    );
  }

  String _activeQuery() {
    if (_searchQuery.trim().isNotEmpty) {
      return _searchQuery.trim();
    }

    return _filterQuery(selectedFilter);
  }

  String _filterQuery(int index) {
    switch (index) {
      case 2:
        return 'Pesantren';
      case 3:
        return 'Yayasan';
      case 4:
        return 'Dakwah';
      case 0:
      case 1:
      default:
        return '';
    }
  }

  List<InstitutionModel> _visibleInstitutions(
    List<InstitutionModel> institutions,
  ) {
    if (selectedFilter == 1) {
      return institutions.where(_isVerified).toList();
    }

    return institutions;
  }

  bool _isVerified(InstitutionModel item) {
    final value = item.verificationStatus?.toLowerCase().trim();
    return value == 'verified' || value == 'terverifikasi';
  }

  bool _isActive(InstitutionModel item) {
    final status = item.status?.toLowerCase().trim();
    return item.isActive || status == 'active' || status == 'aktif';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstitutionCubit, InstitutionState>(
      builder: (context, state) {
        final visibleInstitutions = _visibleInstitutions(state.institutions);

        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (visibleInstitutions.isEmpty) return;

                setState(() {
                  _showPager = !_showPager;
                });
              },
              child: SizedBox(
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 90),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildStats(state),
                            const SizedBox(height: 14),
                            _buildSearchBar(),
                            const SizedBox(height: 10),
                            _buildFilters(),
                            const SizedBox(height: 12),
                            _buildMemberList(
                              state: state,
                              institutions: visibleInstitutions,
                            ),
                          ],
                        ),
                      ),
                    ),

                    FloatingPager(
                      showPager: visibleInstitutions.isNotEmpty && _showPager,
                      page: state.currentPage,
                      isLoading: state.isListLoading,
                      hasNextPage: state.currentPage < state.lastPage,
                      onPageChanged: (page) {
                        context.read<InstitutionCubit>().fetchInstitutions(
                          q: _activeQuery(),
                          page: page,
                          perPage: _perPage,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStats(InstitutionState state) {
    final loadingValue = state.isStatsLoading ? '-' : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.groups_rounded,
              label: 'Anggota',
              value: loadingValue ?? state.totalInstitutions.toString(),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _StatCard(
              icon: Icons.location_on_rounded,
              label: 'Provinsi',
              value: loadingValue ?? state.totalProvinces.toString(),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _StatCard(
              icon: Icons.location_city_rounded,
              label: 'Kota',
              value: loadingValue ?? state.totalCities.toString(),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _StatCard(
              icon: Icons.verified_user_rounded,
              label: 'Terverifikasi',
              value: loadingValue ?? state.totalVerified.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: AppSearchBar(
        controller: _searchController,
        hintText: 'Cari lembaga...',
        onChanged: _onSearchChanged,
        onClear: _onClearSearch,
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          if (index == filters.length) {
            return Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xff2D3440),
                size: 20,
              ),
            );
          }

          final isSelected = selectedFilter == index;

          return GestureDetector(
            onTap: () => _onFilterTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff009B8A) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xff1F2732),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberList({
    required InstitutionState state,
    required List<InstitutionModel> institutions,
  }) {
    if (state.isListLoading && state.institutions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.institutions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 70, 18, 0),
        child: _EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Gagal memuat data',
          message: state.errorMessage!,
          buttonText: 'Coba Lagi',
          onPressed: () {
            context.read<InstitutionCubit>().fetchInstitutions(
              q: _activeQuery(),
              page: 1,
              perPage: _perPage,
            );
          },
        ),
      );
    }

    if (institutions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(18, 70, 18, 0),
        child: _EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Data belum tersedia',
          message: 'Institution belum ditemukan.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: institutions.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= institutions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _MemberCard(member: institutions[index]);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xffD7F8EF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xff009B8A), size: 19),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff7A8089),
              fontSize: 10.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final InstitutionModel member;

  const _MemberCard({required this.member});

  String _textOrStrip(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value.trim();
  }

  String _locationText() {
    final city = member.city?.trim();
    final province = member.province?.trim();

    if ((city == null || city.isEmpty) &&
        (province == null || province.isEmpty)) {
      return '-';
    }

    if (city == null || city.isEmpty) {
      return province!;
    }

    if (province == null || province.isEmpty) {
      return city;
    }

    return '$city, $province';
  }

  String _fieldText() {
    final sector = member.sector?.trim();
    final type = member.institutionType?.trim();

    if (sector != null && sector.isNotEmpty) {
      return sector;
    }

    if (type != null && type.isNotEmpty) {
      return type;
    }

    return '-';
  }

  String _joinedYearText() {
    if (member.joinedYear == null) {
      return '-';
    }

    return member.joinedYear.toString();
  }

  String _logoInitial() {
    final name = member.name?.trim();

    if (name == null || name.isEmpty) {
      return '-';
    }

    final words = name
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => word.trim())
        .toList();

    if (words.isEmpty) {
      return '-';
    }

    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return words.take(3).map((word) => word[0]).join().toUpperCase();
  }

  bool _isVerified() {
    final value = member.verificationStatus?.toLowerCase().trim();
    return value == 'verified' || value == 'terverifikasi';
  }

  bool _isActive() {
    final status = member.status?.toLowerCase().trim();
    return member.isActive || status == 'active' || status == 'aktif';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<InstitutionCubit>(),
              child: InstitutionDetailPage(
                institutionId: member.id,
                initialInstitution: member,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEF0F3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LogoAvatar(imageUrl: member.logoUrl, initial: _logoInitial()),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _textOrStrip(member.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _locationText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff7A8089),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          _StatusBadge(
                            text: _isVerified()
                                ? 'Terverifikasi'
                                : 'Belum Verifikasi',
                            isGreen: _isVerified(),
                          ),
                          _StatusBadge(
                            text: _isActive() ? 'Anggota Aktif' : 'Tidak Aktif',
                            isGreen: _isActive(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.badge_outlined,
                    text: 'Bidang: ${_fieldText()}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.groups_outlined,
                    text: 'Bergabung: ${_joinedYearText()}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initial;

  const _LogoAvatar({required this.imageUrl, required this.initial});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xffF2FBF8),
        border: Border.all(color: const Color(0xff0C8F72), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _LogoInitial(initial: initial);
              },
            )
          : _LogoInitial(initial: initial),
    );
  }
}

class _LogoInitial extends StatelessWidget {
  final String initial;

  const _LogoInitial({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Text(
      initial,
      style: const TextStyle(
        color: Color(0xff087D70),
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final bool isGreen;

  const _StatusBadge({required this.text, this.isGreen = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xffDDF8D9) : const Color(0xffF2F3F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isGreen ? const Color(0xff196D2D) : const Color(0xff6B7280),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 155),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xff009B8A)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff1F2732),
                fontSize: 10.8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEEF0F3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xff009B8A), size: 36),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff1F2732),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff7A8089),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff009B8A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}
