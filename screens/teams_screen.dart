import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/match_model.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/team_badge.dart';
import '../widgets/team_edit_modal.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({Key? key}) : super(key: key);

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _activeFilter = "all";

  void _openTeamModal(Team? team) {
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TeamEditModal(
          team: team,
          teams: provider.teams,
          matches: provider.matches,
          onClose: () => Navigator.pop(context),
          onSave: (updated) {
            if (team == null) {
              // Crea nuova squadra (calcola il max ID)
              final maxId = provider.teams.isEmpty
                  ? 0
                  : provider.teams.map((t) => t.id).reduce((a, b) => a > b ? a : b);
              updated = Team(
                id: maxId + 1,
                name: updated.name,
                group: updated.group,
                color: updated.color,
                players: updated.players,
              );
              provider.addTeam(updated);
            } else {
              // Modifica esistente
              provider.updateTeam(updated);
            }
            Navigator.pop(context);
          },
          onDelete: team == null
              ? null
              : (id) {
                  provider.deleteTeam(id);
                  Navigator.pop(context);
                },
        );
      },
    );
  }

  Widget _buildFilterPill(String value, String label, int count) {
    final isSel = _activeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.accent : Colors.transparent,
          border: Border.all(
            color: isSel ? AppColors.accent : AppColors.borderDark,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSel ? AppColors.black : AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);

    // Se non è admin, mostra la schermata di blocco
    if (!provider.adminMode) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🔒",
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Area Riservata Admin",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Accedi come admin per gestire le squadre del torneo. Tocca l'icona del lucchetto in alto a destra ed inserisci il PIN.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final groupCounts = {
      "A": provider.teams.where((t) => t.group == "A").length,
      "B": provider.teams.where((t) => t.group == "B").length,
      "C": provider.teams.where((t) => t.group == "C").length,
      "D": provider.teams.where((t) => t.group == "D").length,
    };

    final filteredTeams = _activeFilter == "all"
        ? provider.teams
        : provider.teams.where((t) => t.group == _activeFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filtri gironi con conteggio
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterPill("all", "TUTTI", provider.teams.length),
                const SizedBox(width: 8),
                _buildFilterPill("A", "GIRONE A", groupCounts["A"]!),
                const SizedBox(width: 8),
                _buildFilterPill("B", "GIRONE B", groupCounts["B"]!),
                const SizedBox(width: 8),
                _buildFilterPill("C", "GIRONE C", groupCounts["C"]!),
                const SizedBox(width: 8),
                _buildFilterPill("D", "GIRONE D", groupCounts["D"]!),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lista delle squadre
          if (filteredTeams.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Nessuna squadra presente in questa selezione",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTeams.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (c, i) {
                final team = filteredTeams[i];
                
                final hasPlayed = provider.matches.any((m) =>
                    (m.home == team.id || m.away == team.id) &&
                    (m.status == MatchStatus.done || m.status == MatchStatus.live));

                return GestureDetector(
                  onTap: () => _openTeamModal(team),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        TeamBadge(team: team, size: BadgeSize.sm),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Girone ${team.group} · ${team.players.length} giocatori",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasPlayed) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: const Text(
                              "Ha giocato",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          
          const SizedBox(height: 12),

          // Aggiungi Squadra (Dashed Border Button)
          GestureDetector(
            onTap: () => _openTeamModal(null),
            child: CustomPaint(
              painter: DashedRectPainter(
                color: AppColors.borderDark,
                radius: 16,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.accent, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Aggiungi Squadra",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // Riepilogo gironi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "SQUADRE PER GIRONE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.8,
                  children: ["A", "B", "C", "D"].map((g) {
                    final count = groupCounts[g]!;
                    final isOk = count == 5;
                    final isUnder = count < 5;

                    final countColor = isOk
                        ? AppColors.success
                        : isUnder
                            ? AppColors.error
                            : const Color(0xFFEA580C);

                    return Column(
                      children: [
                        Text(
                          "$count",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: countColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Girone $g",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOk
                              ? "✓ OK"
                              : isUnder
                                  ? "mancano ${5 - count}"
                                  : "extra",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: countColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter per disegnare il bordo tratteggiato senza dipendenze esterne
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final Path dashedPath = Path();
    double distance = 0.0;
    for (var metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashGap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap ||
      oldDelegate.radius != radius;
}
