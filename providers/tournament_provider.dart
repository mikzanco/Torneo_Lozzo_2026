import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/match_model.dart';
import '../models/scorer.dart';
import '../data/initial_data.dart';
import '../utils/standings_calculator.dart';

class TournamentProvider extends ChangeNotifier {
  List<Team> teams = [];
  List<MatchModel> matches = [];
  bool adminMode = false;
  bool loaded = false;
  bool goalFlash = false;

  // Caricamento da SharedPreferences
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final rawTeams = prefs.getString('lozzo-teams');
      if (rawTeams != null) {
        final list = jsonDecode(rawTeams) as List;
        teams = list.map((j) => Team.fromJson(j as Map<String, dynamic>)).toList();
      } else {
        teams = List.from(INITIAL_TEAMS);
        await saveTeams();
      }

      final rawMatches = prefs.getString('lozzo-matches');
      if (rawMatches != null) {
        final list = jsonDecode(rawMatches) as List;
        matches = list.map((j) => MatchModel.fromJson(j as Map<String, dynamic>)).toList();
      } else {
        matches = List.from(INITIAL_MATCHES);
        await saveMatches();
      }
    } catch (e) {
      // Fallback in caso di errori di lettura
      teams = List.from(INITIAL_TEAMS);
      matches = List.from(INITIAL_MATCHES);
    }
    loaded = true;
    notifyListeners();
  }

  // Salvataggio
  Future<void> saveMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'lozzo-matches',
        jsonEncode(matches.map((m) => m.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> saveTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'lozzo-teams',
        jsonEncode(teams.map((t) => t.toJson()).toList()),
      );
    } catch (_) {}
  }

  // Admin
  bool verifyPin(String pin) => pin == "1234";

  void toggleAdmin() {
    adminMode = !adminMode;
    notifyListeners();
  }

  void setAdminMode(bool value) {
    adminMode = value;
    notifyListeners();
  }

  // Match actions
  void startMatch(String matchId) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      final original = matches[idx];
      matches[idx] = MatchModel(
        id: original.id,
        group: original.group,
        home: original.home,
        away: original.away,
        day: original.day,
        time: original.time,
        status: MatchStatus.live,
        homeGoals: 0,
        awayGoals: 0,
        scorers: [],
        phase: original.phase,
      );
      saveMatches();
      notifyListeners();
    }
  }

  void addGoal(String matchId, String side, ScorerEvent scorer) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      final match = matches[idx];
      final newScorers = List<ScorerEvent>.from(match.scorers)..add(scorer);
      
      int homeG = match.homeGoals;
      int awayG = match.awayGoals;
      if (side == 'home') {
        homeG++;
      } else {
        awayG++;
      }

      matches[idx] = MatchModel(
        id: match.id,
        group: match.group,
        home: match.home,
        away: match.away,
        day: match.day,
        time: match.time,
        status: match.status,
        homeGoals: homeG,
        awayGoals: awayG,
        scorers: newScorers,
        phase: match.phase,
      );
      
      triggerGoalFlash();
      saveMatches();
      notifyListeners();
    }
  }

  void endMatch(String matchId) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      matches[idx].status = MatchStatus.done;
      
      // Se è una partita del Bracket, esegui l'avanzamento dei vincitori
      if (matches[idx].group == 'KO') {
        endBracketMatch(matchId);
      } else {
        saveMatches();
        notifyListeners();
      }
    }
  }

  // Bracket
  void generateBracket() {
    // Qualificate: prime 4 di ogni girone
    final qA = calcStandings(teams, matches, "A");
    final qB = calcStandings(teams, matches, "B");
    final qC = calcStandings(teams, matches, "C");
    final qD = calcStandings(teams, matches, "D");

    if (qA.length < 4 || qB.length < 4 || qC.length < 4 || qD.length < 4) return;

    // Seeding logic QF1-QF8
    // QF1: 1°A vs 4°D | QF2: 1°B vs 4°C | QF3: 1°C vs 4°B | QF4: 1°D vs 4°A
    // QF5: 2°A vs 3°D | QF6: 2°B vs 3°C | QF7: 2°C vs 3°B | QF8: 2°D vs 3°A
    final newMatches = [
      MatchModel(id: "QF1", group: "KO", home: qA[0].id, away: qD[3].id, day: "Dom 5 Lug", time: "14:00", phase: "QF"),
      MatchModel(id: "QF2", group: "KO", home: qB[0].id, away: qC[3].id, day: "Dom 5 Lug", time: "14:30", phase: "QF"),
      MatchModel(id: "QF3", group: "KO", home: qC[0].id, away: qB[3].id, day: "Dom 5 Lug", time: "15:00", phase: "QF"),
      MatchModel(id: "QF4", group: "KO", home: qD[0].id, away: qA[3].id, day: "Dom 5 Lug", time: "15:30", phase: "QF"),
      MatchModel(id: "QF5", group: "KO", home: qA[1].id, away: qD[2].id, day: "Dom 5 Lug", time: "16:00", phase: "QF"),
      MatchModel(id: "QF6", group: "KO", home: qB[1].id, away: qC[2].id, day: "Dom 5 Lug", time: "16:30", phase: "QF"),
      MatchModel(id: "QF7", group: "KO", home: qC[1].id, away: qB[2].id, day: "Dom 5 Lug", time: "17:00", phase: "QF"),
      MatchModel(id: "QF8", group: "KO", home: qD[1].id, away: qA[2].id, day: "Dom 5 Lug", time: "17:30", phase: "QF"),

      // Placeholders per SF, Finale, Finale 3° posto
      MatchModel(id: "SF1", group: "KO", home: null, away: null, day: "Dom 5 Lug", time: "19:00", phase: "SF"),
      MatchModel(id: "SF2", group: "KO", home: null, away: null, day: "Dom 5 Lug", time: "19:30", phase: "SF"),
      MatchModel(id: "F3", group: "KO", home: null, away: null, day: "Dom 5 Lug", time: "20:30", phase: "F"),
      MatchModel(id: "F", group: "KO", home: null, away: null, day: "Dom 5 Lug", time: "21:00", phase: "F"),
    ];

    // Rimuoviamo eventuali vecchie partite KO e inseriamo quelle nuove
    matches.removeWhere((m) => m.group == "KO");
    matches.addAll(newMatches);

    saveMatches();
    notifyListeners();
  }

  void endBracketMatch(String matchId) {
    final mIdx = matches.indexWhere((x) => x.id == matchId);
    if (mIdx == -1) return;
    final m = matches[mIdx];
    if (m.homeGoals == m.awayGoals) return; // Non ammessi pareggi in KO

    final int winner = m.homeGoals > m.awayGoals ? m.home! : m.away!;
    final int loser  = m.homeGoals > m.awayGoals ? m.away! : m.home!;

    // Avanzamento vincitore
    if (matchId == "QF1" || matchId == "QF2") {
      final sfIdx = matches.indexWhere((x) => x.id == "SF1");
      if (sfIdx != -1) {
        if (matchId == "QF1") {
          matches[sfIdx].home = winner;
        } else {
          matches[sfIdx].away = winner;
        }
      }
    }
    
    if (matchId == "QF3" || matchId == "QF4") {
      final sfIdx = matches.indexWhere((x) => x.id == "SF2");
      if (sfIdx != -1) {
        if (matchId == "QF3") {
          matches[sfIdx].home = winner;
        } else {
          matches[sfIdx].away = winner;
        }
      }
    }

    if (matchId == "QF5" || matchId == "QF6") {
      final sfIdx = matches.indexWhere((x) => x.id == "SF1");
      if (sfIdx != -1) {
        final sf = matches[sfIdx];
        // Assegna al primo slot SF1 libero (home se null, altrimenti away)
        if (sf.home == null) {
          matches[sfIdx].home = winner;
        } else {
          matches[sfIdx].away = winner;
        }
      }
    }

    if (matchId == "QF7" || matchId == "QF8") {
      final sfIdx = matches.indexWhere((x) => x.id == "SF2");
      if (sfIdx != -1) {
        final sf = matches[sfIdx];
        // Assegna al primo slot SF2 libero (home se null, altrimenti away)
        if (sf.home == null) {
          matches[sfIdx].home = winner;
        } else {
          matches[sfIdx].away = winner;
        }
      }
    }

    if (matchId == "SF1") {
      final fIdx = matches.indexWhere((x) => x.id == "F");
      final f3Idx = matches.indexWhere((x) => x.id == "F3");
      if (fIdx != -1) matches[fIdx].home = winner;
      if (f3Idx != -1) matches[f3Idx].home = loser;
    }

    if (matchId == "SF2") {
      final fIdx = matches.indexWhere((x) => x.id == "F");
      final f3Idx = matches.indexWhere((x) => x.id == "F3");
      if (fIdx != -1) matches[fIdx].away = winner;
      if (f3Idx != -1) matches[f3Idx].away = loser;
    }

    saveMatches();
    notifyListeners();
  }

  // Team CRUD
  void addTeam(Team team) {
    teams.add(team);
    saveTeams();
    notifyListeners();
  }

  void updateTeam(Team team) {
    final idx = teams.indexWhere((t) => t.id == team.id);
    if (idx != -1) {
      teams[idx] = team;
      saveTeams();
      notifyListeners();
    }
  }

  void deleteTeam(int id) {
    teams.removeWhere((t) => t.id == id);
    saveTeams();
    notifyListeners();
  }

  // Goal flash
  void triggerGoalFlash() {
    goalFlash = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 700), () {
      goalFlash = false;
      notifyListeners();
    });
  }
}
