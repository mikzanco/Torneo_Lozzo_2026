import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';
import '../utils/scorers_calculator.dart';

class ScorersScreen extends StatelessWidget {
  const ScorersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);
    final allScorers = calcScorers(provider.matches, provider.teams);
    final topScorers = allScorers.take(15).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant brand gradient visual bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: AppColors.logoGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Scorers list
          Expanded(
            child: topScorers.isEmpty
                ? const Center(
                    child: Text(
                      "Nessun marcatore ancora registrato",
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: topScorers.length,
                        separatorBuilder: (c, i) => const Divider(
                          color: AppColors.border,
                          height: 1,
                        ),
                        itemBuilder: (c, i) {
                          final s = topScorers[i];
                          
                          final posColor = i == 0
                              ? AppColors.accent
                              : i == 1
                                  ? AppColors.textSecondary
                                  : i == 2
                                      ? const Color(0xFFEA580C)
                                      : AppColors.textTertiary;

                          final gradients = TeamColors.gradients[s.teamColor.clamp(0, TeamColors.gradients.length - 1)];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Position rank
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    "${i + 1}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: posColor,
                                    ),
                                  ),
                                ),
                                
                                // Team Gradient Circle Avatar housing Maglia #
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: gradients,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradients[1].withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "#${s.n}",
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Player Name & Team Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.teamName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textTertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Goal tally count
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${s.goals}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.accent,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "GOL",
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMuted,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
