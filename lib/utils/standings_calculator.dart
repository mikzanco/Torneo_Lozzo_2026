import '../models/team.dart';
import '../models/match_model.dart';

class StandingRow {
  final int id;
  final String name;
  final int color;
  int g = 0; // Giocate
  int w = 0; // Vittorie
  int d = 0; // Pareggi
  int l = 0; // Sconfitte
  int gf = 0; // Gol Fatti
  int ga = 0; // Gol Subiti
  int pts = 0; // Punti
  List<String> form = []; // "w", "d", "l"

  int get goalDiff => gf - ga;

  StandingRow({required this.id, required this.name, required this.color});
}

List<StandingRow> calcStandings(List<Team> teams, List<MatchModel> matches, String group) {
  // Filtra squadre del girone
  final groupTeams = teams.where((t) => t.group == group).toList();

  // Inizializza mappa stats
  final Map<int, StandingRow> stats = {
    for (var t in groupTeams)
      t.id: StandingRow(id: t.id, name: t.name, color: t.color)
  };

  // Itera partite "done" del girone
  final groupMatches = matches.where((m) => m.group == group && m.status == MatchStatus.done);

  for (var m in groupMatches) {
    final h = stats[m.home];
    final a = stats[m.away];
    if (h == null || a == null) continue;

    h.g++;
    a.g++;
    h.gf += m.homeGoals;
    h.ga += m.awayGoals;
    a.gf += m.awayGoals;
    a.ga += m.homeGoals;

    if (m.homeGoals > m.awayGoals) {
      h.w++;
      h.pts += 3;
      h.form.add("w");
      a.l++;
      a.form.add("l");
    } else if (m.homeGoals < m.awayGoals) {
      a.w++;
      a.pts += 3;
      a.form.add("w");
      h.l++;
      h.form.add("l");
    } else {
      h.d++;
      a.d++;
      h.pts += 1;
      a.pts += 1;
      h.form.add("d");
      a.form.add("d");
    }
  }

  // Ordina e ritorna
  final list = stats.values.toList();

  // Raggruppa per punti
  final Map<int, List<StandingRow>> groups = {};
  for (var row in list) {
    groups.putIfAbsent(row.pts, () => []).add(row);
  }

  // Ordina ciascun gruppo autonomamente
  for (var pts in groups.keys) {
    final groupList = groups[pts]!;
    if (groupList.length == 2) {
      // Caso 2 squadre a pari punti: Scontro diretto -> DR Totale -> GF Totale -> ID
      final t1 = groupList[0];
      final t2 = groupList[1];

      final directMatch = groupMatches.firstWhere(
        (m) => (m.home == t1.id && m.away == t2.id) || (m.home == t2.id && m.away == t1.id),
        orElse: () => MatchModel(id: "", group: "", day: "", time: "", status: MatchStatus.sched),
      );

      int directComparison = 0;
      if (directMatch.id.isNotEmpty && directMatch.status == MatchStatus.done) {
        if (directMatch.homeGoals > directMatch.awayGoals) {
          directComparison = directMatch.home == t1.id ? -1 : 1;
        } else if (directMatch.homeGoals < directMatch.awayGoals) {
          directComparison = directMatch.away == t1.id ? -1 : 1;
        }
      }

      groupList.sort((a, b) {
        if (directComparison != 0) {
          return a.id == t1.id ? directComparison : -directComparison;
        }
        if (b.goalDiff != a.goalDiff) return b.goalDiff.compareTo(a.goalDiff);
        if (b.gf != a.gf) return b.gf.compareTo(a.gf);
        return a.id.compareTo(b.id);
      });
    } else if (groupList.length > 2) {
      // Caso classifica avulsa (3 o più squadre pari punti):
      // 1. Punti negli scontri diretti tra le squadre a pari punti
      // 2. Differenza reti negli scontri diretti
      // 3. Differenza reti totale
      // 4. Gol fatti totali
      // 5. ID
      final tiedIds = groupList.map((e) => e.id).toSet();

      final Map<int, int> avulsaPts = {for (var id in tiedIds) id: 0};
      final Map<int, int> avulsaGf = {for (var id in tiedIds) id: 0};
      final Map<int, int> avulsaGa = {for (var id in tiedIds) id: 0};

      final avulsaMatches = groupMatches.where((m) => tiedIds.contains(m.home) && tiedIds.contains(m.away));
      for (var m in avulsaMatches) {
        final hId = m.home!;
        final aId = m.away!;
        avulsaGf[hId] = avulsaGf[hId]! + m.homeGoals;
        avulsaGa[hId] = avulsaGa[hId]! + m.awayGoals;
        avulsaGf[aId] = avulsaGf[aId]! + m.awayGoals;
        avulsaGa[aId] = avulsaGa[aId]! + m.homeGoals;

        if (m.homeGoals > m.awayGoals) {
          avulsaPts[hId] = avulsaPts[hId]! + 3;
        } else if (m.homeGoals < m.awayGoals) {
          avulsaPts[aId] = avulsaPts[aId]! + 3;
        } else {
          avulsaPts[hId] = avulsaPts[hId]! + 1;
          avulsaPts[aId] = avulsaPts[aId]! + 1;
        }
      }

      groupList.sort((a, b) {
        final ptsA = avulsaPts[a.id] ?? 0;
        final ptsB = avulsaPts[b.id] ?? 0;
        if (ptsB != ptsA) return ptsB.compareTo(ptsA);

        final gdA = (avulsaGf[a.id] ?? 0) - (avulsaGa[a.id] ?? 0);
        final gdB = (avulsaGf[b.id] ?? 0) - (avulsaGa[b.id] ?? 0);
        if (gdB != gdA) return gdB.compareTo(gdA);

        if (b.goalDiff != a.goalDiff) return b.goalDiff.compareTo(a.goalDiff);
        if (b.gf != a.gf) return b.gf.compareTo(a.gf);
        return a.id.compareTo(b.id);
      });
    }
  }

  final sortedPtsKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  final List<StandingRow> sortedList = [];
  for (var pts in sortedPtsKeys) {
    sortedList.addAll(groups[pts]!);
  }

  return sortedList;
}
