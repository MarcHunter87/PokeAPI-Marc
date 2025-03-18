import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/widgets/pokemon_type_icon.dart';
import 'package:pokeapi_pokedex/servicios/color_tipo.dart';

class PokemonTypeFilter extends StatelessWidget {
  final String? tipoSeleccionado;
  final Function(String?) onTipoSeleccionado;
  final bool isDarkMode;

  const PokemonTypeFilter({
    super.key,
    required this.tipoSeleccionado,
    required this.onTipoSeleccionado,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
      child: Row(
        children: [
          FilterChip(
            label: Text(
              'Todos',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: tipoSeleccionado == null,
            onSelected: (selected) {
              if (selected) {
                onTipoSeleccionado(null);
              }
            },
            showCheckmark: false,
            backgroundColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.15),
            selectedColor: isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.25),
          ),
          const SizedBox(width: 12),
          ...PokemonTypeIcon.tiposTraducidos.entries.map((entry) {
            final color = ColorTipo.obtenerColorTipo(entry.key);
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: tipoSeleccionado == entry.key,
                onSelected: (selected) {
                  if (selected) {
                    onTipoSeleccionado(entry.key);
                  }
                },
                showCheckmark: false,
                backgroundColor: isDarkMode
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.4),
                selectedColor: isDarkMode
                    ? color.withOpacity(0.3)
                    : color.withOpacity(0.7),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
