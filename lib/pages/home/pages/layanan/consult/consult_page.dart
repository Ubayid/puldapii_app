import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_user_page.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_ustadz_page.dart';

class ConsultPage extends StatefulWidget {
  const ConsultPage({super.key});

  @override
  State<ConsultPage> createState() => _ConsultPageState();
}

class _ConsultPageState extends State<ConsultPage> {
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  bool _isLoading = true;
  bool _isUstadz = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();

    final role = prefs.getString('user_role')?.toLowerCase().trim() ?? '';

    print('CONSULT PAGE ROLE: $role');

    if (!mounted) return;

    setState(() {
      _isUstadz = role == 'ustadz';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8F4),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_isUstadz) {
      return const ConsultUstadzPage();
    }

    return const ConsultUserPage();
  }
}
