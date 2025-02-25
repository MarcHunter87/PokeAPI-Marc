import 'package:flutter/material.dart';

class PokemonSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const PokemonSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
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
        onChanged: onSearch,
      ),
    );
  }
}
