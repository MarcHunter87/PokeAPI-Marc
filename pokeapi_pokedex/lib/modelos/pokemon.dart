class Pokemon {
  final String name;
  final String imageUrl;
  final int? height;
  final int? weight;
  final List<String>? types;
  final Map<String, int>? stats;

  Pokemon({
    required this.name,
    required this.imageUrl,
    this.height,
    this.weight,
    this.types,
    this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    final id = url.split('/')[url.split('/').length - 2];
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    return Pokemon(
      name: name,
      imageUrl: imageUrl,
    );
  }
}
