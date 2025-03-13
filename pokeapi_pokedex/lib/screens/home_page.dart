import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_card.dart';
import 'package:pokeapi_pokedex/widgets/search_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
  final ScrollController _controladorScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarPokemons();
    _controladorScroll.addListener(() {
      if (_controladorScroll.position.pixels >=
              _controladorScroll.position.maxScrollExtent - 200 &&
          !_cargandoPokemons &&
          !_cargandoMasPokemons &&
          _queryDeBusqueda.isEmpty) {
        _cargarMasPokemons();
      }
    });
  }

  Future<void> _cargarPokemons() async {
    setState(() {
      _cargandoPokemons = true;
    });
    try {
      final pokemons =
          await PokeAPI.obtenerPokemons(limit: _numDePokemons, offset: _offset);
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
      final nuevosPokemons =
          await PokeAPI.obtenerPokemons(limit: _numDePokemons, offset: _offset);
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
    await _cargarPokemons();
  }

  Future<void> _buscarPokemons(String query) async {
    if (query.isEmpty) {
      await _cargarOtraVezLosPokemons();
      return;
    }

    setState(() {
      _cargandoPokemons = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('POKÉDEX', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          PokemonSearchBar(
            onSearch: (value) {
              setState(() {
                _queryDeBusqueda = value;
              });
              _buscarPokemons(value);
            },
            scrollController: _controladorScroll,
          ),
          Expanded(
            child: _cargandoPokemons
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red))
                : RefreshIndicator(
                    onRefresh: _cargarOtraVezLosPokemons,
                    child: ListView.builder(
                      controller: _controladorScroll,
                      itemCount:
                          _pokemons.length + (_cargandoMasPokemons ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _pokemons.length) {
                          final pokemon = _pokemons[index];
                          return PokemonCard(pokemon: pokemon);
                        }
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                              child:
                                  CircularProgressIndicator(color: Colors.red)),
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
