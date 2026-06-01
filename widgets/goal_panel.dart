import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../models/team.dart';
import '../models/scorer.dart';
import '../providers/tournament_provider.dart';
import '../theme/app_theme.dart';
import 'team_badge.dart';

class GoalPanel extends StatefulWidget {
  final MatchModel match;
  final String side; // 'home' or 'away'
  final int timer;

  const GoalPanel({
    Key? key,
    required this.match,
    required this.side,
    required this.timer,
  }) : super(key: key);

  @override
  State<GoalPanel> createState() => _GoalPanelState();
}

class _GoalPanelState extends State<GoalPanel> {
  bool _isOwnGoal = false;
  final TextEditingController _numberController = TextEditingController();
  late TextEditingController _minuteController;
  
  bool _showError = false;
  String? _resolvedPlayerName;

  @override
  void initState() {
    super.initState();
    _minuteController = TextEditingController(text: widget.timer.toString());
    _numberController.addListener(_validatePlayerNumber);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _validatePlayerNumber() {
    final teamId = widget.side == 'home' ? widget.match.home : widget.match.away;
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final team = provider.teams.firstWhere((t) => t.id == teamId, orElse: () => Team(id: 0, name: "", group: "", color: 0, players: []));
    
    final numStr = _numberController.text.trim();
    if (numStr.isEmpty) {
      setState(() {
        _resolvedPlayerName = null;
        _showError = false;
      });
      return;
    }

    final n = int.tryParse(numStr);
    if (n == null) {
      setState(() {
        _resolvedPlayerName = null;
        _showError = true;
      });
      return;
    }

    final playerIdx = team.players.indexWhere((p) => p.n == n);
    if (playerIdx != -1) {
      setState(() {
        _resolvedPlayerName = team.players[playerIdx].name;
        _showError = false;
      });
    } else {
      setState(() {
        _resolvedPlayerName = null;
        _showError = true;
      });
    }
  }

  void _confirmGoal() {
    final teamId = widget.side == 'home' ? widget.match.home : widget.match.away;
    if (teamId == null) return;
    
    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final team = provider.teams.firstWhere((t) => t.id == teamId);

    final min = int.tryParse(_minuteController.text.trim()) ?? widget.timer;

    ScorerEvent scorer;
    if (_isOwnGoal) {
      scorer = ScorerEvent(team: teamId, own: true, min: min);
    } else {
      final numStr = _numberController.text.trim();
      final n = int.tryParse(numStr);
      if (n == null) {
        setState(() => _showError = true);
        return;
      }

      final player = team.players.firstWhere((p) => p.n == n, orElse: () => throw Exception());
      scorer = ScorerEvent(
        team: teamId,
        player: player.name,
        n: n,
        min: min,
        own: false,
      );
    }

    // Aggiungi gol e chiudi
    provider.addGoal(widget.match.id, widget.side, scorer);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);
    final teamId = widget.side == 'home' ? widget.match.home : widget.match.away;
    final team = provider.teams.firstWhere(
      (t) => t.id == teamId,
      orElse: () => Team(id: 0, name: "?", group: "?", color: 0, players: []),
    );

    final isFormValid = _isOwnGoal || _resolvedPlayerName != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.bottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header con Badge squadra
            Row(
              children: [
                TeamBadge(team: team, size: BadgeSize.sm),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "⚽ Goal — ${team.name}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Inserisci i dettagli del marcatore",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Toggle Marcatore / Autogol
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isOwnGoal = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isOwnGoal ? AppColors.accent : AppColors.surfaceBg,
                        border: Border.all(
                          color: !_isOwnGoal ? AppColors.accent : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Marcatore",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: !_isOwnGoal ? AppColors.black : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isOwnGoal = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isOwnGoal ? AppColors.error : AppColors.surfaceBg,
                        border: Border.all(
                          color: _isOwnGoal ? AppColors.error : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Autogol",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _isOwnGoal ? AppColors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Se regolare, inserisci il numero di maglia
            if (!_isOwnGoal) ...[
              const Text(
                "NUMERO MAGLIA",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Es: 9",
                  hintStyle: const TextStyle(color: AppColors.textDim),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Feedback del marcatore
              SizedBox(
                height: 18,
                child: Center(
                  child: _resolvedPlayerName != null
                      ? Text(
                          "✓ $_resolvedPlayerName",
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        )
                      : _showError
                          ? const Text(
                              "⚠ Numero non trovato nella rosa",
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Minuto di gioco
            const Text(
              "MINUTO",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _minuteController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pulsante di conferma
            GestureDetector(
              onTap: isFormValid ? _confirmGoal : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isFormValid ? 1.0 : 0.4,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "✓ Conferma Goal",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Pulsante annulla
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annulla",
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
