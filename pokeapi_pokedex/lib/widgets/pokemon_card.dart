import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';

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
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).dividerColor
                : Colors.transparent,
            width: 1,
          ),
        ),
        elevation: 2,
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
                  fit: BoxFit.cover,

                  //Seguro por si falla la imagen
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: const Color.fromRGBO(224, 224, 224, 1),
                      child: Icon(Icons.error,
                          color: Theme.of(context).colorScheme.error),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  pokemon.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
