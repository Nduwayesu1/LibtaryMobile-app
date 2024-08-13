import 'package:flutter/material.dart';
import 'package:libraryapp/modles/book.dart'; // Correct import path
import 'package:libraryapp/services/book_service.dart'; // Adjust based on your file structure

class UpdateScreen extends StatefulWidget {
  final int bookId; // Change type to int

  UpdateScreen({required this.bookId});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _yearController;
  late TextEditingController _isbnController;
  late TextEditingController _ratingController;
  bool _isRead = false;

  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Correct instantiation

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadBook();
  }

  void _initializeFields() {
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _yearController = TextEditingController();
    _isbnController = TextEditingController();
    _ratingController = TextEditingController();
  }

  Future<void> _loadBook() async {
    try {
      Book? book = await _databaseHelper.getBook(widget.bookId); // Pass widget.bookId directly
      if (book != null) {
        setState(() {
          _titleController.text = book.title;
          _authorController.text = book.author;
          _yearController.text = book.year.toString();
          _isbnController.text = book.isbn;
          _ratingController.text = book.rating.toString();
          _isRead = book.isRead ?? false; // Ensure _isRead is not null
        });
      } else {
        throw Exception('Book not found');
      }
    } catch (e) {
      print('Error loading book: $e');
      // Handle error as needed
    }
  }

  void _updateBook() async {
    if (_formKey.currentState!.validate()) {
      final updatedBook = Book(
        id: widget.bookId,
        title: _titleController.text,
        author: _authorController.text,
        year: int.tryParse(_yearController.text) ?? 0,
        isbn: _isbnController.text,
        isRead: _isRead,
        rating: int.tryParse(_ratingController.text) ?? 0,
      );

      try {
        int result = await _databaseHelper.updateBook(updatedBook);

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Book updated successfully'),
            ),
          );

          // Navigate back to home screen after updating book
          Navigator.pop(context);
        } else {
          throw Exception('Failed to update book');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update book'),
          ),
        );
        print('Error updating book: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Book'),
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
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _isRead,
                    onChanged: (value) {
                      setState(() {
                        _isRead = value ?? false; // Ensure _isRead is not null
                      });
                    },
                  ),
                  Text('Is Read'),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rating';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid rating';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBook,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
}
