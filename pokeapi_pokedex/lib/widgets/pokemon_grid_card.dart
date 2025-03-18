import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';

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
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).dividerColor
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,

                    //Seguro por si falla la imagen
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pokemon.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
