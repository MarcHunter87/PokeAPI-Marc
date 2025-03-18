import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';

class PokemonStatsPage extends StatefulWidget {
  final String name;
  final Function toggleTheme;
  final bool isDarkMode;

  const PokemonStatsPage({
    super.key,
    required this.name,
    required this.toggleTheme,
    required this.isDarkMode,
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
    _cargarPokemon();
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

  Color _conseguirColorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'normal':
        return const Color.fromRGBO(189, 189, 189, 1);
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return const Color.fromRGBO(245, 124, 0, 1);
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigo;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.deepPurple;
      case 'dark':
        return const Color.fromRGBO(66, 66, 66, 1);
      case 'dragon':
        return const Color.fromRGBO(48, 63, 159, 1);
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
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
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon:
                  Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => widget.toggleTheme(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 15),
              child: Column(
                children: [
                  Image.network(
                    _pokemon!.imageUrl,
                    width: 200,
                    fit: BoxFit.contain,
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
                    children: _pokemon!.types!
                        .map((type) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Chip(
                                label: Text(
                                  type.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: _conseguirColorTipo(type),
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
