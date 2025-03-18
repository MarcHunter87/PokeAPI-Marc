import 'package:flutter/material.dart';

class ColorTipo {
  static Color obtenerColorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'normal':
        return const Color(0xFFA8A878);
      case 'fire':
        return const Color(0xFFF08030);
      case 'water':
        return const Color(0xFF6890F0);
      case 'grass':
        return const Color(0xFF78C850);
      case 'electric':
        return const Color(0xFFF8D030);
      case 'ice':
        return const Color(0xFF98D8D8);
      case 'fighting':
        return const Color(0xFFC03028);
      case 'poison':
        return const Color(0xFFA040A0);
      case 'ground':
        return const Color(0xFFE0C068);
      case 'flying':
        return const Color(0xFFA890F0);
      case 'psychic':
        return const Color(0xFFF85888);
      case 'bug':
        return const Color(0xFFA8B820);
      case 'rock':
        return const Color(0xFFB8A038);
      case 'ghost':
        return const Color(0xFF705898);
      case 'dark':
        return const Color(0xFF705848);
      case 'dragon':
        return const Color(0xFF7038F8);
      case 'steel':
        return const Color(0xFFB8B8D0);
      case 'fairy':
        return const Color(0xFFEE99AC);
      default:
        return const Color(0xFFA8A878);
    }
  }

  static BoxDecoration obtenerTransparencia(String tipo,
      {bool isDarkMode = false, String? segundoTipo}) {
    final color = obtenerColorTipo(tipo);
    if (segundoTipo != null) {
      final colorSecundario = obtenerColorTipo(segundoTipo);
      return BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.9),
            isDarkMode
                ? colorSecundario.withOpacity(0.2)
                : colorSecundario.withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.9),
          width: 1.5,
        ),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.9),
      border: Border.all(
        color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.9),
        width: 1.5,
      ),
    );
  }
}
