import 'package:flutter/material.dart';
import 'package:libraryapp/screens/register_screen.dart';
import 'package:libraryapp/screens/update_book_screen.dart';
import 'package:libraryapp/services/book_service.dart'; // Adjust the import path as per your project structure
import 'package:libraryapp/settings.dart';
import 'package:provider/provider.dart';
import 'package:libraryapp/screens/theme_provider.dart';
import 'package:libraryapp/modles/book.dart'; // Adjust the import path as per your project structure

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => DatabaseHelper()), // Ensure DatabaseHelper is correctly imported and initialized
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibraryApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Provider.of<ThemeProvider>(context).isDarkMode
            ? Brightness.dark
            : Brightness.light,
      ),
      routes: {
        '/register': (context) => RegisterScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Book>> _booksFuture;
  String _sortBy = 'title';
  bool _ascending = true;
  TextEditingController _searchController = TextEditingController(); // Controller for the search field

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final DatabaseHelper _databaseHelper =
        Provider.of<DatabaseHelper>(context, listen: false);

    try {
      _booksFuture =
          _databaseHelper.getAllBooks(sortBy: _sortBy, ascending: _ascending);
    } catch (e) {
      print('Error fetching books: $e');
      _booksFuture = Future.error(e);
    }
  }

  Future<void> _deleteBook(int id) async {
    try {
      final DatabaseHelper _databaseHelper =
          Provider.of<DatabaseHelper>(context, listen: false);
      int deleted = await _databaseHelper.deleteBook(id);
      if (deleted > 0) {
        setState(() {
          _loadBooks();
        });
      }
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  void _toggleSortingOrder() {
    setState(() {
      _ascending = !_ascending;
    });
    _loadBooks();
  }

  Future<void> _performSearch(String query) async {
    final DatabaseHelper _databaseHelper =
        Provider.of<DatabaseHelper>(context, listen: false);
  
    // Debounce or delay search action to avoid frequent calls
    await Future.delayed(Duration(milliseconds: 300));

    if (query.isEmpty) {
      // If search query is empty, load all books
      _loadBooks();
    } else {
      try {
        List<Book> searchResults = await _databaseHelper.searchBook(query);
        setState(() {
          _booksFuture = Future.value(searchResults);
        });
      } catch (e) {
        print('Error searching books: $e');
        setState(() {
          _booksFuture = Future.error(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _loadBooks();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Sort by Title'), value: 'title'),
              const PopupMenuItem(child: Text('Sort by Author'), value: 'author'),
              const PopupMenuItem(child: Text('Sort by Rating'), value: 'rating'),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _toggleSortingOrder(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Register'),
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings'); // Updated route name
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No books found.'));
                } else {
                  // Check if snapshot.data is actually a List<Book>
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Book book = snapshot.data![index];
                            return ListTile(
                              title: Text(book.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Author: ${book.author}'),
                                  Text('Rating: ${book.rating}'),
                                  Text('Read: ${book.isRead ? 'True' : 'False'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteBook(book.id!);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateScreen(bookId: book.id!),
                                        ),
                                      ).then((_) {
                                        _loadBooks();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to book details screen if needed
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20), // Adjust the height as needed
                     
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
