import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';

class PokemonStatsPage extends StatefulWidget {
  final String name;
  final Function toggleTheme;
  final bool isDarkMode;
  final Pokemon? pokemonPreCargado;

  const PokemonStatsPage({
    super.key,
    required this.name,
    required this.toggleTheme,
    required this.isDarkMode,
    this.pokemonPreCargado,
  });

  @override
  State<PokemonStatsPage> createState() => _PokemonStatsPageState();
}

class _PokemonStatsPageState extends State<PokemonStatsPage> {
  Pokemon? _pokemon;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.pokemonPreCargado != null) {
      setState(() {
        _pokemon = widget.pokemonPreCargado;
        _isLoading = false;
      });
    } else {
      _cargarPokemon();
    }
  }

  Future<void> _cargarPokemon() async {
    try {
      final pokemonObtenido = await PokeAPI.obtenerDetallesPokemon(widget.name);
      setState(() {
        _pokemon = pokemonObtenido;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _traducirNombreEstadisticas(String nombreEstadistica) {
    switch (nombreEstadistica) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Ataque';
      case 'defense':
        return 'Defensa';
      case 'special-attack':
        return 'Ataque Especial';
      case 'special-defense':
        return 'Defensa Especial';
      case 'speed':
        return 'Velocidad';
      default:
        return nombreEstadistica;
    }
  }

  Color _conseguirColorEstadisticas(int valor) {
    if (valor < 50) return Colors.red;
    if (valor < 100) return Colors.orange;
    if (valor < 150) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.name.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon:
                  Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => widget.toggleTheme(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 15),
              child: Column(
                children: [
                  Image.network(
                    _pokemon!.imageUrl,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Icon(Icons.error,
                            size: 50,
                            color: Theme.of(context).colorScheme.error),
                      );
                    },
                  ),
                  Text(
                    _pokemon!.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _pokemon!.types
                        .map((type) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: PokemonTypeIcon(
                                tipo: type,
                                isDarkMode: widget.isDarkMode,
                                simple: false,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context).dividerColor
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Altura',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_pokemon!.height} dm',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Peso',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_pokemon!.weight} hg',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estadísticas Base',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._pokemon!.stats!.entries.map((stat) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Theme.of(context).dividerColor
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _traducirNombreEstadisticas(stat.key),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  stat.value.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: stat.value / 255,
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[200]
                                    : Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _conseguirColorEstadisticas(stat.value)),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
