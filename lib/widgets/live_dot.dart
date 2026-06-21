import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveDot extends StatefulWidget {
  const LiveDot({super.key});

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Ping esterno
            FadeTransition(
              opacity: Tween(begin: 0.75, end: 0.0).animate(_controller),
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 2.0).animate(_controller),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.liveBg,
                  ),
                ),
              ),
            ),
            // Pallino fisso
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.live,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        const Text(
          "LIVE",
          style: TextStyle(
            color: AppColors.liveBg,
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
