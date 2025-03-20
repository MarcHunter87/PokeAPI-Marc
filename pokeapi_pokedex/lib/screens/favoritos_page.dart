import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokemons_favoritos.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_card.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_grid_card.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_filter.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';

class FavoritosPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const FavoritosPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<Pokemon> _pokemons = [];
  bool _cargandoPokemons = false;
  String? _tipoSeleccionado;
  bool _vistaEnCuadricula = false;
  bool _ordenAlfabetico = false;

  @override
  void initState() {
    super.initState();
    _cargarPokemonsFavoritos();
  }

  Future<void> _cargarPokemonsFavoritos() async {
    setState(() {
      _cargandoPokemons = true;
      _tipoSeleccionado = null;
      _pokemons = [];
    });

    try {
      final favoritos = await PokemonsFavoritos.obtenerPokemonsFavoritos();

      if (_ordenAlfabetico) {
        favoritos.sort((a, b) => a.name.compareTo(b.name));
      }

      if (mounted) {
        setState(() {
          _pokemons = favoritos;
          _cargandoPokemons = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _cargandoPokemons = false;
        });
      }
    }
  }

  void _filtrarPorTipo(String? tipo) {
    setState(() {
      _tipoSeleccionado = tipo;
      _filtrarFavoritosPorTipo(tipo);
    });
  }

  Future<void> _filtrarFavoritosPorTipo(String? tipo) async {
    if (tipo == null) {
      _cargarPokemonsFavoritos();
      return;
    }

    setState(() {
      _cargandoPokemons = true;
    });

    try {
      final favoritos = await PokemonsFavoritos.obtenerPokemonsFavoritos();
      final pokemonsFiltrados =
          favoritos.where((pokemon) => pokemon.types.contains(tipo)).toList();

      if (_ordenAlfabetico) {
        pokemonsFiltrados.sort((a, b) => a.name.compareTo(b.name));
      }

      setState(() {
        _pokemons = pokemonsFiltrados;
        _cargandoPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
      });
    }
  }

  void _eliminarPokemonDeFavoritos(String nombrePokemon) {
    setState(() {
      _pokemons.removeWhere((pokemon) => pokemon.name == nombrePokemon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'FAVORITOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _ordenAlfabetico ? Icons.sort_by_alpha : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _ordenAlfabetico = !_ordenAlfabetico;
                if (_ordenAlfabetico) {
                  if (_tipoSeleccionado != null) {
                    _filtrarFavoritosPorTipo(_tipoSeleccionado);
                  } else {
                    _cargarPokemonsFavoritos();
                  }
                } else {
                  if (_tipoSeleccionado != null) {
                    _filtrarFavoritosPorTipo(_tipoSeleccionado);
                  } else {
                    _cargarPokemonsFavoritos();
                  }
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              _vistaEnCuadricula ? Icons.grid_view : Icons.view_list,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              setState(() {
                _vistaEnCuadricula = !_vistaEnCuadricula;
              });
            },
          ),
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          PokemonTypeFilter(
            tipoSeleccionado: _tipoSeleccionado,
            onTipoSeleccionado: _filtrarPorTipo,
            isDarkMode: widget.isDarkMode,
          ),
          if (_pokemons.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _tipoSeleccionado != null
                    ? 'No tienes Pokémons de tipo ${PokemonTypeIcon.tiposTraducidos[_tipoSeleccionado]?.toLowerCase() ?? _tipoSeleccionado} guardados en favoritos'
                    : 'No tienes Pokémons guardados en favoritos',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _cargandoPokemons
                ? const Center(child: CircularProgressIndicator())
                : _vistaEnCuadricula
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _pokemons.length,
                        itemBuilder: (context, index) {
                          final pokemon = _pokemons[index];
                          return PokemonGridCard(
                            pokemon: pokemon,
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                            onFavoriteRemoved: _eliminarPokemonDeFavoritos,
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _pokemons.length,
                        itemBuilder: (context, index) {
                          final pokemon = _pokemons[index];
                          return PokemonCard(
                            pokemon: pokemon,
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                            onFavoriteRemoved: _eliminarPokemonDeFavoritos,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
