import 'package:flutter/material.dart';

class AllCategoriesModal extends StatelessWidget {
  final Function(String) onCategorySelected;

  const AllCategoriesModal({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          AppBar(
            title: Text('All Categories'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _categoryTile('Medical', Icons.local_hospital, Colors.red, context),
                _categoryTile('Parks', Icons.park, Colors.green, context),
                _categoryTile('Pensions', Icons.home, Colors.blue, context),
                _categoryTile('Restaurants', Icons.restaurant, Colors.orange, context),
                _categoryTile('Beauty Salons', Icons.spa, Colors.purple, context),
                _categoryTile('Hotels', Icons.hotel, Colors.teal, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(String title, IconData icon, Color color, BuildContext context) {
    return InkWell(
      onTap: () {
        onCategorySelected(title.toLowerCase());
        Navigator.pop(context);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}