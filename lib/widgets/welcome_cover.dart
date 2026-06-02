import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class WelcomeCover extends StatefulWidget {
  final VoidCallback onEnter;

  const WelcomeCover({
    Key? key,
    required this.onEnter,
  }) : super(key: key);

  @override
  State<WelcomeCover> createState() => _WelcomeCoverState();
}

class _WelcomeCoverState extends State<WelcomeCover> with SingleTickerProviderStateMixin {
  late AnimationController _ballController;
  late Animation<double> _oscillationAnimation;
  late Animation<double> _rotationAnimation;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    // Controller per il movimento fluttuante e rotatorio del pallone da calcio
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _oscillationAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _ballController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _ballController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ballController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url);
      }
    } catch (_) {
      try {
        await launchUrl(url);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          // ================= 1. BACKGROUND GEOMETRICO =================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.scaffoldBg,
                    AppColors.scaffoldBg.withBlue(35).withRed(15),
                    AppColors.scaffoldBg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Cerchio luminoso sfocato Magenta in alto a sinistra
          Positioned(
            left: -80,
            top: 80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSecondary.withOpacity(0.04),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentSecondary.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Cerchio luminoso sfocato Ciano in basso a destra
          Positioned(
            right: -100,
            bottom: 120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.04),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.12),
                    blurRadius: 120,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Elementi Geometrici Decorativi (Cerchietti del poster)
          Positioned(
            left: 40,
            top: 240,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentSecondary.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
          ),

          Positioned(
            right: 50,
            top: 360,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.12),
                  width: 2.0,
                ),
              ),
            ),
          ),

          // Crocette decorative
          Positioned(
            left: 80,
            bottom: 280,
            child: Text(
              "✕",
              style: TextStyle(
                color: AppColors.accentSecondary.withOpacity(0.3),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Positioned(
            right: 90,
            top: 180,
            child: Text(
              "✕",
              style: TextStyle(
                color: AppColors.accent.withOpacity(0.3),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ================= 2. CONTENUTO PRINCIPALE (CENTRATURA MOBILE-FIRST) =================
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),

                    // === INTESTAZIONE: SAVE THE DATE ===
                    Center(
                      child: Text(
                        "SAVE THE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppColors.white,
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                              color: AppColors.accentSecondary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(-2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "DATE!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppColors.white,
                          letterSpacing: -1.0,
                          height: 0.9,
                          shadows: [
                            Shadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // === CENTRO: PALLONE E TRIANGOLO NEON (ANIMATO) ===
                    Center(
                      child: AnimatedBuilder(
                        animation: _ballController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _oscillationAnimation.value),
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Triangolo Neon
                                  Transform.rotate(
                                    angle: 0.12,
                                    child: CustomPaint(
                                      size: const Size(200, 180),
                                      painter: TrianglePainter(gradient: AppColors.logoGradient),
                                    ),
                                  ),
                                  
                                  // Pallone da calcio ⚽
                                  const Text(
                                    "⚽",
                                    style: TextStyle(
                                      fontSize: 92,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                            blurRadius: 10,
                                            offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const Spacer(flex: 2),

                    // === DATA DEL TORNEO ===
                    Center(
                      child: Text(
                        "SABATO 4",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppColors.white,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "& DOMENICA 5",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppColors.white,
                          letterSpacing: -0.5,
                          height: 0.9,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => AppColors.logoGradient.createShader(bounds),
                        child: Text(
                          "LUGLIO 2026",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: AppColors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // === PULSANTE NEON CENTRATO ===
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_isExiting) return;
                          setState(() {
                            _isExiting = true;
                          });
                          widget.onEnter();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.accent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withOpacity(0.08),
                                AppColors.accentSecondary.withOpacity(0.08),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SCOPRI IL LIVE",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.white,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.accent.withOpacity(0.5),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.accent,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // === SOCIAL FOOTER ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialItem(
                          label: "@Torneo_Lozzo",
                          url: "https://www.instagram.com/Torneo_Lozzo/",
                        ),
                        _buildSocialItem(
                          label: "@fatti.di.lozzo",
                          url: "https://www.instagram.com/fatti.di.lozzo/",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialItem({required String label, required String url}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const InstagramIcon(size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstagramIcon extends StatelessWidget {
  final double size;

  const InstagramIcon({
    Key? key,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF9187C), // Pinkish red
            Color(0xFFBC2A8D), // Purple
            Color(0xFFE3372E), // Coral
            Color(0xFFFCAF45), // Orange-yellow
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.65,
        height: size * 0.65,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: size * 0.06),
          borderRadius: BorderRadius.circular(size * 0.18),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: size * 0.06),
              ),
            ),
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Container(
                width: size * 0.08,
                height: size * 0.08,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Gradient gradient;

  TrianglePainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.9)
      ..lineTo(0, size.height * 0.9)
      ..close();

    final shadowPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
