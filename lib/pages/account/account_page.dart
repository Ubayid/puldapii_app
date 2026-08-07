import 'package:flutter/material.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/services/auth_service.dart';

import 'account_guest_view.dart';
import 'account_logged_in_view.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _authService = AuthService();

  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _authService.getToken();
  }

  Future<void> _refreshAccount() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    setState(() {
      _tokenFuture = _authService.getToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(),

          Expanded(
            child: GradientPage(
              child: FutureBuilder<String?>(
                future: _tokenFuture,
                builder: (context, snapshot) {
                  print('ACCOUNT SNAPSHOT STATE: ${snapshot.connectionState}');
                  print('ACCOUNT SNAPSHOT DATA: ${snapshot.data}');
                  print('ACCOUNT SNAPSHOT ERROR: ${snapshot.error}');

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error token: ${snapshot.error}'),
                    );
                  }

                  final token = snapshot.data;
                  final isLoggedIn = token != null && token.isNotEmpty;

                  print('ACCOUNT IS LOGGED IN: $isLoggedIn');

                  if (isLoggedIn) {
                    return AccountLoggedInView(
                      onLogoutSuccess: _refreshAccount,
                    );
                  }

                  return AccountGuestView(onLoginSuccess: _refreshAccount);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
