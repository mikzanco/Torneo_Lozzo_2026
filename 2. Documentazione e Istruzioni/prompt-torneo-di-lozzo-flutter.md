# 🏆 PROMPT — Generazione App "Torneo di Lozzo" in Flutter

---

## 🎯 Obiettivo

Crea un'**app Flutter completa** (web + mobile) per gestire un **torneo di calcio amatoriale** chiamato **"Torneo di Lozzo"** (date: **4–5 Luglio 2026**). L'app deve funzionare come un'applicazione mobile-first con tema scuro premium, e permettere sia la consultazione pubblica che la gestione admin in tempo reale.

---

## 🛠️ Stack Tecnico

- **Flutter 3.x** (Dart)
- **State Management**: `Provider` + `ChangeNotifier` (oppure `Riverpod` se preferisci, ma mantieni semplicità)
- **Persistenza locale**: `shared_preferences` per JSON serializzato
- **Nessun backend** — tutta la logica è locale
- **Nessuna dipendenza pesante** — solo Flutter SDK + shared_preferences
- Layout **mobile-first** con `ConstrainedBox(maxWidth: 448)` (equivalente a `max-w-md` = 28rem = 448px)

### Dipendenze `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.0
  provider: ^6.1.0
```

---

## 🏗️ Architettura Progetto

```
lib/
├── main.dart                  # Entry point + MaterialApp + ThemeData
├── models/
│   ├── team.dart              # Modello Squadra
│   ├── match_model.dart       # Modello Partita
│   ├── scorer.dart            # Modello Marcatore
│   └── player.dart            # Modello Giocatore
├── providers/
│   └── tournament_provider.dart  # State management centrale
├── data/
│   └── initial_data.dart      # Squadre e partite iniziali
├── theme/
│   └── app_theme.dart         # Colori, stili testo, decorazioni
├── screens/
│   ├── live_screen.dart       # Pagina Live
│   ├── standings_screen.dart  # Pagina Classifica
│   ├── scorers_screen.dart    # Pagina Cannonieri
│   ├── results_screen.dart    # Pagina Risultati
│   ├── bracket_screen.dart    # Pagina Tabellone
│   └── teams_screen.dart      # Pagina Squadre
├── widgets/
│   ├── team_badge.dart        # Badge squadra con gradiente
│   ├── form_dot.dart          # Pallino risultato (V/P/S)
│   ├── live_dot.dart          # Indicatore pulsante LIVE
│   ├── live_card.dart         # Card partita in corso
│   ├── goal_panel.dart        # Bottom-sheet inserimento gol
│   ├── admin_modal.dart       # Bottom-sheet PIN admin
│   ├── mini_table.dart        # Mini classifica girone
│   ├── full_table.dart        # Classifica completa girone
│   └── team_edit_modal.dart   # Bottom-sheet modifica squadra
└── utils/
    ├── standings_calculator.dart  # Logica classifica
    └── scorers_calculator.dart    # Logica marcatori
```

---

## 🎨 Design System — Tema e Colori

### Mappatura Colori Tailwind → Flutter

```dart
class AppColors {
  // === BACKGROUND ===
  static const Color scaffoldBg    = Color(0xFF09090B); // zinc-950
  static const Color cardBg        = Color(0xFF18181B); // zinc-900
  static const Color surfaceBg     = Color(0xFF27272A); // zinc-800
  static const Color inputBg       = Color(0xFF27272A); // zinc-800

  // === BORDI ===
  static const Color border        = Color(0xFF27272A); // zinc-800
  static const Color borderLight   = Color(0x9927272A); // zinc-800/60
  static const Color borderDark    = Color(0xFF3F3F46); // zinc-700

  // === TESTO ===
  static const Color textPrimary   = Color(0xFFF4F4F5); // zinc-100
  static const Color textSecondary = Color(0xFFD4D4D8); // zinc-300
  static const Color textTertiary  = Color(0xFF71717A); // zinc-500
  static const Color textMuted     = Color(0xFF52525B); // zinc-600
  static const Color textDim       = Color(0xFF3F3F46); // zinc-700

  // === ACCENT ===
  static const Color accent        = Color(0xFFFACC15); // yellow-400
  static const Color accentDark    = Color(0xFF854D0E); // yellow-800 (per sfondi)

  // === STATO ===
  static const Color success       = Color(0xFF34D399); // emerald-400
  static const Color warning       = Color(0xFFFBBF24); // yellow-400
  static const Color error         = Color(0xFFEF4444); // red-500
  static const Color live          = Color(0xFFEF4444); // red-500
  static const Color liveBg        = Color(0xFFF87171); // red-400

