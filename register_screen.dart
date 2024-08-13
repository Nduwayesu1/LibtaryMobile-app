import 'package:flutter/material.dart';
import 'package:libraryapp/modles/book.dart';
import 'package:libraryapp/services/book_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _isbnController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();
  bool _isRead = false;

  final _formKey = GlobalKey<FormState>();
  late final DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _databaseHelper.initDB();
      await _databaseHelper.initPreferences();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        id: null,
        title: _titleController.text,
        author: _authorController.text,
        year: int.tryParse(_yearController.text) ?? 0,
        isbn: _isbnController.text,
        isRead: _isRead,
        rating: int.tryParse(_ratingController.text) ?? 0,
      );

      try {
        int result = await _databaseHelper.insertBook(newBook);

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Book registered successfully'),
            ),
          );

          _titleController.clear();
          _authorController.clear();
          _yearController.clear();
          _isbnController.clear();
          _ratingController.clear();
          setState(() {
            _isRead = false;
          });

          Navigator.pop(context);
        } else {
          throw Exception('Failed to register book');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register book'),
          ),
        );
        print('Error saving book: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New Book'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the author name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Publication Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the publication year';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(
                  labelText: 'ISBN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ISBN';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid ISBN';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(
                  labelText: 'Rating (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid rating';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _isRead,
                    onChanged: (value) {
                      setState(() {
                        _isRead = value ?? false;
                      });
                    },
                  ),
                  Text('Mark as Read'),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveBook();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
