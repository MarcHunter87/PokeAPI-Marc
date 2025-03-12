import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/modelos/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(48, 48, 48, 1),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                pokemon.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,

                //Seguro por si falla la imagen
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                pokemon.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
