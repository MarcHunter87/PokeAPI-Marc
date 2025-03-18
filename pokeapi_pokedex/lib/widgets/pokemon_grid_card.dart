import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';

class PokemonGridCard extends StatelessWidget {
  final Pokemon pokemon;
  final Function toggleTheme;
  final bool isDarkMode;

  const PokemonGridCard({
    super.key,
    required this.pokemon,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonStatsPage(
              name: pokemon.name,
              toggleTheme: toggleTheme,
              isDarkMode: isDarkMode,
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: ColorTipo.obtenerTransparencia(
            pokemon.types.first,
            isDarkMode: isDarkMode,
            segundoTipo: pokemon.types.length > 1 ? pokemon.types[1] : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pokemon.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: pokemon.types
                      .map((tipo) => PokemonTypeIcon(
                            tipo: tipo,
                            isDarkMode: isDarkMode,
                            small: true,
                            simple: true,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error,
                              color: Theme.of(context).colorScheme.error),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
