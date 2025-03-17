import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokeapi_pokedex/modelos/pokemon.dart';

class PokeAPI {
  static Future<List<Pokemon>> obtenerPokemons(
      {int limit = 20, int offset = 0}) async {
    final url = 'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Pokemon.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<Pokemon>> buscarPokemons(String query) async {
    final url = 'https://pokeapi.co/api/v2/pokemon?limit=1500';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      final List<Pokemon> pokemonsBuscados =
          results.map((json) => Pokemon.fromJson(json)).toList();
      return pokemonsBuscados
          .where((pokemon) =>
              pokemon.name.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<Pokemon> obtenerDetallesPokemon(String nombre) async {
    final url = 'https://pokeapi.co/api/v2/pokemon/$nombre';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final id = data['id'].toString();
      final imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

      return Pokemon(
        name: data['name'],
        imageUrl: imageUrl,
        height: data['height'],
        weight: data['weight'],
        types: (data['types'] as List)
            .map((t) => t['type']['name'].toString())
            .toList(),
        stats: Map.fromEntries(
          (data['stats'] as List).map(
            (stat) => MapEntry(
              stat['stat']['name'],
              stat['base_stat'] as int,
            ),
          ),
        ),
      );
    } else {
      throw Exception('Error al cargar los datos del Pokémon');
    }
  }
}