  // === FORM DOTS ===
  static const Color dotWin        = Color(0xFF34D399); // emerald-400
  static const Color dotDraw       = Color(0xFFFBBF24); // yellow-400
  static const Color dotLoss       = Color(0xFFEF4444); // red-500

  // === CHIP GIRONE ===
  static const Color chipA         = Color(0xFF22D3EE); // cyan-400
  static const Color chipB         = Color(0xFFFACC15); // yellow-400
  static const Color chipC         = Color(0xFFF87171); // red-400
  static const Color chipD         = Color(0xFF34D399); // emerald-400

  // === BIANCO ===
  static const Color white         = Color(0xFFFFFFFF);
  static const Color black         = Color(0xFF000000);
}
```

### 20 Gradienti Colore Squadre

```dart
class TeamColors {
  static const List<List<Color>> gradients = [
    [Color(0xFF1E3A5F), Color(0xFF1D4ED8)],  //  0 - Blu scuro     (blue-900 → blue-700)
    [Color(0xFF7F1D1D), Color(0xFFB91C1C)],  //  1 - Rosso          (red-900 → red-700)
    [Color(0xFF14532D), Color(0xFF15803D)],  //  2 - Verde          (green-900 → green-700)
    [Color(0xFF9A3412), Color(0xFFEA580C)],  //  3 - Arancione      (orange-800 → orange-600)
    [Color(0xFF581C87), Color(0xFF7E22CE)],  //  4 - Viola          (purple-900 → purple-700)
    [Color(0xFF115E59), Color(0xFF0D9488)],  //  5 - Verde acqua    (teal-800 → teal-600)
    [Color(0xFF334155), Color(0xFF64748B)],  //  6 - Grigio         (slate-700 → slate-500)
    [Color(0xFF831843), Color(0xFFBE185D)],  //  7 - Rosa           (pink-900 → pink-700)
    [Color(0xFF312E81), Color(0xFF4338CA)],  //  8 - Indaco         (indigo-900 → indigo-700)
    [Color(0xFF3F6212), Color(0xFF65A30D)],  //  9 - Verde lime     (lime-800 → lime-600)
    [Color(0xFF155E75), Color(0xFF0891B2)],  // 10 - Ciano          (cyan-800 → cyan-600)
    [Color(0xFF92400E), Color(0xFFD97706)],  // 11 - Ambra          (amber-800 → amber-600)
    [Color(0xFF881337), Color(0xFFBE123C)],  // 12 - Rosa scuro     (rose-900 → rose-700)
    [Color(0xFF4C1D95), Color(0xFF6D28D9)],  // 13 - Violetto       (violet-900 → violet-700)
    [Color(0xFF065F46), Color(0xFF059669)],  // 14 - Smeraldo       (emerald-800 → emerald-600)
    [Color(0xFF0C4A6E), Color(0xFF0284C7)],  // 15 - Azzurro        (sky-900 → sky-700)
    [Color(0xFF701A75), Color(0xFFA21CAF)],  // 16 - Fucsia         (fuchsia-900 → fuchsia-700)
    [Color(0xFF854D0E), Color(0xFFCA8A04)],  // 17 - Giallo         (yellow-800 → yellow-600)
    [Color(0xFF991B1B), Color(0xFFC2410C)],  // 18 - Rosso-arancio  (red-800 → orange-700)
    [Color(0xFF1E40AF), Color(0xFF0891B2)],  // 19 - Blu-ciano      (blue-800 → cyan-700)
  ];
}
```

### Stili Testo Base

```dart
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontWeight: FontWeight.w900,  // font-black
    color: AppColors.white,
    letterSpacing: -0.5,          // tracking-tight
  );

  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textTertiary,
    letterSpacing: 2.0,           // tracking-widest
  );

  static const TextStyle score = TextStyle(
    fontSize: 48,                  // text-6xl
    fontWeight: FontWeight.w900,
    color: AppColors.white,
  );

  static const TextStyle scoreDivider = TextStyle(
    fontSize: 24,                  // text-3xl
    fontWeight: FontWeight.w900,
    color: AppColors.textMuted,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}
```

### Decorazioni/Card Base

```dart
class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardBg,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(16),   // rounded-2xl
  );

  static BoxDecoration pill({bool active = false}) => BoxDecoration(
    color: active ? AppColors.accent : Colors.transparent,
    border: Border.all(color: active ? AppColors.accent : AppColors.borderDark),
    borderRadius: BorderRadius.circular(999),  // rounded-full
  );

  static BoxDecoration bottomSheet = BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),  // rounded-t-3xl
  );
}
```

---

## 📊 Modelli Dati (Dart Classes)

### Player
```dart
class Player {
  final int n;       // numero maglia
  final String name;

  Player({required this.n, required this.name});

