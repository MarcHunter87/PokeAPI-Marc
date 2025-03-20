import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_card.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_grid_card.dart';
import 'package:pokeapi_pokedex/widgets/search_bar.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_filter.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';
import 'package:pokeapi_pokedex/screens/pokemon_stats_page.dart';
import 'package:pokeapi_pokedex/screens/favoritos_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  bool _ordenAlfabetico = false;
  String _letraActual = 'a';
  final List<String> _letras = 'abcdefghijklmnopqrstuvwxyz'.split('');
  bool _sinConexion = false;

  @override
  void initState() {
    super.initState();
    _verificarConexion();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          _sinConexion = true;
          _pokemons = [];
        });
      } else if (_sinConexion) {
        setState(() => _sinConexion = false);
        if (_queryDeBusqueda.isNotEmpty) {
          _buscarPokemons(_queryDeBusqueda);
        } else {
          _cargarOtraVezLosPokemons();
        }
      }
    });
    _cargarPokemons();
    _controladorScroll.addListener(() {
      if (_controladorScroll.position.pixels >=
              _controladorScroll.position.maxScrollExtent - 200 &&
          !_cargandoPokemons &&
          !_cargandoMasPokemons) {
        if (_ordenAlfabetico) {
          _cargarSiguienteLetra();
        } else if (_queryDeBusqueda.isEmpty) {
          _cargarMasPokemons();
        }
      }
    });
  }

  Future<void> _verificarConexion() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _sinConexion = connectivityResult == ConnectivityResult.none;
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

  Future<void> _cargarMasPokemons() async {
    if (_cargandoMasPokemons) return;

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
    });

    if (_ordenAlfabetico) {
      await _cargarPokemonsAlfabeticamente();
    } else {
      await _cargarPokemons();
    }
  }

  Future<void> _buscarPokemons(String query) async {
    if (query.isEmpty) {
      await _cargarOtraVezLosPokemons();
      return;
    }

    setState(() {
      _cargandoPokemons = true;
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
      if (_ordenAlfabetico) {
        _pokemons.clear();
        if (tipo == null) {
          _cargarPokemonsAlfabeticamente();
        } else {
          _cargarPokemonsPorTipoAlfabeticamente(tipo);
        }
      } else {
        _offset = 0;
        _pokemons.clear();
        _queryDeBusqueda = "";
        _cargarPokemons();
      }
    });
  }

  Future<void> _mostrarPokemonAleatorio() async {
    setState(() {
      _cargandoPokemons = true;
    });

    try {
      final pokemon = await PokeAPI.obtenerPokemonAleatorio();

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
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
      });
    }
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

  Future<void> _cargarPokemonsPorTipoAlfabeticamente(String tipo) async {
    setState(() {
      _cargandoPokemons = true;
      _pokemons = [];
    });

    try {
      final pokemonsPorTipo = await PokeAPI.obtenerPokemonsPorTipo(tipo);
      pokemonsPorTipo.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _pokemons = pokemonsPorTipo;
        _cargandoPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
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
                  if (_tipoSeleccionado != null) {
                    _cargarPokemonsPorTipoAlfabeticamente(_tipoSeleccionado!);
                  } else {
                    _cargarPokemonsAlfabeticamente();
                  }
                } else {
                  _cargarOtraVezLosPokemons();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritosPage(
                    toggleTheme: widget.toggleTheme,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
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
          if (_queryDeBusqueda.isEmpty && !_sinConexion)
            PokemonTypeFilter(
              tipoSeleccionado: _tipoSeleccionado,
              onTipoSeleccionado: _filtrarPorTipo,
              isDarkMode: widget.isDarkMode,
            ),
          if (_pokemons.isEmpty && _queryDeBusqueda.isNotEmpty && !_sinConexion)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No se encontraron Pokémons que empiecen con "$_queryDeBusqueda"',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          if (_sinConexion && _pokemons.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: !widget.isDarkMode
                    ? Border.all(color: Colors.black, width: 1)
                    : null,
              ),
              child: Text(
                'No hay conexión a Internet. Una vez regrese volverá a funcionar la Pokedex',
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
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
