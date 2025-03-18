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

      final datosPokemons = results.map((result) async {
        final pokemonUrl = result['url'];
        final pokemonResponse = await http.get(Uri.parse(pokemonUrl));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonResponse.body);
          return {
            'name': result['name'],
            'id': pokemonData['id'].toString(),
            'types': (pokemonData['types'] as List)
                .map((t) => t['type']['name'].toString())
                .toList(),
          };
        }
        return {
          'name': result['name'],
          'id': result['url'].split('/')[result['url'].split('/').length - 2],
          'types': ['normal'],
        };
      });

      final pokemons = await Future.wait(datosPokemons);
      return pokemons
          .map((data) => Pokemon(
                name: data['name'],
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${data['id']}.png',
                types: data['types'],
              ))
          .toList();
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
      final pokemonsFiltrados = results
          .where((result) => result['name']
              .toString()
              .toLowerCase()
              .startsWith(query.toLowerCase()))
          .toList();

      final datosPokemons = pokemonsFiltrados.map((result) async {
        final pokemonUrl = result['url'];
        final pokemonResponse = await http.get(Uri.parse(pokemonUrl));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonResponse.body);
          return {
            'name': result['name'],
            'id': pokemonData['id'].toString(),
            'types': (pokemonData['types'] as List)
                .map((t) => t['type']['name'].toString())
                .toList(),
          };
        }
        return {
          'name': result['name'],
          'id': result['url'].split('/')[result['url'].split('/').length - 2],
          'types': ['normal'],
        };
      });

      final pokemons = await Future.wait(datosPokemons);
      return pokemons
          .map((data) => Pokemon(
                name: data['name'],
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${data['id']}.png',
                types: data['types'],
              ))
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
