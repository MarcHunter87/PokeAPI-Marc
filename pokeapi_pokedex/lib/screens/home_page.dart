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
          !_cargandoMasPokemons &&
          !_cargandoPokemons) {
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
      print('Error al cargar pokémons: $error');
    }
  }

  Future<void> _cargarMasPokemons() async {
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
      print('Error al cargar más pokémons: $error');
    }
  }

  Future<void> _cargarOtraVezLosPokemons() async {
    setState(() {
      _offset = 0;
      _pokemons.clear();
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('POKÉDEX', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        surfaceTintColor: Colors.transparent,
      ),
      body: _cargandoPokemons
          //Si es true, muestra la CircularProgressIndicator, si es false, muestra RefreshIndicator
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : RefreshIndicator(
              onRefresh: _cargarOtraVezLosPokemons,
              child: ListView.builder(
                controller: _controladorScroll,
                //Si _cargandoMasPokemons es true, se suma 1 al itemCount para que se muestre el CircularProgressIndicator
                itemCount: 1 +
                    pokemonsBuscados.length +
                    (_cargandoMasPokemons ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return PokemonSearchBar(
                      onSearch: (value) {
                        setState(() {
                          _queryDeBusqueda = value;
                        });
                      },
                    );
                  }
                  if (index <= pokemonsBuscados.length) {
                    final pokemon = pokemonsBuscados[index - 1];
                    return PokemonCard(pokemon: pokemon);
                  }
                  //No se muestra a menos que _cargandoMasPokemons sea true
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.red)),
                  );
                },
              ),
            ),
    );
  }
}
