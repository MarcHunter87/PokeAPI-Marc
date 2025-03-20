import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/notification_service.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';

class PokemonsFavoritos {
  static const String _key = 'favorite_pokemons';

  static Future<List<Pokemon>> obtenerPokemonsFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pokemonsJson = prefs.getString(_key);
    if (pokemonsJson == null) return [];

    final List<dynamic> pokemonsData = jsonDecode(pokemonsJson);
    return pokemonsData.map((data) {
      Map<String, int>? stats;
      if (data['stats'] != null) {
        stats = Map<String, int>.from(data['stats']
            .map((key, value) => MapEntry(key.toString(), value as int)));
      }

      return Pokemon(
        name: data['name'],
        imageUrl: data['imageUrl'],
        height: data['height'],
        weight: data['weight'],
        types: List<String>.from(data['types']),
        stats: stats ??
            {
              'hp': 0,
              'attack': 0,
              'defense': 0,
              'special-attack': 0,
              'special-defense': 0,
              'speed': 0
            },
      );
    }).toList();
  }

  static Future<void> agregarPokemonFavorito(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Pokemon> favoritos = await obtenerPokemonsFavoritos();

    if (!favoritos.any((p) => p.name == pokemon.name)) {
      try {
        final pokemonCompleto =
            await PokeAPI.obtenerDetallesPokemon(pokemon.name);
        favoritos.add(pokemonCompleto);

        final List<Map<String, dynamic>> pokemonsData = favoritos
            .map((p) => {
                  'name': p.name,
                  'imageUrl': p.imageUrl,
                  'height': p.height,
                  'weight': p.weight,
                  'types': p.types,
                  'stats': p.stats,
                })
            .toList();

        final String encoded = jsonEncode(pokemonsData);
        await prefs.setString(_key, encoded);

        NotificationService.mostrarNotificacionPokemonFavorito(pokemon.name);
      } catch (e) {
        throw Exception(
            'Error al obtener los detalles del Pokémon para guardarlo en favoritos');
      }
    }
  }

  static Future<void> eliminarPokemonFavorito(String nombrePokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Pokemon> favoritos = await obtenerPokemonsFavoritos();

    favoritos.removeWhere((p) => p.name == nombrePokemon);

    final List<Map<String, dynamic>> pokemonsData = favoritos
        .map((p) => {
              'name': p.name,
              'imageUrl': p.imageUrl,
              'height': p.height,
              'weight': p.weight,
              'types': p.types,
              'stats': p.stats,
            })
        .toList();

    final String encoded = jsonEncode(pokemonsData);
    await prefs.setString(_key, encoded);
  }

  static Future<bool> comprobarSiEsFavorito(String nombrePokemon) async {
    final List<Pokemon> favoritos = await obtenerPokemonsFavoritos();
    return favoritos.any((p) => p.name == nombrePokemon);
  }
}
