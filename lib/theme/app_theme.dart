import 'package:flutter/material.dart';

class AppColors {
  // === BACKGROUND ===
  static const Color scaffoldBg =
      Color(0xFF0E131F); // Profondo Blu Ardesia dal logo
  static const Color cardBg = Color(0xFF171D2F); // Sfondo delle card coordinato
  static const Color surfaceBg = Color(0xFF222B45); // Elementi di superficie
  static const Color inputBg = Color(0xFF222B45); // Campi di input

  // === BORDI ===
  static const Color border = Color(0xFF232D48); // Bordi scuri coordinati
  static const Color borderLight = Color(0x99232D48); // Bordi trasparenti
  static const Color borderDark = Color(0xFF3A4B75); // Bordi evidenziati

  // === TESTO ===
  static const Color textPrimary = Color(0xFFF4F4F5); // Bianco primario
  static const Color textSecondary = Color(0xFFD4D4D8); // Grigio chiaro
  static const Color textTertiary =
      Color(0xFF8A99AD); // Grigio ardesia leggibile
  static const Color textMuted =
      Color(0xFF5E6E82); // Grigio scuro per dettagli secondari
  static const Color textDim = Color(0xFF3F4E64); // Testo molto attenuato

  // === ACCENT ===
  static const Color accent =
      Color(0xFF00E5FF); // Ciano/Azzurro Neon primario del logo
  static const Color accentDark =
      Color(0xFF006064); // Ciano scuro per sfondi/bottoni premuti
  static const Color accentSecondary =
      Color(0xFFEC358D); // Rosa/Magenta Neon del logo
  static const Color accentSecondaryDark = Color(0xFF880E4F); // Magenta scuro

  // === GRADIENTI ===
  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFFEC358D), Color(0xFF00E5FF)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  // === STATO ===
  static const Color success =
      Color(0xFF00E676); // Verde neon per successi/vittorie
  static const Color warning =
      Color(0xFFFFD600); // Giallo per ammonizioni/pareggi
  static const Color error =
      Color(0xFFFF1744); // Rosso neon per errori/sconfitte
  static const Color live = Color(0xFFFF1744); // Rosso live
  static const Color liveBg = Color(0xFFFF8A80); // Sfondo live

  // === FORM DOTS ===
  static const Color dotWin = Color(0xFF00E676); // Vittoria
  static const Color dotDraw = Color(0xFFFFD600); // Pareggio
  static const Color dotLoss = Color(0xFFFF1744); // Sconfitta

  // === CHIP GIRONE ===
  static const Color chipA = Color(0xFF00E5FF); // Ciano
  static const Color chipB = Color(0xFFFFD600); // Giallo
  static const Color chipC = Color(0xFFEC358D); // Magenta
  static const Color chipD = Color(0xFF00E676); // Smeraldo

  // === BIANCO ===
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

class TeamColors {
  static const List<List<Color>> gradients = [
    [
      Color(0xFF1E3A5F),
      Color(0xFF1D4ED8)
    ], //  0 - Blu scuro     (blue-900 → blue-700)
    [
      Color(0xFF7F1D1D),
      Color(0xFFB91C1C)
    ], //  1 - Rosso          (red-900 → red-700)
    [
      Color(0xFF14532D),
      Color(0xFF15803D)
    ], //  2 - Verde          (green-900 → green-700)
    [
      Color(0xFF9A3412),
      Color(0xFFEA580C)
    ], //  3 - Arancione      (orange-800 → orange-600)
    [
      Color(0xFF581C87),
      Color(0xFF7E22CE)
    ], //  4 - Viola          (purple-900 → purple-700)
    [
      Color(0xFF115E59),
      Color(0xFF0D9488)
    ], //  5 - Verde acqua    (teal-800 → teal-600)
    [
      Color(0xFF334155),
      Color(0xFF64748B)
    ], //  6 - Grigio         (slate-700 → slate-500)
    [
      Color(0xFF831843),
      Color(0xFFBE185D)
    ], //  7 - Rosa           (pink-900 → pink-700)
    [
      Color(0xFF312E81),
      Color(0xFF4338CA)
    ], //  8 - Indaco         (indigo-900 → indigo-700)
    [
      Color(0xFF3F6212),
      Color(0xFF65A30D)
    ], //  9 - Verde lime     (lime-800 → lime-600)
    [
      Color(0xFF155E75),
      Color(0xFF0891B2)
    ], // 10 - Ciano          (cyan-800 → cyan-600)
    [
      Color(0xFF92400E),
      Color(0xFFD97706)
    ], // 11 - Ambra          (amber-800 → amber-600)
    [
      Color(0xFF881337),
      Color(0xFFBE123C)
    ], // 12 - Rosa scuro     (rose-900 → rose-700)
    [
      Color(0xFF4C1D95),
      Color(0xFF6D28D9)
    ], // 13 - Violetto       (violet-900 → violet-700)
    [
      Color(0xFF065F46),
      Color(0xFF059669)
    ], // 14 - Smeraldo       (emerald-800 → emerald-600)
    [
      Color(0xFF0C4A6E),
      Color(0xFF0284C7)
    ], // 15 - Azzurro        (sky-900 → sky-700)
    [
      Color(0xFF701A75),
      Color(0xFFA21CAF)
    ], // 16 - Fucsia         (fuchsia-900 → fuchsia-700)
    [
      Color(0xFF854D0E),
      Color(0xFFCA8A04)
    ], // 17 - Giallo         (yellow-800 → yellow-600)
    [
      Color(0xFF991B1B),
      Color(0xFFC2410C)
    ], // 18 - Rosso-arancio  (red-800 → orange-700)
    [
      Color(0xFF1E40AF),
      Color(0xFF0891B2)
    ], // 19 - Blu-ciano      (blue-800 → cyan-700)
  ];
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontWeight: FontWeight.w900, // font-black
    color: AppColors.white,
    letterSpacing: -0.5, // tracking-tight
  );

  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textTertiary,
    letterSpacing: 2.0, // tracking-widest
  );

  static const TextStyle score = TextStyle(
    fontSize: 48, // text-6xl
    fontWeight: FontWeight.w900,
    color: AppColors.white,
  );

  static const TextStyle scoreDivider = TextStyle(
    fontSize: 24, // text-3xl
    fontWeight: FontWeight.w900,
    color: AppColors.textMuted,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardBg,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(16), // rounded-2xl
  );

  static BoxDecoration pill({bool active = false}) => BoxDecoration(
        color: active ? AppColors.accent : Colors.transparent,
        border:
            Border.all(color: active ? AppColors.accent : AppColors.borderDark),
        borderRadius: BorderRadius.circular(999), // rounded-full
      );

  static BoxDecoration bottomSheet = const BoxDecoration(
    color: AppColors.cardBg,
    borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)), // rounded-t-3xl
  );
}
