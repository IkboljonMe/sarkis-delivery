import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/glass_card.dart';

class SummaryCardWidget extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final bool pulse;

  const SummaryCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (pulse) {
      dot = dot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(duration: 700.ms, end: const Offset(1.5, 1.5));
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              dot,
              const Spacer(),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value),
                duration: const Duration(milliseconds: 600),
                builder: (_, v, __) => Text('$v',
                    style: AppTextStyles.headingXL.copyWith(color: color)),
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
