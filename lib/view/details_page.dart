import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'add_edit_page.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  DetailsPage({required this.restaurant});

  void _deleteRestaurant(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white, 
          colorScheme: ColorScheme.light(
            primary: Colors.red, 
            onPrimary: Colors.white, 
            onSurface: Colors.black, 
          ),
        ),
        child: AlertDialog(
          title: Text('Excluir Restaurante', style: TextStyle(color: Colors.red)),
          content: Text(
            'Tem certeza que deseja excluir este restaurante?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Excluir', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed ?? false) {
      await DatabaseHelper().deleteRestaurant(restaurant['id']);
      Navigator.pop(context, true);
    }
  }

  void _editRestaurant(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditPage(restaurant: restaurant),
      ),
    );
    Navigator.pop(context, true); 
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
      appBar: AppBar(title: Text('Detalhes do Restaurante')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (restaurant['imagePath'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(restaurant['imagePath']),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),
              Text(
                'Nome: ${restaurant['name']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Nota:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildRatingStars(restaurant['rating']),
              SizedBox(height: 10),
              Text('Tipo de Restaurante: ${restaurant['category']}'),
              SizedBox(height: 10),
              if (restaurant['orderDetails'] != null &&
                  restaurant['orderDetails'].isNotEmpty)
                Text('Pedido: ${restaurant['orderDetails']}'),
              SizedBox(height: 10),
              if (restaurant['visitDate'] != null &&
                  restaurant['visitDate'].isNotEmpty)
                Text('Data de Visita: ${restaurant['visitDate']}'),
              SizedBox(height: 10),
              if (restaurant['comment'] != null &&
                  restaurant['comment'].isNotEmpty)
                Text('Comentário: ${restaurant['comment']}'),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _editRestaurant(context),
                    child: Text('Editar'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _deleteRestaurant(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
