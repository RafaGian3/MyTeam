import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  // [BARU]
  const NotFoundScreen({super.key, required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Halaman tidak ditemukan'),
            if (routeName != null) Text(routeName!),
          ],
        ),
      ),
    );
  }
}