  Map<String, dynamic> toJson() => {'n': n, 'name': name};
  factory Player.fromJson(Map<String, dynamic> j) =>
    Player(n: j['n'], name: j['name']);
}
```

### Team
```dart
class Team {
  final int id;
  String name;
  String group;
  int color;          // indice nel TeamColors.gradients
  List<Player> players;

  Team({required this.id, required this.name, required this.group,
        required this.color, required this.players});

  String get initials =>
    name.split(' ').map((w) => w[0]).join('').substring(0, 2).toUpperCase();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'group': group, 'color': color,
    'players': players.map((p) => p.toJson()).toList(),
  };

  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'], name: j['name'], group: j['group'], color: j['color'],
    players: (j['players'] as List).map((p) => Player.fromJson(p)).toList(),
  );
}
```

### Scorer (evento gol)
```dart
class ScorerEvent {
  final int team;       // id squadra
  final String? player; // nome (null se autogol)
  final int? n;         // numero maglia (null se autogol)
  final int min;        // minuto
  final bool own;       // true = autogol

  ScorerEvent({required this.team, this.player, this.n,
               required this.min, this.own = false});

  Map<String, dynamic> toJson() => {
    'team': team, 'player': player, 'n': n, 'min': min, 'own': own,
  };

  factory ScorerEvent.fromJson(Map<String, dynamic> j) => ScorerEvent(
    team: j['team'], player: j['player'], n: j['n'],
    min: j['min'], own: j['own'] ?? false,
  );
}
```

### MatchModel
```dart
enum MatchStatus { sched, live, done }

class MatchModel {
  final String id;       // "A1", "QF1", "SF1", "F", "F3"
  final String group;    // "A", "B", "C", "D", "KO"
  int? home;             // id squadra casa (nullable per bracket TBD)
  int? away;
  final String day;
  final String time;
  MatchStatus status;
  int homeGoals;
  int awayGoals;
  List<ScorerEvent> scorers;
  String? phase;         // "QF", "SF", "F" per partite KO

  MatchModel({
    required this.id, required this.group, this.home, this.away,
    required this.day, required this.time,
    this.status = MatchStatus.sched,
    this.homeGoals = 0, this.awayGoals = 0,
    this.scorers = const [], this.phase,
  });

  // serializzazione/deserializzazione JSON ...
}
```

### StandingRow (per classifica)
```dart
class StandingRow {
  final int id;
  final String name;
  final int color;
  int g = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0, pts = 0;
  List<String> form = [];  // "w", "d", "l"

  int get goalDiff => gf - ga;

