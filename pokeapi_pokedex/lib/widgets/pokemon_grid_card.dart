import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';
import 'package:pokeapi_pokedex/servicios/pokemons_favoritos.dart';

class PokemonGridCard extends StatefulWidget {
  final Pokemon pokemon;
  final Function toggleTheme;
  final bool isDarkMode;
  final Function(String)? onFavoriteRemoved;

  const PokemonGridCard({
    super.key,
    required this.pokemon,
    required this.toggleTheme,
    required this.isDarkMode,
    this.onFavoriteRemoved,
  });

  @override
  State<PokemonGridCard> createState() => _PokemonGridCardState();
}

class _PokemonGridCardState extends State<PokemonGridCard> {
  bool _esFavorito = false;

  @override
  void initState() {
    super.initState();
    _actualizarEstadoFavorito();
  }

  Future<void> _actualizarEstadoFavorito() async {
    final esFav =
        await PokemonsFavoritos.comprobarSiEsFavorito(widget.pokemon.name);
    setState(() {
      _esFavorito = esFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_esFavorito) {
      await PokemonsFavoritos.eliminarPokemonFavorito(widget.pokemon.name);
      if (widget.onFavoriteRemoved != null) {
        widget.onFavoriteRemoved!(widget.pokemon.name);
      }
    } else {
      await PokemonsFavoritos.agregarPokemonFavorito(widget.pokemon);
    }
    setState(() {
      _esFavorito = !_esFavorito;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonStatsPage(
              name: widget.pokemon.name,
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          decoration: ColorTipo.obtenerTransparencia(
            widget.pokemon.types.first,
            isDarkMode: widget.isDarkMode,
            segundoTipo: widget.pokemon.types.length > 1
                ? widget.pokemon.types[1]
                : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.pokemon.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _esFavorito
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _esFavorito
                                ? ColorTipo.obtenerColorTipo(
                                    widget.pokemon.types.first)
                                : ColorTipo.obtenerColorTipo(
                                        widget.pokemon.types.first)
                                    .withAlpha(128),
                            size: 20,
                          ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.pokemon.types
                          .map((tipo) => PokemonTypeIcon(
                                tipo: tipo,
                                isDarkMode: widget.isDarkMode,
                                small: true,
                                simple: true,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: Image.network(
                          widget.pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
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
            ],
          ),
        ),
      ),
    );
  }
}
