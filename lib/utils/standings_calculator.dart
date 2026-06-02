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
  list.sort((a, b) {
    if (b.pts != a.pts) return b.pts.compareTo(a.pts);
    if (b.goalDiff != a.goalDiff) return b.goalDiff.compareTo(a.goalDiff);
    return b.gf.compareTo(a.gf);
  });

  return list;
}
