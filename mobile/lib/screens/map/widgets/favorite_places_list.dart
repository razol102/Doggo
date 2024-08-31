import 'package:flutter/material.dart';
import 'package:mobile/screens/map/set_favorite_place.dart';
import 'package:mobile/services/http_service.dart';

import '../../../main.dart';

class FavoritePlacesList extends StatefulWidget {
  final int dogId;

  const FavoritePlacesList({Key? key, required this.dogId}) : super(key: key);

  @override
  _FavoritePlacesListState createState() => _FavoritePlacesListState();
}

class _FavoritePlacesListState extends State<FavoritePlacesList> with RouteAware {
  List<Map<String, dynamic>> favoritePlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoritePlaces();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    // Unsubscribe from RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the user navigates back to this screen
    _fetchFavoritePlaces();
  }

  Future<void> _fetchFavoritePlaces() async {
    try {
      final home = await _getFavoritePlace('home');
      final dogPark = await _getFavoritePlace('dog park');
      final petStore = await _getFavoritePlace('pet store');

      setState(() {
        favoritePlaces = [home, dogPark, petStore];
      });
    } catch (e) {
      print('Failed to load favorite places: $e');
    }
  }

  Future<Map<String, dynamic>> _getFavoritePlace(String placeType) async {
    final place = await HttpService.getFavoritePlaceByType(widget.dogId, placeType);
    if (place == null) {
      return {
        'place_name': 'Save your favorite $placeType',
        'address': '',
        'place_type': placeType
      };
    }
    return place;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Favorite Places:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: favoritePlaces.length,
            itemBuilder: (context, index) {
              final place = favoritePlaces[index];
              return ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text(place['place_name']),
                subtitle: place['address'].isNotEmpty ? Text(place['address']) : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetFavoritePlace(
                        dogId: widget.dogId,
                        placeType: place['place_type'],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
