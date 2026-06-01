class Player {
  final int n;       // numero maglia
  final String name;

  Player({required this.n, required this.name});

  Map<String, dynamic> toJson() => {'n': n, 'name': name};
  
  factory Player.fromJson(Map<String, dynamic> j) => Player(
        n: j['n'] as int,
        name: j['name'] as String,
      );
}