  StandingRow({required this.id, required this.name, required this.color});
}
```

---

## 👥 Dati Iniziali — 20 Squadre

Genera esattamente queste 20 squadre suddivise in 4 gironi da 5:

**Girone A:**
1. Falchi Celesti (color: 0) — Giocatori: #7 A. Bianchi, #9 P. Ferrari, #3 M. Neri, #11 L. Conti, #5 R. Sala
2. Rossi del Sud (color: 1) — Giocatori: #11 G. Ricci, #8 F. Longo, #4 D. Galli
3. Lupi Grigi (color: 6) — Giocatori: #10 C. Russo, #6 M. Bruno
4. Delfini Blu (color: 8) — Giocatori: #9 S. Costa, #7 A. Villa
5. Pantere FC (color: 7) — Giocatori: #10 E. Serra, #3 L. Riva

**Girone B:**
6. Aquile Nere (color: 3) — Giocatori: #9 M. Esposito, #3 C. Rizzo, #7 T. Ferro
7. Leoni FC (color: 4) — Giocatori: #8 R. Mancini, #11 V. Greco
8. Stelle Gialle (color: 11) — Giocatori: #10 F. Marino, #6 A. Coda
9. Tigri Arancio (color: 12) — Giocatori: #9 N. Caruso, #5 P. Monti
10. Condor AC (color: 2) — Giocatori: #7 G. Pini, #10 S. Foti

**Girone C:**
11. Stelle Azzurre (color: 9) — Giocatori: #11 L. Ferretti, #9 M. Bello
12. Rangers '99 (color: 16) — Giocatori: #10 D. Costa, #7 A. Preti
13. Vespe United (color: 14) — Giocatori: #8 F. Tosi, #11 R. Bassi
14. Black Stars (color: 13) — Giocatori: #9 C. Nava, #6 L. Ricci
15. Cobra FC (color: 17) — Giocatori: #10 G. Santi, #3 M. Forti

**Girone D:**
16. Tornado FC (color: 5) — Giocatori: #10 G. Ricci, #9 E. Luca
17. Vecchia Guardia (color: 15) — Giocatori: #14 S. Russo, #8 P. Dori
18. Draghi Rossi (color: 19) — Giocatori: #9 F. Gallo, #11 N. Sole
19. Samurai FC (color: 18) — Giocatori: #7 A. Kato, #5 L. Yama
20. Nibbio AC (color: 10) — Giocatori: #10 C. Volpe, #9 R. Nido

---

## ⚽ Dati Iniziali — Partite Gironi (32 Partite)

Genera 8 partite per girone. Ecco tutte le partite con i risultati pre-compilati:

### Girone A — 8 partite
| ID  | Casa            | Trasferta       | Giorno      | Ora   | Status | Ris.  | Marcatori |
|-----|-----------------|-----------------|-------------|-------|--------|-------|-----------|
| A1  | Falchi Celesti  | Rossi del Sud   | Sab 4 Lug   | 09:00 | done   | 3-1   | A. Bianchi #7 12', P. Ferrari #9 28', A. Bianchi #7 38' — G. Ricci #11 21' |
| A2  | Lupi Grigi      | Delfini Blu     | Sab 4 Lug   | 09:30 | done   | 1-1   | C. Russo #10 15' — S. Costa #9 33' |
| A3  | Falchi Celesti  | Lupi Grigi      | Sab 4 Lug   | 14:00 | done   | 2-0   | P. Ferrari #9 7', L. Conti #11 41' |
| A4  | Rossi del Sud   | Pantere FC      | Sab 4 Lug   | 14:30 | done   | 2-1   | F. Longo #8 10', G. Ricci #11 34' — E. Serra #10 27' |
| A5  | Falchi Celesti  | Delfini Blu     | Dom 5 Lug   | 09:00 | live   | 2-1   | A. Bianchi #7 12', P. Ferrari #9 28' — S. Costa #9 21' |
| A6  | Rossi del Sud   | Lupi Grigi      | Dom 5 Lug   | 09:30 | sched  | 0-0   | — |
| A7  | Lupi Grigi      | Pantere FC      | Dom 5 Lug   | 10:00 | sched  | 0-0   | — |
| A8  | Delfini Blu     | Pantere FC      | Dom 5 Lug   | 10:30 | sched  | 0-0   | — |

### Girone B — 8 partite
| ID  | Casa            | Trasferta       | Giorno      | Ora   | Status | Ris.  | Marcatori |
|-----|-----------------|-----------------|-------------|-------|--------|-------|-----------|
| B1  | Aquile Nere     | Leoni FC        | Sab 4 Lug   | 10:00 | done   | 4-1   | M. Esposito #9 5', 22', C. Rizzo #3 31', T. Ferro #7 40' — R. Mancini #8 18' |
| B2  | Stelle Gialle   | Tigri Arancio   | Sab 4 Lug   | 10:30 | done   | 1-2   | F. Marino #10 20' — N. Caruso #9 8', P. Monti #5 37' |
| B3  | Aquile Nere     | Stelle Gialle   | Sab 4 Lug   | 15:00 | done   | 3-0   | M. Esposito #9 3', 19', C. Rizzo #3 44' |
| B4  | Leoni FC        | Condor AC       | Sab 4 Lug   | 15:30 | done   | 2-0   | R. Mancini #8 12', V. Greco #11 29' |
| B5  | Aquile Nere     | Tigri Arancio   | Dom 5 Lug   | 09:00 | sched  | 0-0   | — |
| B6  | Leoni FC        | Stelle Gialle   | Dom 5 Lug   | 09:30 | sched  | 0-0   | — |
| B7  | Stelle Gialle   | Condor AC       | Dom 5 Lug   | 10:00 | sched  | 0-0   | — |
| B8  | Tigri Arancio   | Condor AC       | Dom 5 Lug   | 10:30 | sched  | 0-0   | — |

### Girone C — 8 partite
| ID  | Casa            | Trasferta       | Giorno      | Ora   | Status | Ris.  | Marcatori |
|-----|-----------------|-----------------|-------------|-------|--------|-------|-----------|
| C1  | Stelle Azzurre  | Rangers '99     | Sab 4 Lug   | 11:00 | done   | 1-0   | L. Ferretti #11 33' |
| C2  | Vespe United    | Black Stars     | Sab 4 Lug   | 11:30 | done   | 2-1   | F. Tosi #8 14', R. Bassi #11 39' — C. Nava #9 27' |
| C3  | Stelle Azzurre  | Vespe United    | Sab 4 Lug   | 16:00 | done   | 2-1   | L. Ferretti #11 9', M. Bello #9 28' — F. Tosi #8 41' |
| C4  | Rangers '99     | Cobra FC        | Sab 4 Lug   | 16:30 | done   | 3-0   | D. Costa #10 6', A. Preti #7 23', D. Costa #10 40' |
| C5  | Stelle Azzurre  | Black Stars     | Dom 5 Lug   | 11:00 | sched  | 0-0   | — |
| C6  | Rangers '99     | Vespe United    | Dom 5 Lug   | 11:30 | sched  | 0-0   | — |
| C7  | Vespe United    | Cobra FC        | Dom 5 Lug   | 12:00 | sched  | 0-0   | — |
| C8  | Black Stars     | Cobra FC        | Dom 5 Lug   | 12:30 | sched  | 0-0   | — |

### Girone D — 8 partite
| ID  | Casa            | Trasferta       | Giorno      | Ora   | Status | Ris.  | Marcatori |
|-----|-----------------|-----------------|-------------|-------|--------|-------|-----------|
| D1  | Tornado FC      | Vecchia Guardia | Sab 4 Lug   | 12:00 | done   | 2-1   | G. Ricci #10 11', E. Luca #9 30' — S. Russo #14 25' |
| D2  | Draghi Rossi    | Samurai FC      | Sab 4 Lug   | 12:30 | done   | 2-0   | F. Gallo #9 17', N. Sole #11 36' |
| D3  | Tornado FC      | Draghi Rossi    | Sab 4 Lug   | 17:00 | done   | 1-1   | G. Ricci #10 22' — F. Gallo #9 38' |
| D4  | Vecchia Guardia | Nibbio AC       | Sab 4 Lug   | 17:30 | done   | 2-0   | S. Russo #14 8', P. Dori #8 31' |
| D5  | Tornado FC      | Samurai FC      | Dom 5 Lug   | 11:00 | sched  | 0-0   | — |
| D6  | Vecchia Guardia | Draghi Rossi    | Dom 5 Lug   | 11:30 | sched  | 0-0   | — |
| D7  | Draghi Rossi    | Nibbio AC       | Dom 5 Lug   | 12:00 | sched  | 0-0   | — |
| D8  | Samurai FC      | Nibbio AC       | Dom 5 Lug   | 12:30 | sched  | 0-0   | — |

---

## 📐 Logica di Classifica (`calcStandings`)

Per ogni girone, calcola per ciascuna squadra su partite con status `done`:
- **G** (giocate), **V** (vittorie), **P** (pareggi), **S** (sconfitte)
- **GF** (gol fatti), **GA** (gol subiti)
- **Pts** (punti): vittoria = 3 pts, pareggio = 1 pt
- **Form**: lista degli ultimi risultati ("w", "d", "l")

**Ordinamento**: per punti decrescenti → differenza reti (GF-GA) decrescente → gol fatti decrescenti.

```dart
List<StandingRow> calcStandings(List<Team> teams, List<MatchModel> matches, String group) {
  // Filtra squadre del girone
  // Inizializza mappa stats
  // Itera partite "done" del girone
  // Per ogni partita aggiorna stats casa/trasferta
  // Ordina e ritorna
}
```

---

## 🥇 Logica Classifica Marcatori (`calcScorers`)

Conta i gol per giocatore su tutte le partite `done` o `live`, **ignorando gli autogol** (`s.own == true`). Chiave univoca: `"{teamId}-{numero_maglia}"`. Ordinamento per gol decrescenti. Mostra i top 15.

---

## 🔄 State Management — `TournamentProvider`

```dart
class TournamentProvider extends ChangeNotifier {
  List<Team> teams = [];
  List<MatchModel> matches = [];
  bool adminMode = false;
  bool loaded = false;
  bool goalFlash = false;

