import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';

class PokemonTypeIcon extends StatelessWidget {
  final String tipo;
  final bool isDarkMode;
  final bool small;
  final bool simple;

  const PokemonTypeIcon({
    super.key,
    required this.tipo,
    required this.isDarkMode,
    this.small = false,
    this.simple = false,
  });

  static const Map<String, String> _tiposTraducidos = {
    'normal': 'NORMAL',
    'fire': 'FUEGO',
    'water': 'AGUA',
    'grass': 'PLANTA',
    'electric': 'ELÉCTRICO',
    'ice': 'HIELO',
    'fighting': 'LUCHA',
    'poison': 'VENENO',
    'ground': 'TIERRA',
    'flying': 'VOLADOR',
    'psychic': 'PSÍQUICO',
    'bug': 'BICHO',
    'rock': 'ROCA',
    'ghost': 'FANTASMA',
    'dark': 'SINIESTRO',
    'dragon': 'DRAGÓN',
    'steel': 'ACERO',
    'fairy': 'HADA',
  };

  String _traducirTipo(String tipo) {
    return _tiposTraducidos[tipo.toLowerCase()] ?? tipo;
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorTipo.obtenerColorTipo(tipo);

    if (!simple) {
      return Chip(
        label: Text(
          _traducirTipo(tipo),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.8 : 0.9),
        borderRadius: BorderRadius.circular(small ? 4 : 8),
      ),
      child: Text(
        _traducirTipo(tipo),
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
