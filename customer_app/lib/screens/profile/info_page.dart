import 'package:flutter/material.dart';

import '../../utils/app_text_styles.dart';

/// Generic static text page (Terms of Service, Privacy Policy, etc.).
class InfoPage extends StatelessWidget {
  final String title;
  final String body;
  const InfoPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title, style: AppTextStyles.headingL),
          const SizedBox(height: 16),
          Text(body,
              style: AppTextStyles.body.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
