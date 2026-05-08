import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget webAdmin;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.webAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return mobile;
        }
        return webAdmin;
      },
    );
  }
}

