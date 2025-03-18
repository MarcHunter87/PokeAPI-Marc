import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';

class PokemonsFavoritos {
  static const String _key = 'favorite_pokemons';

  static Future<List<Pokemon>> obtenerPokemonsFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pokemonsJson = prefs.getString(_key);
    if (pokemonsJson == null) return [];

    final List<dynamic> nombresPokemon = jsonDecode(pokemonsJson);
    final List<Pokemon> pokemons = [];

    for (var nombre in nombresPokemon) {
      try {
        final pokemon = await PokeAPI.obtenerDetallesPokemon(nombre);
        pokemons.add(pokemon);
      } catch (e) {
        continue;
      }
    }

    return pokemons;
  }

  static Future<void> agregarPokemonFavorito(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritos = await _obtenerNombresFavoritos();

    if (!favoritos.contains(pokemon.name)) {
      favoritos.add(pokemon.name);
      final String encoded = jsonEncode(favoritos);
      await prefs.setString(_key, encoded);
    }
  }

  static Future<void> eliminarPokemonFavorito(String nombrePokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritos = await _obtenerNombresFavoritos();

    favoritos.remove(nombrePokemon);
    final String encoded = jsonEncode(favoritos);
    await prefs.setString(_key, encoded);
  }

  static Future<bool> comprobarSiEsFavorito(String nombrePokemon) async {
    final List<String> favoritos = await _obtenerNombresFavoritos();
    return favoritos.contains(nombrePokemon);
  }

  static Future<List<String>> _obtenerNombresFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pokemonsJson = prefs.getString(_key);
    if (pokemonsJson == null) return [];

    final List<dynamic> nombresPokemon = jsonDecode(pokemonsJson);
    return nombresPokemon.cast<String>();
  }
}
