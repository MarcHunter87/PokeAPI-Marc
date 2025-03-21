import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';
import 'package:pokeapi_pokedex/servicios/pokemons_favoritos.dart';

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  final Function toggleTheme;
  final bool isDarkMode;
  final Function(String)? onFavoriteRemoved;
  final Function(Pokemon)? onFavoriteAdded;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.toggleTheme,
    required this.isDarkMode,
    this.onFavoriteRemoved,
    this.onFavoriteAdded,
  });

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool _esFavorito = false;

  @override
  void initState() {
    super.initState();
    _actualizarEstadoFavorito();
  }

  @override
  void didUpdateWidget(PokemonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pokemon.name != widget.pokemon.name) {
      _actualizarEstadoFavorito();
    }
  }

  Future<void> _actualizarEstadoFavorito() async {
    final esFav =
        await PokemonsFavoritos.comprobarSiEsFavorito(widget.pokemon.name);
    if (mounted) {
      setState(() {
        _esFavorito = esFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_esFavorito) {
      await PokemonsFavoritos.eliminarPokemonFavorito(widget.pokemon.name);
      if (widget.onFavoriteRemoved != null) {
        widget.onFavoriteRemoved!(widget.pokemon.name);
      }
    } else {
      await PokemonsFavoritos.agregarPokemonFavorito(widget.pokemon);
      if (widget.onFavoriteAdded != null) {
        widget.onFavoriteAdded!(widget.pokemon);
      }
    }
    if (mounted) {
      setState(() {
        _esFavorito = !_esFavorito;
      });
    }
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
              pokemonPreCargado: widget.pokemon,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Hero(
                    tag: 'pokemon-image-${widget.pokemon.name}',
                    child: Image.network(
                      widget.pokemon.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pokemon.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: widget.pokemon.types
                            .map((tipo) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: PokemonTypeIcon(
                                    tipo: tipo,
                                    isDarkMode: widget.isDarkMode,
                                    small: true,
                                    simple: true,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _esFavorito ? Icons.favorite : Icons.favorite_border,
                    color: _esFavorito
                        ? ColorTipo.obtenerColorTipo(widget.pokemon.types.first)
                        : ColorTipo.obtenerColorTipo(widget.pokemon.types.first)
                            .withAlpha(128),
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
