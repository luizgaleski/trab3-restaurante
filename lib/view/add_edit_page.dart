import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';

class AddEditPage extends StatefulWidget {
  final Map<String, dynamic>? restaurant;

  AddEditPage({this.restaurant});

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _orderController = TextEditingController();
  final _commentController = TextEditingController();

  String? _selectedCategory;
  String? _imagePath;
  String? _selectedDate;

  final List<String> _categories = [
    'Comida Italiana',
    'Comida Brasileira',
    'Comida Japonesa',
    'Fast Food',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      _nameController.text = widget.restaurant!['name'];
      _ratingController.text = widget.restaurant!['rating'].toString();
      _orderController.text = widget.restaurant!['orderDetails'];
      _commentController.text = widget.restaurant!['comment'];
      _selectedCategory = widget.restaurant!['category'];
      _imagePath = widget.restaurant!['imagePath'];
      _selectedDate = widget.restaurant!['visitDate'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').parse(_selectedDate!)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white, 
              onSurface: Colors.black, 
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _saveRestaurant() async {
    if (_formKey.currentState!.validate()) {
      final restaurant = {
        'id': widget.restaurant?['id'],
        'name': _nameController.text,
        'rating': int.parse(_ratingController.text),
        'orderDetails': _orderController.text,
        'visitDate': _selectedDate,
        'comment': _commentController.text,
        'category': _selectedCategory,
        'imagePath': _imagePath,
      };

      if (widget.restaurant == null) {
        await DatabaseHelper().insertRestaurant(restaurant);
      } else {
        await DatabaseHelper().updateRestaurant(restaurant);
      }

      Navigator.pop(context);
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant == null ? 'Adicionar Restaurante' : 'Editar Restaurante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Colors.black), 
                  ),
                  validator: (value) => value!.isEmpty ? 'Este campo é obrigatório' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _ratingController,
                  decoration: InputDecoration(
                    labelText: 'Nota (0 a 5)',
                    labelStyle: TextStyle(color: Colors.black), 
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final rating = int.tryParse(value!);
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'Insira uma nota válida (0 a 5)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tipo de Restaurante',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, selecione uma categoria' : null,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data de Visita',
                        hintText: 'Selecione a data',
                        labelStyle: TextStyle(color: Colors.black), 
                        hintStyle: TextStyle(color: Colors.red), 
                      ),
                      controller: TextEditingController(text: _selectedDate),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, selecione uma data'
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _orderController,
                  decoration: InputDecoration(
                    labelText: 'Pedido',
                    labelStyle: TextStyle(color: Colors.black), 
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Comentário',
                    labelStyle: TextStyle(color: Colors.black), 
                  ),
                ),
                SizedBox(height: 20),
                _imagePath == null
                    ? TextButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image, color: Colors.red),
                        label: Text(
                          'Selecionar Imagem',
                          style: TextStyle(color: Colors.red), 
                        ),
                      )
                    : Column(
                        children: [
                          Image.file(File(_imagePath!), height: 200),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.image, color: Colors.red),
                                label: Text(
                                  'Alterar Imagem',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _removeImage,
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text(
                                  'Remover Imagem',
                                  style: TextStyle(color: Colors.red), 
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _saveRestaurant,
                      child: Text('Salvar'),
                    ),
                    ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
