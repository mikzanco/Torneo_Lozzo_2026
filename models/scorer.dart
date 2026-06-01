class ScorerEvent {
  final int team;       // id squadra
  final String? player; // nome (null se autogol)
  final int? n;         // numero maglia (null se autogol)
  final int min;        // minuto
  final bool own;       // true = autogol

  ScorerEvent({
    required this.team,
    this.player,
    this.n,
    required this.min,
    this.own = false,
  });

  Map<String, dynamic> toJson() => {
        'team': team,
        'player': player,
        'n': n,
        'min': min,
        'own': own,
      };

  factory ScorerEvent.fromJson(Map<String, dynamic> j) => ScorerEvent(
        team: j['team'] as int,
        player: j['player'] as String?,
        n: j['n'] as int?,
        min: j['min'] as int,
        own: j['own'] as bool? ?? false,
      );
}
