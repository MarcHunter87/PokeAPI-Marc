import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';
import 'package:pokeapi_pokedex/servicios/pokeapi.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Pokemon> _pokemons = [];
  final int _numDePokemons = 20;
  bool _cargandoPokemons = false;
  bool _cargandoMasPokemons = false;
  int _offset = 0;
  final ScrollController _controladorScroll = ScrollController();
  String _queryDeBusqueda = "";

  @override
  void initState() {
    super.initState();
    _cargarPokemons();
    _controladorScroll.addListener(() {
      if (_controladorScroll.position.pixels >= _controladorScroll.position.maxScrollExtent - 200 && !_cargandoMasPokemons && !_cargandoPokemons) {
        _cargarMasPokemons();
      }
    });
  }

  Future<void> _cargarPokemons() async {
    setState(() {
      _cargandoPokemons = true;
    });

    try {
      final pokemons = await PokeAPI.obtenerPokemons(limit: _numDePokemons, offset: _offset);
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
      final nuevosPokemons = await PokeAPI.obtenerPokemons(limit: _numDePokemons, offset: _offset);
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
  void dispose() {
    _controladorScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokemonsBuscados = _pokemons.where((pokemon) => pokemon.name.toLowerCase().startsWith(_queryDeBusqueda.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('POKÉDEX', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        surfaceTintColor: Colors.transparent,
      ),

      body: _cargandoPokemons
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : RefreshIndicator(
        onRefresh: _cargarOtraVezLosPokemons,
        child: ListView.builder(
          controller: _controladorScroll,
          itemCount: 1 + pokemonsBuscados.length + (_cargandoMasPokemons ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar Pokémons',
                    hintStyle: const TextStyle(color: Color.fromRGBO(189, 189, 189, 1)),
                    fillColor: const Color.fromRGBO(48, 48, 48, 1),
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _queryDeBusqueda = value;
                    });
                  },
                ),
              );
            }
            if (index <= pokemonsBuscados.length) {
              final pokemon = pokemonsBuscados[index - 1];
              return Card(
                color: const Color.fromRGBO(48, 48, 48, 1),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pokemon.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    pokemon.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: Colors.red)),
            );
          },
        ),
      ),
    );
  }
}
