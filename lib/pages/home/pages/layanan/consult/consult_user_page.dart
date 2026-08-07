import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/consultation_bloc/consultation_bloc.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_form.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_list_page.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';

class ConsultUserPage extends StatefulWidget {
  const ConsultUserPage({super.key});

  @override
  State<ConsultUserPage> createState() => _ConsultUserPageState();
}

class _ConsultUserPageState extends State<ConsultUserPage> {
  static const Color primaryColor = Colors.teal;

  bool _showPager = false;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  void _toggleFloatingPager() {
    setState(() {
      _showPager = !_showPager;
    });
  }

  void _handleScrollDirection(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) {
      _setShowPager(true);
    } else if (direction == ScrollDirection.forward) {
      _setShowPager(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(),

              Expanded(
                child: GradientPage(
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis == Axis.vertical) {
                        _handleScrollDirection(notification.direction);
                      }

                      return false;
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleFloatingPager,
                      child: const ConsultListPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          BlocBuilder<ConsultationBloc, ConsultationState>(
            builder: (context, state) {
              final isLoading =
                  state.status == ConsultationStatus.incomingLoading;

              final consultations = state.myConsultations;

              return FloatingPager(
                showPager: consultations.isNotEmpty && _showPager,
                page: state.page,
                isLoading: isLoading,
                hasNextPage: state.hasNextPage,
                onPageChanged: (page) {
                  _setShowPager(false);

                  context.read<ConsultationBloc>().add(
                    ConsultationHistoryPageChanged(page),
                  );
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConsultForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
