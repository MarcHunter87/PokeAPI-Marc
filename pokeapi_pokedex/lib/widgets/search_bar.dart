import 'package:flutter/material.dart';

class PokemonSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final ScrollController scrollController;
  final String searchText;

  const PokemonSearchBar({
    super.key,
    required this.onSearch,
    required this.scrollController,
    required this.searchText,
  });

  @override
  State<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends State<PokemonSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchText);
  }

  @override
  void didUpdateWidget(PokemonSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchText != _controller.text) {
      _controller.text = widget.searchText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    widget.onSearch(value);
    if (widget.scrollController.hasClients) {
      widget.scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
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
