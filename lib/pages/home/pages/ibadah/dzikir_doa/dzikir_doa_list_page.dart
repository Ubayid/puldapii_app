import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/dzikir_pp_bloc/dzikir_pp_bloc.dart';
import 'package:puldapii/pages/home/pages/ibadah/dzikir_doa/dzikir_doa_detail_page.dart';
import 'package:puldapii/utils/services/home/dzikir_pp_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class DzikirPpMenuPage extends StatelessWidget {
  final DzikirPpService service;

  const DzikirPpMenuPage({super.key, required this.service});

  void _openDetail(BuildContext context, DzikirPpCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              DzikirPpBloc(service, category: category)..add(FetchDzikirPp()),
          child: DzikirPpDetailPage(category: category),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(onChatTap: () {}),
          Expanded(
            child: GradientPage(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        _DzikirMenuCard(
                          title: 'Dzikir Pagi',
                          subtitle: 'Bacaan dzikir untuk mengawali pagi hari',
                          icon: Icons.wb_sunny_rounded,
                          onTap: () =>
                              _openDetail(context, DzikirPpCategory.pagi),
                        ),
                        const SizedBox(height: 10),
                        _DzikirMenuCard(
                          title: 'Dzikir Petang',
                          subtitle: 'Bacaan dzikir untuk waktu sore dan malam',
                          icon: Icons.nightlight_round,
                          onTap: () =>
                              _openDetail(context, DzikirPpCategory.petang),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DzikirMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DzikirMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.teal, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
