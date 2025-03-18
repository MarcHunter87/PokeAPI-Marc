import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final Function toggleTheme;
  final bool isDarkMode;

  const PokemonCard({
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
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: ColorTipo.obtenerTransparencia(
            pokemon.types.first,
            isDarkMode: isDarkMode,
            segundoTipo: pokemon.types.length > 1 ? pokemon.types[1] : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pokemon.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.error,
                            color: Theme.of(context).colorScheme.error),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemon.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: pokemon.types
                            .map((tipo) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: PokemonTypeIcon(
                                    tipo: tipo,
                                    isDarkMode: isDarkMode,
                                    small: true,
                                    simple: true,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: ColorTipo.obtenerColorTipo(pokemon.types.first),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
