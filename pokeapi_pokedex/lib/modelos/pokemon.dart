class Pokemon {
  final String name;
  final String imageUrl;
  final int? height;
  final int? weight;
  List<String> types;
  Map<String, int>? stats;

  Pokemon({
    required this.name,
    required this.imageUrl,
    this.height,
    this.weight,
    List<String>? types,
    this.stats,
  }) : types = types ?? [];

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    final id = url.split('/')[url.split('/').length - 2];
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    return Pokemon(
      name: name,
      imageUrl: imageUrl,
      types: [],
      stats: {
        'hp': 0,
        'attack': 0,
        'defense': 0,
        'special-attack': 0,
        'special-defense': 0,
        'speed': 0
      },
    );
  }
}
