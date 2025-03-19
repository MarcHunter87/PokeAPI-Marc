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
              'TODOS',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
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
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            selectedColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(204),
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
                    color: Theme.of(context).colorScheme.onSurface,
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
                backgroundColor:
                    isDarkMode ? color.withAlpha(51) : color.withAlpha(102),
                selectedColor:
                    isDarkMode ? color.withAlpha(77) : color.withAlpha(179),
              ),
            );
          }),
        ],
      ),
    );
  }
}
