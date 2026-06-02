import 'player.dart';

class Team {
  final int id;
  String name;
  String group;
  int color; // indice nel TeamColors.gradients
  List<Player> players;

  Team({
    required this.id,
    required this.name,
    required this.group,
    required this.color,
    required this.players,
  });

  String get initials {
    if (name.trim().isEmpty) return "??";
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (name.trim().length >= 2) {
      return name.trim().substring(0, 2).toUpperCase();
    } else {
      return (name.trim() * 2).toUpperCase();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'color': color,
        'players': players.map((p) => p.toJson()).toList(),
      };

  factory Team.fromJson(Map<String, dynamic> j) => Team(
        id: j['id'] as int,
        name: j['name'] as String,
        group: j['group'] as String,
        color: j['color'] as int,
        players: (j['players'] as List)
            .map((p) => Player.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
