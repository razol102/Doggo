import 'package:flutter/material.dart';

class FavoritePlacesList extends StatelessWidget {
  final List<Map<String, dynamic>> favoritePlaces;

  const FavoritePlacesList({Key? key, required this.favoritePlaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Favorite Places:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true, // Shrinks the ListView to fit its content
            itemCount: favoritePlaces.length,
            itemBuilder: (context, index) {
              final place = favoritePlaces[index];
              return ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text(place['name']),
                subtitle: Text(place['address']),
              );
            },
          ),
        ),
      ],
    );
  }
}
