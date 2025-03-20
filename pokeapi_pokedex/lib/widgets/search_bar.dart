import 'package:flutter/material.dart';

class PokemonSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final ScrollController scrollController;

  const PokemonSearchBar({
    super.key,
    required this.onSearch,
    required this.scrollController,
  });

  void _handleSearch(String value) {
    onSearch(value);
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar Pokémons',
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          fillColor: Theme.of(context).cardColor,
          filled: true,
          prefixIcon:
              Icon(Icons.search, color: Theme.of(context).iconTheme.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        cursorColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : null,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        onChanged: _handleSearch,
      ),
    );
  }
}
