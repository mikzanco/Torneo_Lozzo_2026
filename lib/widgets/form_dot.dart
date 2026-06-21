import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FormDot extends StatelessWidget {
  final String result; // "w", "d", "l"

  const FormDot({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (result.toLowerCase()) {
      case 'w':
        dotColor = AppColors.dotWin;
        break;
      case 'd':
        dotColor = AppColors.dotDraw;
        break;
      case 'l':
      default:
        dotColor = AppColors.dotLoss;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
    );
  }
}
