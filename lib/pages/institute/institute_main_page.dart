import 'package:flutter/material.dart';
import 'package:puldapii/pages/institute/_logged_in_page.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class InstituteMainPage extends StatelessWidget {
  const InstituteMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(),
            Expanded(child: GradientPage(child: InstituteLoggedInPage())),
          ],
        ),
      ),
    );
  }
}
