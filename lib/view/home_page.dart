import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'add_edit_page.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    final data = await DatabaseHelper().getRestaurants();
    setState(() {
      _restaurants = data;
    });
  }

  void _navigateToAddEditPage([Map<String, dynamic>? restaurant]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditPage(restaurant: restaurant),
      ),
    );
    _fetchRestaurants();
  }

  void _navigateToDetailsPage(Map<String, dynamic> restaurant) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailsPage(restaurant: restaurant),
      ),
    );

    if (updated == true) {
      _fetchRestaurants();
    }
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/reviews_icon.png',
                  width: 40,
                  height: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Reviews',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _restaurants.isEmpty
                  ? Center(child: Text('Nenhum restaurante adicionado ainda.'))
                  : ListView.builder(
                      itemCount: _restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = _restaurants[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: restaurant['imagePath'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(restaurant['imagePath']),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.restaurant, size: 50, color: Colors.red),
                            title: Text(
                              restaurant['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: _buildRatingStars(restaurant['rating']),
                            onTap: () => _navigateToDetailsPage(restaurant),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToAddEditPage(),
      ),
    );
  }
}