  // Caricamento da SharedPreferences
  Future<void> loadData() async { ... }

  // Salvataggio
  Future<void> saveMatches() async { ... }
  Future<void> saveTeams() async { ... }

  // Admin
  bool verifyPin(String pin) => pin == "1234";
  void toggleAdmin() { adminMode = !adminMode; notifyListeners(); }

  // Match actions
  void startMatch(String matchId) { ... }
  void addGoal(String matchId, String side, ScorerEvent scorer) { ... }
  void endMatch(String matchId) { ... }

  // Bracket
  void generateBracket() { ... }
  void endBracketMatch(String matchId) { ... }

  // Team CRUD
  void addTeam(Team team) { ... }
  void updateTeam(Team team) { ... }
  void deleteTeam(int id) { ... }

  // Goal flash
  void triggerGoalFlash() {
    goalFlash = true;
    notifyListeners();
    Future.delayed(Duration(milliseconds: 700), () {
      goalFlash = false;
      notifyListeners();
    });
  }
}
```

Persistenza via `SharedPreferences`:
- Chiave `"lozzo-matches"` → JSON stringificato delle partite
- Chiave `"lozzo-teams"` → JSON stringificato delle squadre

---

## 📱 Struttura Navigazione

### Scaffold Principale

```dart
Scaffold(
  backgroundColor: AppColors.scaffoldBg,
  body: SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 448),
      child: Column(
        children: [
          // HEADER STICKY
          _buildHeader(),      // Nome torneo + LiveDot + lucchetto admin
          _buildTabBar(),      // 6 tab scrollabili orizzontalmente
          // CONTENUTO
          Expanded(
            child: _buildCurrentPage(),  // switch sul tab selezionato
          ),
        ],
      ),
    ),
  ),
)
```

### 6 Tab
1. `⚽ Live` — Partita in corso + prossime partite
2. `📊 Classifica` — Classifiche gironi
3. `🥇 Cannonieri` — Classifica marcatori
4. `📋 Risultati` — Partite completate
5. `🏆 Tabellone` — Fase a eliminazione diretta
6. `⚙️ Squadre` — Gestione squadre

Tab implementabili con `SingleChildScrollView` + `Row` di `GestureDetector`/`InkWell`, con sottolineatura animata (`Container` height 2, color accent).

---

## 📄 Schermate — Specifiche Dettagliate

### 1. ⚽ Schermata Live

**Se c'è una partita live (`MatchStatus.live`):**
- **LiveCard** (widget custom):
  - Header: "Girone {group} · {day}" a sinistra, `LiveDot` + timer "{min}'" in giallo a destra
  - Centro: `TeamBadge(size: lg)` + nome sotto per ogni squadra, punteggio `Text(style: AppTextStyles.score)` al centro separato da "–" in grigio
  - Sotto: "Marcatori" label + due colonne con `⚽ #{n} {nome} — {min}'`
  - **Admin**: sezione gialla con 2 bottoni "⚽ Goal {squadra}" + bottone rosso "🏁 Termina Partita"
  - Ogni bottone "Goal" apre il `GoalPanel` come `showModalBottomSheet`

