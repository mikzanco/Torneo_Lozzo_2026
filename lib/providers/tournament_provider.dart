import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String adminPin = "123456"; // PIN predefinito

  StreamSubscription? _teamsSubscription;
  StreamSubscription? _matchesSubscription;
  bool _teamsLoaded = false;
  bool _matchesLoaded = false;

  // Caricamento in tempo reale da Firestore
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('lozzo-admin-pin');
      if (savedPin != null) {
        adminPin = savedPin;
      }
    } catch (_) {}

    // Ascolta le modifiche alle squadre in tempo reale
    _teamsSubscription = FirebaseFirestore.instance
        .collection('teams')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // Se il database è vuoto su Firestore, carica i dati iniziali
        await _uploadInitialTeams();
      } else {
        teams = snapshot.docs.map((doc) => Team.fromJson(doc.data())).toList();
        teams.sort((a, b) => a.id.compareTo(b.id));
        _teamsLoaded = true;
        _checkLoaded();
      }
    }, onError: (e) {
      debugPrint("Errore caricamento squadre: $e");
    });

    // Ascolta le modifiche alle partite in tempo reale
    _matchesSubscription = FirebaseFirestore.instance
        .collection('matches')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // Se il database è vuoto su Firestore, carica i dati iniziali
        await _uploadInitialMatches();
      } else {
        matches = snapshot.docs
            .map((doc) => MatchModel.fromJson(doc.data()))
            .toList();

        // Ordinamento corretto per le partite
        final idOrder = [
          for (int i = 1; i <= 8; i++) "A$i",
          for (int i = 1; i <= 8; i++) "B$i",
          for (int i = 1; i <= 8; i++) "C$i",
          for (int i = 1; i <= 8; i++) "D$i",
          for (int i = 1; i <= 8; i++) "QF$i",
          "SF1",
          "SF2",
          "F3",
          "F"
        ];
        matches.sort((a, b) {
          final idxA = idOrder.indexOf(a.id);
          final idxB = idOrder.indexOf(b.id);
          if (idxA != -1 && idxB != -1) {
            return idxA.compareTo(idxB);
          }
          return a.id.compareTo(b.id);
        });
        _matchesLoaded = true;
        _checkLoaded();
      }
    }, onError: (e) {
      debugPrint("Errore caricamento partite: $e");
    });
  }

  void _checkLoaded() {
    if (_teamsLoaded && _matchesLoaded) {
      loaded = true;
      notifyListeners();
    }
  }

  Future<void> _uploadInitialTeams() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final team in INITIAL_TEAMS) {
      final docRef = FirebaseFirestore.instance
          .collection('teams')
          .doc(team.id.toString());
      batch.set(docRef, team.toJson());
    }
    await batch.commit();
  }

  Future<void> _uploadInitialMatches() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final match in INITIAL_MATCHES) {
      final docRef =
          FirebaseFirestore.instance.collection('matches').doc(match.id);
      batch.set(docRef, match.toJson());
    }
    await batch.commit();
  }

  // Resetta tutto il torneo ai dati di fabbrica
  Future<void> resetTournament() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Elimina tutti i match correnti
      for (final m in matches) {
        final docRef =
            FirebaseFirestore.instance.collection('matches').doc(m.id);
        batch.delete(docRef);
      }

      // Ricrea solo i match dei gironi iniziali resettati
      final cleanMatches = INITIAL_MATCHES.map((m) {
        return MatchModel(
          id: m.id,
          group: m.group,
          home: m.home,
          away: m.away,
          day: m.day,
          time: m.time,
          status: MatchStatus.sched,
          homeGoals: 0,
          awayGoals: 0,
          scorers: [],
          phase: m.phase,
        );
      }).toList();

      // Rimuovi il tabellone KO
      cleanMatches.removeWhere((m) => m.group == "KO");

      for (final m in cleanMatches) {
        final docRef =
            FirebaseFirestore.instance.collection('matches').doc(m.id);
        batch.set(docRef, m.toJson());
      }

      await batch.commit();
      adminMode = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Errore reset torneo: $e");
    }
  }

  // Admin PIN management
  bool verifyPin(String pin) => pin == adminPin;

  Future<void> changePin(String newPin) async {
    adminPin = newPin;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lozzo-admin-pin', newPin);
    } catch (_) {}
    notifyListeners();
  }

  void toggleAdmin() {
    adminMode = !adminMode;
    notifyListeners();
  }

  void setAdminMode(bool value) {
    adminMode = value;
    notifyListeners();
  }

  // Match Actions
  void startMatch(String matchId) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      final original = matches[idx];
      final updated = MatchModel(
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
      FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .set(updated.toJson());
    }
  }

  void addGoal(String matchId, String side, ScorerEvent scorer) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      final match = matches[idx];
      final newScorers = List<ScorerEvent>.from(match.scorers)..add(scorer);

      int homeG = match.homeGoals;
      int awayG = match.awayGoals;

      if (scorer.own) {
        if (side == 'home') {
          awayG++;
        } else {
          homeG++;
        }
      } else {
        if (side == 'home') {
          homeG++;
        } else {
          awayG++;
        }
      }

      final updated = MatchModel(
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
        homeFouls: match.homeFouls,
        awayFouls: match.awayFouls,
      );

      triggerGoalFlash();
      FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .set(updated.toJson());
    }
  }

  void updateFouls(String matchId, String side, int delta) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      final match = matches[idx];
      int homeF = match.homeFouls;
      int awayF = match.awayFouls;

      if (side == 'home') {
        homeF = (homeF + delta).clamp(0, 99);
      } else {
        awayF = (awayF + delta).clamp(0, 99);
      }

      final updated = MatchModel(
        id: match.id,
        group: match.group,
        home: match.home,
        away: match.away,
        day: match.day,
        time: match.time,
        status: match.status,
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        scorers: match.scorers,
        phase: match.phase,
        homeFouls: homeF,
        awayFouls: awayF,
      );

      FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .set(updated.toJson());
    }
  }

  void endMatch(String matchId) {
    final idx = matches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      final match = matches[idx];
      final updated = MatchModel(
        id: match.id,
        group: match.group,
        home: match.home,
        away: match.away,
        day: match.day,
        time: match.time,
        status: MatchStatus.done,
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        scorers: match.scorers,
        phase: match.phase,
        homeFouls: match.homeFouls,
        awayFouls: match.awayFouls,
      );

      if (match.group == 'KO') {
        _endBracketMatch(updated);
      } else {
        FirebaseFirestore.instance
            .collection('matches')
            .doc(matchId)
            .set(updated.toJson());
      }
    }
  }

  // Bracket Seeding
  void generateBracket() async {
    final qA = calcStandings(teams, matches, "A");
    final qB = calcStandings(teams, matches, "B");
    final qC = calcStandings(teams, matches, "C");
    final qD = calcStandings(teams, matches, "D");

    if (qA.length < 4 || qB.length < 4 || qC.length < 4 || qD.length < 4) return;

    final newMatches = [
      MatchModel(
          id: "QF1",
          group: "KO",
          home: qA[0].id,
          away: qD[3].id,
          day: "Dom 5 Lug",
          time: "14:00",
          phase: "QF"),
      MatchModel(
          id: "QF2",
          group: "KO",
          home: qB[0].id,
          away: qC[3].id,
          day: "Dom 5 Lug",
          time: "14:30",
          phase: "QF"),
      MatchModel(
          id: "QF3",
          group: "KO",
          home: qC[0].id,
          away: qB[3].id,
          day: "Dom 5 Lug",
          time: "15:00",
          phase: "QF"),
      MatchModel(
          id: "QF4",
          group: "KO",
          home: qD[0].id,
          away: qA[3].id,
          day: "Dom 5 Lug",
          time: "15:30",
          phase: "QF"),
      MatchModel(
          id: "QF5",
          group: "KO",
          home: qA[1].id,
          away: qD[2].id,
          day: "Dom 5 Lug",
          time: "16:00",
          phase: "QF"),
      MatchModel(
          id: "QF6",
          group: "KO",
          home: qB[1].id,
          away: qC[2].id,
          day: "Dom 5 Lug",
          time: "16:30",
          phase: "QF"),
      MatchModel(
          id: "QF7",
          group: "KO",
          home: qC[1].id,
          away: qB[2].id,
          day: "Dom 5 Lug",
          time: "17:00",
          phase: "QF"),
      MatchModel(
          id: "QF8",
          group: "KO",
          home: qD[1].id,
          away: qA[2].id,
          day: "Dom 5 Lug",
          time: "17:30",
          phase: "QF"),
      MatchModel(
          id: "SF1",
          group: "KO",
          home: null,
          away: null,
          day: "Dom 5 Lug",
          time: "19:00",
          phase: "SF"),
      MatchModel(
          id: "SF2",
          group: "KO",
          home: null,
          away: null,
          day: "Dom 5 Lug",
          time: "19:30",
          phase: "SF"),
      MatchModel(
          id: "F3",
          group: "KO",
          home: null,
          away: null,
          day: "Dom 5 Lug",
          time: "20:30",
          phase: "F"),
      MatchModel(
          id: "F",
          group: "KO",
          home: null,
          away: null,
          day: "Dom 5 Lug",
          time: "21:00",
          phase: "F"),
    ];

    final batch = FirebaseFirestore.instance.batch();

    // Rimuoviamo eventuali vecchie partite KO da Firestore
    final koMatchIds =
        matches.where((m) => m.group == "KO").map((m) => m.id).toList();
    for (final id in koMatchIds) {
      final docRef = FirebaseFirestore.instance.collection('matches').doc(id);
      batch.delete(docRef);
    }

    // Aggiungiamo le nuove
    for (final m in newMatches) {
      final docRef = FirebaseFirestore.instance.collection('matches').doc(m.id);
      batch.set(docRef, m.toJson());
    }

    await batch.commit();
  }

  void _endBracketMatch(MatchModel completedMatch) async {
    if (completedMatch.homeGoals == completedMatch.awayGoals) return;

    final batch = FirebaseFirestore.instance.batch();

    // Salva la partita completata
    final matchDoc = FirebaseFirestore.instance
        .collection('matches')
        .doc(completedMatch.id);
    batch.set(matchDoc, completedMatch.toJson());

    final int winner =
        completedMatch.homeGoals > completedMatch.awayGoals ? completedMatch.home! : completedMatch.away!;
    final int loser =
        completedMatch.homeGoals > completedMatch.awayGoals ? completedMatch.away! : completedMatch.home!;

    final Map<String, MatchModel> updates = {};

    if (completedMatch.id == "QF1" || completedMatch.id == "QF2") {
      final sf = matches.firstWhere((x) => x.id == "SF1");
      final updatedSf = MatchModel(
        id: sf.id,
        group: sf.group,
        home: completedMatch.id == "QF1" ? winner : sf.home,
        away: completedMatch.id == "QF2" ? winner : sf.away,
        day: sf.day,
        time: sf.time,
        status: sf.status,
        homeGoals: sf.homeGoals,
        awayGoals: sf.awayGoals,
        scorers: sf.scorers,
        phase: sf.phase,
      );
      updates["SF1"] = updatedSf;
    }

    if (completedMatch.id == "QF3" || completedMatch.id == "QF4") {
      final sf = matches.firstWhere((x) => x.id == "SF2");
      final updatedSf = MatchModel(
        id: sf.id,
        group: sf.group,
        home: completedMatch.id == "QF3" ? winner : sf.home,
        away: completedMatch.id == "QF4" ? winner : sf.away,
        day: sf.day,
        time: sf.time,
        status: sf.status,
        homeGoals: sf.homeGoals,
        awayGoals: sf.awayGoals,
        scorers: sf.scorers,
        phase: sf.phase,
      );
      updates["SF2"] = updatedSf;
    }

    if (completedMatch.id == "QF5" || completedMatch.id == "QF6") {
      final sf = updates["SF1"] ?? matches.firstWhere((x) => x.id == "SF1");
      final homeVal = sf.home ?? winner;
      final awayVal = sf.home == null ? sf.away : (sf.away ?? winner);

      final updatedSf = MatchModel(
        id: sf.id,
        group: sf.group,
        home: homeVal,
        away: awayVal,
        day: sf.day,
        time: sf.time,
        status: sf.status,
        homeGoals: sf.homeGoals,
        awayGoals: sf.awayGoals,
        scorers: sf.scorers,
        phase: sf.phase,
      );
      updates["SF1"] = updatedSf;
    }

    if (completedMatch.id == "QF7" || completedMatch.id == "QF8") {
      final sf = updates["SF2"] ?? matches.firstWhere((x) => x.id == "SF2");
      final homeVal = sf.home ?? winner;
      final awayVal = sf.home == null ? sf.away : (sf.away ?? winner);

      final updatedSf = MatchModel(
        id: sf.id,
        group: sf.group,
        home: homeVal,
        away: awayVal,
        day: sf.day,
        time: sf.time,
        status: sf.status,
        homeGoals: sf.homeGoals,
        awayGoals: sf.awayGoals,
        scorers: sf.scorers,
        phase: sf.phase,
      );
      updates["SF2"] = updatedSf;
    }

    if (completedMatch.id == "SF1") {
      final f = matches.firstWhere((x) => x.id == "F");
      final f3 = matches.firstWhere((x) => x.id == "F3");
      updates["F"] = MatchModel(
        id: f.id,
        group: f.group,
        home: winner,
        away: f.away,
        day: f.day,
        time: f.time,
        status: f.status,
        homeGoals: f.homeGoals,
        awayGoals: f.awayGoals,
        scorers: f.scorers,
        phase: f.phase,
      );
      updates["F3"] = MatchModel(
        id: f3.id,
        group: f3.group,
        home: loser,
        away: f3.away,
        day: f3.day,
        time: f3.time,
        status: f3.status,
        homeGoals: f3.homeGoals,
        awayGoals: f3.awayGoals,
        scorers: f3.scorers,
        phase: f3.phase,
      );
    }

    if (completedMatch.id == "SF2") {
      final f = updates["F"] ?? matches.firstWhere((x) => x.id == "F");
      final f3 = updates["F3"] ?? matches.firstWhere((x) => x.id == "F3");
      updates["F"] = MatchModel(
        id: f.id,
        group: f.group,
        home: f.home,
        away: winner,
        day: f.day,
        time: f.time,
        status: f.status,
        homeGoals: f.homeGoals,
        awayGoals: f.awayGoals,
        scorers: f.scorers,
        phase: f.phase,
      );
      updates["F3"] = MatchModel(
        id: f3.id,
        group: f3.group,
        home: f3.home,
        away: loser,
        day: f3.day,
        time: f3.time,
        status: f3.status,
        homeGoals: f3.homeGoals,
        awayGoals: f3.awayGoals,
        scorers: f3.scorers,
        phase: f3.phase,
      );
    }

    // Applica tutte le modifiche
    updates.forEach((id, matchModel) {
      final docRef = FirebaseFirestore.instance.collection('matches').doc(id);
      batch.set(docRef, matchModel.toJson());
    });

    await batch.commit();
  }

  // Team CRUD in Firestore
  void addTeam(Team team) {
    FirebaseFirestore.instance
        .collection('teams')
        .doc(team.id.toString())
        .set(team.toJson());
  }

  void updateTeam(Team team) {
    FirebaseFirestore.instance
        .collection('teams')
        .doc(team.id.toString())
        .set(team.toJson());
  }

  void deleteTeam(int id) {
    FirebaseFirestore.instance
        .collection('teams')
        .doc(id.toString())
        .delete();
  }

  // Clean subscriptions
  @override
  void dispose() {
    _teamsSubscription?.cancel();
    _matchesSubscription?.cancel();
    super.dispose();
  }

  // Goal Flash Animation
  void triggerGoalFlash() {
    goalFlash = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 700), () {
      goalFlash = false;
      notifyListeners();
    });
  }
}
