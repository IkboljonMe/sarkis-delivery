import 'package:flutter/material.dart';

class SummaryCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
