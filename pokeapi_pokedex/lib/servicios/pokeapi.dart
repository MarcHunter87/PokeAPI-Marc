import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:pokeapi_pokedex/modelos/pokemon.dart';

class PokeAPI {
  static Future<List<Pokemon>> obtenerPokemons(
      {int limit = 20, int offset = 0}) async {
    final url = 'https://beta.pokeapi.co/graphql/v1beta';
    final query = '''
      query pokemons(\$limit: Int!, \$offset: Int!) {
        pokemon_v2_pokemon(limit: \$limit, offset: \$offset) {
          name
          id
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': query,
        'variables': {'limit': limit, 'offset': offset}
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List pokemons = data['data']['pokemon_v2_pokemon'];

      return pokemons
          .map((pokemon) => Pokemon(
                name: pokemon['name'],
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                types: (pokemon['pokemon_v2_pokemontypes'] as List)
                    .map((type) => type['pokemon_v2_type']['name'].toString())
                    .toList(),
              ))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<Pokemon>> buscarPokemons(String query) async {
    if (query.isEmpty) return [];

    final url = 'https://beta.pokeapi.co/graphql/v1beta';
    final graphQuery = '''
    query buscarPokemons(\$search: String!) {
      pokemon_v2_pokemon(where: {name: {_ilike: \$search}}) {
        name
        id
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
      }
    }
  ''';

    final searchPattern = query.length >= 3
        ? '%${query.toLowerCase()}%'
        : '${query.toLowerCase()}%';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': graphQuery,
        'variables': {'search': searchPattern},
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List pokemons = data['data']['pokemon_v2_pokemon'];

      return pokemons
          .map((pokemon) => Pokemon(
                name: pokemon['name'],
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                types: (pokemon['pokemon_v2_pokemontypes'] as List)
                    .map((type) => type['pokemon_v2_type']['name'].toString())
                    .toList(),
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

  static Future<List<Pokemon>> obtenerPokemonsPorTipo(String tipo,
      {int limit = 20, int offset = 0}) async {
    final url = 'https://beta.pokeapi.co/graphql/v1beta';
    final query = '''
      query pokemonsPorTipo(\$limit: Int!, \$offset: Int!, \$tipo: String!) {
        pokemon_v2_pokemon(
          limit: \$limit,
          offset: \$offset,
          where: {
            pokemon_v2_pokemontypes: {
              pokemon_v2_type: {
                name: {_eq: \$tipo}
              }
            }
          }
        ) {
          name
          id
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': query,
        'variables': {
          'limit': limit,
          'offset': offset,
          'tipo': tipo.toLowerCase()
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List pokemons = data['data']['pokemon_v2_pokemon'];

      return pokemons
          .map((pokemon) => Pokemon(
                name: pokemon['name'],
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                types: (pokemon['pokemon_v2_pokemontypes'] as List)
                    .map((type) => type['pokemon_v2_type']['name'].toString())
                    .toList(),
              ))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<Pokemon> obtenerPokemonAleatorio() async {
    final url = 'https://beta.pokeapi.co/graphql/v1beta';

    final nombresQuery = '''
      query obtenerNombres {
        pokemon_v2_pokemon(limit: 1500) {
          name
        }
      }
    ''';

    final nombresResponse = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': nombresQuery,
      }),
    );

    final nombresData = json.decode(nombresResponse.body);
    final listaNombres = nombresData['data']['pokemon_v2_pokemon'] as List;

    final random = Random();
    final nombreAleatorio =
        listaNombres[random.nextInt(listaNombres.length)]['name'];

    return await obtenerDetallesPokemon(nombreAleatorio);
  }
}
