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
    scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
        onChanged: _handleSearch,
      ),
    );
  }
}