**Se NON c'è partita live:**
- Card con icona 🏁 + testo "Nessuna partita in corso"

**Sotto**: ListView "Prossime partite" (max 5 con status `sched`), ciascuna con `TeamBadge(sm)`, nomi, giorno, girone, orario in giallo

**Admin senza live**: pannello "⚡ Avvia Partita" con `DropdownButton` delle partite `sched` + bottone giallo "▶ Avvia ora"

### 2. 📊 Schermata Classifica

- Filtro pillole orizzontale: "Tutti", "Girone A/B/C/D"
- **Vista "Tutti"**: `GridView.count(crossAxisCount: 2)` con `MiniTable` per girone
  - Ogni riga: posizione (1=giallo, 2=grigio), nome, punti
  - Bordo sinistro: `Container(width: 2, color: emerald)` per 1°, `yellow` per 2°
- **Vista singolo girone**: `FullTable` con `Row` simulante griglia a 8 colonne (#, Squadra, G, V, P, S, DR, Pts)
  - Form dots sotto il nome squadra
  - Bordo sinistro colorato
- Legenda: quadratino verde = "Qualificata", giallo = "Seconda"
- Colore chip per girone: A=cyan, B=yellow, C=red, D=emerald

### 3. 🥇 Schermata Cannonieri

- `Container` decorativo con gradiente giallo-arancio-rosso `LinearGradient` (h: 4px)
- `ListView.separated` dei top 15 marcatori:
  - Posizione grande (1=giallo, 2=grigio, 3=arancione)
  - `CircleAvatar` con gradiente squadra + "#{n}" al centro
  - Nome giocatore + nome squadra sotto
  - Conteggio gol grande giallo + label "gol"

### 4. 📋 Schermata Risultati

- Filtro per girone (stesse pillole)
- Partite `done` raggruppate per `day` (usa `groupBy` o manuale con `Map<String, List>`)
- Per ogni partita: card con `TeamBadge(sm)` per entrambe le squadre, nomi con punteggio (vincente in bianco, perdente in grigio), chip girone colorato
- Sotto: riga marcatori per lato

### 5. 🏆 Schermata Tabellone

**Prima della fine dei gironi**: messaggio "⏳ Il tabellone si genera al termine della fase a gironi"

**Dopo gironi completati + admin**: bottone "🏆 Genera Tabellone"

**Logica seeding quarti di finale (8 partite):**
- QF1: 1°A vs 4°D | QF2: 1°B vs 4°C | QF3: 1°C vs 4°B | QF4: 1°D vs 4°A
- QF5: 2°A vs 3°D | QF6: 2°B vs 3°C | QF7: 2°C vs 3°B | QF8: 2°D vs 3°A

**Avanzamento vincitori:**
- QF1→SF1 casa, QF2→SF1 trasferta
- QF3→SF2 casa, QF4→SF2 trasferta
- QF5/QF6→SF1 (primo slot libero)
- QF7/QF8→SF2 (primo slot libero)
- Vincente SF1→Finale casa, Perdente SF1→Finale3° casa
- Vincente SF2→Finale trasferta, Perdente SF2→Finale3° trasferta

**Regola KO**: pareggi non ammessi. Bottone "Fine" disabilitato se pari.

**Widget**: 4 sezioni con header label, per ogni match una card con 2 righe (casa/trasferta), badge o placeholder grigio ("TBD"), punteggio, ✓ per vincente, opacità ridotta per perdente.

### 6. ⚙️ Schermata Squadre

**Senza admin**: card con icona 🔒 + messaggio

**Con admin**:
- Filtro per girone con conteggio "(5)"
- `ListView` di card squadre con `TeamBadge(sm)`, nome, girone, n. giocatori, eventuale "Ha giocato"
- Bottone `+ Aggiungi Squadra` con bordo tratteggiato `Border.all(style: BorderStyle.dashed)` (usa `CustomPainter` o `DottedBorder` package)
- Riepilogo gironi: `GridView(crossAxisCount: 4)` con conteggio + stato (✓ OK / mancano X / extra)

**Bottom-sheet modifica squadra** (via `showModalBottomSheet(isScrollControlled: true)`):
- Anteprima live badge
- `TextField` nome (max 30 char, validazione duplicati)
- 4 bottoni girone A/B/C/D con warning se ha giocato
- Color picker: `GridView(crossAxisCount: 5)` con 20 `InkWell` circolari a gradiente, bordo giallo su selezionato
- Rosa giocatori: `ListView` con badge numero, nome, bottone elimina; form aggiunta con TextFields + bottone +
- Bottone salva giallo
- Bottone elimina rosso (conferma 2 step)

---

## 🔐 Sistema Admin

### Costante
```dart
const String adminPin = "1234";
```

### Modal Login (Bottom Sheet)
Usa `showModalBottomSheet` con:
- 4 caselle PIN (`Container` 48x48 con bordo, `●` se riempita)
- Tastierino numerico: `GridView(crossAxisCount: 3)` con bottoni 1-9, vuoto, 0, ⌫
- Auto-submit a 4 cifre
- Errore: testo rosso + effetto scuotimento (usa `AnimationController` con `Offset` tremble per simulare `animate-bounce`)
- Successo: chiude sheet, setta `adminMode = true`

### Bottone Header
- `GestureDetector` con `Container` 32x32
- 🔒 su sfondo grigio quando non admin
- 🔓 su sfondo giallo quando admin
- Tap: toggle admin se attivo, oppure apre modal PIN

---

## ⚽ GoalPanel (Bottom Sheet)

`showModalBottomSheet(isScrollControlled: true)` con:
- Badge + nome squadra
- Toggle "Marcatore" / "Autogol" (2 bottoni pill con `AnimatedContainer`)
- Se marcatore: `TextField` numero maglia (grande, centrato), con feedback sotto:
  - "✓ {Nome}" in verde se trovato nella rosa
  - "⚠ Numero non trovato nella rosa" in rosso
- `TextField` minuto (pre-compilato con timer corrente)
- Bottone "✓ Conferma Goal" giallo grande
- Al conferma: aggiorna match, triggerGoalFlash()

**Logica autogol**: `ScorerEvent(team: teamId, own: true, min: min)` — non conta nella classifica marcatori. Il gol viene aggiunto al contatore della squadra che ha selezionato il lato.

---

## ⚡ Animazioni e Micro-interazioni Flutter

### Goal Flash
```dart
// Nel widget principale, sopra tutto:
if (provider.goalFlash)
  Positioned.fill(
    child: IgnorePointer(
      child: AnimatedOpacity(
        opacity: provider.goalFlash ? 1.0 : 0.0,
        duration: Duration(milliseconds: 700),
        child: Container(color: AppColors.accent.withOpacity(0.1)),
      ),
    ),
  ),
```

### Live Dot Pulsante
```dart
class LiveDot extends StatefulWidget { ... }

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Ping esterno
            FadeTransition(
              opacity: Tween(begin: 0.75, end: 0.0).animate(_controller),
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 2.0).animate(_controller),
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.liveBg,
                  ),
                ),
              ),
            ),
            // Pallino fisso
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.live,
              ),
            ),
          ],
        ),
        SizedBox(width: 6),
        Text("Live",
          style: TextStyle(
            color: AppColors.liveBg,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
```

### Bottoni — Effetto Press
```dart
// Usa un widget custom o GestureDetector + AnimatedScale:
GestureDetector(
  onTapDown: (_) => setState(() => _pressed = true),
  onTapUp: (_) => setState(() => _pressed = false),
  onTapCancel: () => setState(() => _pressed = false),
  child: AnimatedScale(
    scale: _pressed ? 0.95 : 1.0,
    duration: Duration(milliseconds: 100),
    child: Container( ... ),  // il bottone
  ),
)
```

### PIN Errato — Scuotimento
```dart
// Usa AnimationController con shake:
late AnimationController _shakeController;
late Animation<double> _shakeAnimation;

_shakeController = AnimationController(
  duration: Duration(milliseconds: 500),
  vsync: this,
);
_shakeAnimation = Tween(begin: 0.0, end: 10.0)
  .chain(CurveTween(curve: Curves.elasticIn))
  .animate(_shakeController);

// Build:
AnimatedBuilder(
  animation: _shakeAnimation,
  builder: (ctx, child) => Transform.translate(
    offset: Offset(sin(_shakeAnimation.value * pi * 4) * _shakeAnimation.value, 0),
    child: child,
  ),
  child: _buildPinBoxes(),
)
```

### Timer Partita Live
```dart
// Nell'initState della LiveCard:
Timer.periodic(Duration(minutes: 1), (timer) {
  setState(() => _minute++);
  if (_minute >= 90) timer.cancel();
});
```

### Loading Screen
```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("⚽", style: TextStyle(fontSize: 32)),
      SizedBox(height: 12),
      Text("CARICAMENTO...",
        style: TextStyle(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
          fontSize: 12,
        ),
      ),
    ],
  ),
)
```

---

## 📦 Widget Riutilizzabili — Specifiche

### `TeamBadge`
```dart
enum BadgeSize { sm, md, lg }

class TeamBadge extends StatelessWidget {
  final Team team;
  final BadgeSize size;

  // sm: 36x36, radius 12, fontSize 12
  // md: 48x48, radius 16, fontSize 14
  // lg: 64x64, radius 16, fontSize 20

  // Container con BoxDecoration(gradient: LinearGradient(
  //   begin: Alignment.topLeft, end: Alignment.bottomRight,
  //   colors: TeamColors.gradients[team.color],
  // ))
  // Child: Text(team.initials, fontWeight: FontWeight.w900, color: white)
}
```

### `FormDot`
```dart
Container(
  width: 8, height: 8,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: result == "w" ? AppColors.dotWin
         : result == "d" ? AppColors.dotDraw
         : AppColors.dotLoss,
  ),
)
```

---

## 💾 Persistenza — SharedPreferences

```dart
class StorageService {
  static Future<void> saveMatches(List<MatchModel> matches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lozzo-matches', jsonEncode(matches.map((m) => m.toJson()).toList()));
  }

  static Future<List<MatchModel>?> loadMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('lozzo-matches');
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list.map((j) => MatchModel.fromJson(j)).toList();
  }

  // Analogamente per teams...
}
```

All'avvio (`TournamentProvider.loadData()`):
1. Tenta di caricare da SharedPreferences
2. Se dati presenti → usa quelli
3. Se assenti → usa `INITIAL_TEAMS` e `INITIAL_MATCHES`
4. Setta `loaded = true` e `notifyListeners()`

---

## ✅ Checklist Finale

- [ ] L'app compila e gira su web, Android e iOS
- [ ] Struttura file organizzata come da schema architettura
- [ ] Tutti i 20 team sono presenti con i dati corretti
- [ ] Tutte le 32 partite dei gironi sono generate con i risultati pre-compilati
- [ ] La classifica si calcola correttamente con l'ordinamento specificato
- [ ] La classifica marcatori funziona correttamente (esclusi autogol)
- [ ] Il sistema admin con PIN è funzionante con tastierino numerico
- [ ] Si possono avviare partite, inserire goal, terminare partite
- [ ] Il tabellone si genera con il seeding corretto
- [ ] L'avanzamento nel bracket funziona automaticamente
- [ ] Le partite KO non possono terminare in pareggio
- [ ] La gestione squadre (CRUD) è completa con validazione
- [ ] La persistenza via SharedPreferences funziona
- [ ] Il design è coerente: tema scuro, colori corretti, mobile-first 448px
- [ ] Tutte le animazioni sono presenti (goal flash, live dot, scale buttons, shake PIN)
- [ ] Il testo dell'interfaccia è interamente in italiano
- [ ] Il Provider notifica correttamente i listener su ogni modifica
- [ ] Nessun overflow su schermi piccoli

---

*Genera l'intera app Flutter/Dart seguendo l'architettura descritta. Crea tutti i file necessari con codice completo e funzionante. Usa solo `flutter`, `provider` e `shared_preferences` come dipendenze.*
