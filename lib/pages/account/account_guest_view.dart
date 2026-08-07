import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/auth_bloc/auth_bloc.dart';
import 'package:puldapii/pages/auth/login_page.dart';
import 'package:puldapii/pages/auth/register_page.dart';
import 'package:puldapii/utils/widget/background.dart';

class AccountGuestView extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const AccountGuestView({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GradientPage(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    _LoginCard(
                      onLoginTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthBloc>(),
                              child: const LoginPage(),
                            ),
                          ),
                        );

                        if (result == true) {
                          onLoginSuccess();
                        }
                      },
                      onRegisterTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthBloc>(),
                              child: const RegisterPage(),
                            ),
                          ),
                        );

                        if (result == true) {
                          onLoginSuccess();
                        }
                      },
                    ),

                    // const SizedBox(height: 20),

                    // _MenuSection(
                    //   children: [
                    //     _MenuTile(
                    //       icon: Icons.help_outline,
                    //       title: "Pusat Bantuan",
                    //       subtitle: "Butuh bantuan menggunakan aplikasi?",
                    //       onTap: () {
                    //         print("Bantuan tapped");
                    //       },
                    //     ),
                    //     _MenuTile(
                    //       icon: Icons.info_outline,
                    //       title: "Tentang Aplikasi",
                    //       subtitle: "Informasi mengenai PULDAPIIKU",
                    //       onTap: () {
                    //         print("Tentang tapped");
                    //       },
                    //     ),
                    //     _MenuTile(
                    //       icon: Icons.privacy_tip_outlined,
                    //       title: "Kebijakan Privasi",
                    //       subtitle: "Pelajari penggunaan data dan privasi",
                    //       onTap: () {
                    //         print("Privacy tapped");
                    //       },
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 24),

                    Text(
                      "Masuk untuk mengakses fitur akun, riwayat, dan layanan lainnya.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),
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

class _LoginCard extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const _LoginCard({required this.onLoginTap, required this.onRegisterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onLoginTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(251, 205, 76, 1),
                foregroundColor: const Color.fromRGBO(24, 100, 80, 1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Masuk",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onRegisterTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Daftar Akun",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
