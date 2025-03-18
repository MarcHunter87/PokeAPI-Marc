import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_card.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_grid_card.dart';
import 'package:pokeapi_pokedex/widgets/search_bar.dart';
import 'package:pokeapi_pokedex/servicios/pokemons_favoritos.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_filter.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';

class MyHomePage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const MyHomePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Pokemon> _pokemons = [];
  final int _numDePokemons = 20;
  int _offset = 0;
  bool _cargandoPokemons = false;
  bool _cargandoMasPokemons = false;
  String _queryDeBusqueda = "";
  String? _tipoSeleccionado;
  final ScrollController _controladorScroll = ScrollController();
  bool _vistaEnCuadricula = false;
  bool _mostrandoFavoritos = false;

  @override
  void initState() {
    super.initState();
    _cargarPokemons();
    _controladorScroll.addListener(() {
      if (_controladorScroll.position.pixels >=
              _controladorScroll.position.maxScrollExtent - 200 &&
          !_cargandoPokemons &&
          !_cargandoMasPokemons &&
          _queryDeBusqueda.isEmpty &&
          !_mostrandoFavoritos) {
        _cargarMasPokemons();
      }
    });
  }

  Future<void> _cargarPokemons() async {
    setState(() {
      _cargandoPokemons = true;
    });
    try {
      final pokemons = _tipoSeleccionado != null
          ? await PokeAPI.obtenerPokemonsPorTipo(
              _tipoSeleccionado!,
              limit: _numDePokemons,
              offset: _offset,
            )
          : await PokeAPI.obtenerPokemons(
              limit: _numDePokemons,
              offset: _offset,
            );
      setState(() {
        _pokemons = pokemons;
        _cargandoPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
      });
    }
  }

  Future<void> _cargarPokemonsFavoritos() async {
    setState(() {
      _cargandoPokemons = true;
      _mostrandoFavoritos = true;
      _queryDeBusqueda = "";
      _pokemons = [];
    });

    try {
      final favoritos = await PokemonsFavoritos.obtenerPokemonsFavoritos();
      if (mounted) {
        setState(() {
          _pokemons = favoritos;
          _cargandoPokemons = false;
        });

        if (favoritos.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tienes Pokémon favoritos guardados'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _cargandoPokemons = false;
          _mostrandoFavoritos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al cargar los Pokémon favoritos'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _cargarPokemonsFavoritos,
            ),
          ),
        );
      }
    }
  }

  Future<void> _cargarMasPokemons() async {
    if (_cargandoMasPokemons || _mostrandoFavoritos) return;

    setState(() {
      _cargandoMasPokemons = true;
      _offset += _numDePokemons;
    });

    try {
      final nuevosPokemons = _tipoSeleccionado != null
          ? await PokeAPI.obtenerPokemonsPorTipo(
              _tipoSeleccionado!,
              limit: _numDePokemons,
              offset: _offset,
            )
          : await PokeAPI.obtenerPokemons(
              limit: _numDePokemons,
              offset: _offset,
            );
      setState(() {
        _pokemons.addAll(nuevosPokemons);
        _cargandoMasPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoMasPokemons = false;
      });
    }
  }

  Future<void> _cargarOtraVezLosPokemons() async {
    setState(() {
      _offset = 0;
      _pokemons.clear();
      _mostrandoFavoritos = false;
    });
    await _cargarPokemons();
  }

  Future<void> _buscarPokemons(String query) async {
    if (query.isEmpty) {
      await _cargarOtraVezLosPokemons();
      return;
    }

    setState(() {
      _cargandoPokemons = true;
      _mostrandoFavoritos = false;
      _tipoSeleccionado = null;
    });

    try {
      final pokemonsBuscados = await PokeAPI.buscarPokemons(query);
      setState(() {
        _pokemons = pokemonsBuscados;
        _cargandoPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
      });
    }
  }

  void _filtrarPorTipo(String? tipo) {
    setState(() {
      _tipoSeleccionado = tipo;
      _offset = 0;
      _pokemons.clear();
      _mostrandoFavoritos = false;
      _queryDeBusqueda = "";
    });
    _cargarPokemons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'POKÉDEX',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _mostrandoFavoritos ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              if (_mostrandoFavoritos) {
                _cargarOtraVezLosPokemons();
              } else {
                _cargarPokemonsFavoritos();
              }
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
          PokemonSearchBar(
            onSearch: (value) {
              setState(() {
                _queryDeBusqueda = value;
                _tipoSeleccionado = null;
              });
              _buscarPokemons(value);
            },
            scrollController: _controladorScroll,
          ),
          PokemonTypeFilter(
            tipoSeleccionado: _tipoSeleccionado,
            onTipoSeleccionado: _filtrarPorTipo,
            isDarkMode: widget.isDarkMode,
          ),
          Expanded(
            child: _cargandoPokemons
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red))
                : RefreshIndicator(
                    onRefresh: _cargarOtraVezLosPokemons,
                    child: _vistaEnCuadricula
                        ? GridView.builder(
                            controller: _controladorScroll,
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _pokemons.length +
                                (_cargandoMasPokemons ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _pokemons.length) {
                                final pokemon = _pokemons[index];
                                return PokemonGridCard(
                                  pokemon: pokemon,
                                  toggleTheme: widget.toggleTheme,
                                  isDarkMode: widget.isDarkMode,
                                );
                              }
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.red)),
                              );
                            },
                          )
                        : ListView.builder(
                            controller: _controladorScroll,
                            itemCount: _pokemons.length +
                                (_cargandoMasPokemons ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _pokemons.length) {
                                final pokemon = _pokemons[index];
                                return PokemonCard(
                                  pokemon: pokemon,
                                  toggleTheme: widget.toggleTheme,
                                  isDarkMode: widget.isDarkMode,
                                );
                              }
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.red)),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
