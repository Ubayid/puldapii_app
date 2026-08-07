import 'package:flutter/material.dart';

class GradientPage extends StatelessWidget {
  final Widget child;

  const GradientPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(169, 218, 221, 1),
                Color.fromRGBO(201, 230, 228, 1),
                Color.fromRGBO(250, 250, 250, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
