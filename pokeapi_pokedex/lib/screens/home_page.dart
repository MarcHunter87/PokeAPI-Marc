import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_card.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_grid_card.dart';
import 'package:pokeapi_pokedex/widgets/search_bar.dart';
import 'package:pokeapi_pokedex/servicios/pokemons_favoritos.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_filter.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';

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
  bool _ordenAlfabetico = false;
  String _letraActual = 'a';
  final List<String> _letras = 'abcdefghijklmnopqrstuvwxyz'.split('');

  @override
  void initState() {
    super.initState();
    _cargarPokemons();
    _controladorScroll.addListener(() {
      if (_controladorScroll.position.pixels >=
              _controladorScroll.position.maxScrollExtent - 200 &&
          !_cargandoPokemons &&
          !_cargandoMasPokemons) {
        if (_ordenAlfabetico) {
          _cargarSiguienteLetra();
        } else if (_queryDeBusqueda.isEmpty && !_mostrandoFavoritos) {
          _cargarMasPokemons();
        }
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
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _cargandoPokemons = false;
          _mostrandoFavoritos = false;
        });
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
      if (_mostrandoFavoritos) {
        _filtrarFavoritosPorTipo(tipo);
      } else {
        _offset = 0;
        _pokemons.clear();
        _queryDeBusqueda = "";
        _cargarPokemons();
      }
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

  Future<void> _mostrarPokemonAleatorio() async {
    setState(() {
      _cargandoPokemons = true;
    });

    late final Pokemon pokemon;

    while (true) {
      try {
        final randomId = (DateTime.now().millisecondsSinceEpoch % 1500) + 1;
        pokemon = await PokeAPI.obtenerPokemonPorId(randomId);
        break;
      } catch (error) {
        continue;
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonStatsPage(
            name: pokemon.name,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            pokemonPreCargado: pokemon,
          ),
        ),
      );
    }

    setState(() {
      _cargandoPokemons = false;
    });
  }

  Future<void> _cargarPokemonsAlfabeticamente() async {
    setState(() {
      _cargandoPokemons = true;
      _pokemons = [];
    });

    try {
      final pokemonsDeLetra = await PokeAPI.buscarPokemons(_letraActual);
      setState(() {
        _pokemons = pokemonsDeLetra;
        _cargandoPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
      });
    }
  }

  Future<void> _cargarSiguienteLetra() async {
    if (!_ordenAlfabetico || _cargandoMasPokemons) return;

    final currentIndex = _letras.indexOf(_letraActual);
    if (currentIndex >= _letras.length - 1) return;

    setState(() {
      _cargandoMasPokemons = true;
    });

    try {
      final siguienteLetra = _letras[currentIndex + 1];
      final pokemonsDeLetra = await PokeAPI.buscarPokemons(siguienteLetra);

      if (mounted) {
        setState(() {
          _pokemons.addAll(pokemonsDeLetra);
          _letraActual = siguienteLetra;
          _cargandoMasPokemons = false;
        });
      }
    } catch (error) {
      setState(() {
        _cargandoMasPokemons = false;
      });
    }
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
            icon: const Icon(
              Icons.shuffle,
              color: Colors.white,
            ),
            onPressed: _mostrarPokemonAleatorio,
          ),
          IconButton(
            icon: Icon(
              _ordenAlfabetico ? Icons.sort_by_alpha : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _ordenAlfabetico = !_ordenAlfabetico;
                if (_ordenAlfabetico) {
                  _cargarPokemonsAlfabeticamente();
                } else {
                  _cargarOtraVezLosPokemons();
                }
              });
            },
          ),
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
          if (_pokemons.isEmpty && _mostrandoFavoritos)
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
                                child:
                                    Center(child: CircularProgressIndicator()),
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
                                child:
                                    Center(child: CircularProgressIndicator()),
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
