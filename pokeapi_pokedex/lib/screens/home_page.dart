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
  final int _numDePokemonsBase = 20;
  int _numPokemonsMostrados = 20;
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
          _queryDeBusqueda.isEmpty &&
          _numPokemonsMostrados < _pokemons.length) {
        _mostrarMasPokemons();
      }
    });
  }

  Future<void> _cargarPokemons() async {
    setState(() {
      _cargandoPokemons = true;
    });
    try {
      final pokemons = await PokeAPI.obtenerPokemons();
      setState(() {
        _pokemons = pokemons;
        _numPokemonsMostrados = _numDePokemonsBase;
        _cargandoPokemons = false;
      });
    } catch (error) {
      setState(() {
        _cargandoPokemons = false;
      });
      print('Error al cargar pokémons: $error');
    }
  }

  Future<void> _mostrarMasPokemons() async {
    setState(() {
      _cargandoMasPokemons = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _numPokemonsMostrados =
          (_numPokemonsMostrados + _numDePokemonsBase) > _pokemons.length
              ? _pokemons.length
              : _numPokemonsMostrados + _numDePokemonsBase;
      _cargandoMasPokemons = false;
    });
  }

  Future<void> _cargarOtraVezLosPokemons() async {
    setState(() {
      _pokemons.clear();
      _queryDeBusqueda = "";
    });
    await _cargarPokemons();
  }

  @override
  Widget build(BuildContext context) {
    final pokemonsBuscados = _pokemons
        .where((pokemon) => pokemon.name
            .toLowerCase()
            .startsWith(_queryDeBusqueda.toLowerCase()))
        .toList();

    final pokemonsMostrados =
        pokemonsBuscados.take(_numPokemonsMostrados).toList();

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
                _numPokemonsMostrados = _numDePokemonsBase;
              });
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
                      itemCount: pokemonsMostrados.length +
                          (_cargandoMasPokemons ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < pokemonsMostrados.length) {
                          final pokemon = pokemonsMostrados[index];
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
