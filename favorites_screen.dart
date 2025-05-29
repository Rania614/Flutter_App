import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book_model.dart';
import 'book_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Book> favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteBooksJson = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoriteBooks = favoriteBooksJson
          .map((bookJson) => Book.fromJson(jsonDecode(bookJson)))
          .toList();
    });
  }

  Future<void> _removeFromFavorites(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteBooks = prefs.getStringList('favorites') ?? [];
    final bookJson = jsonEncode(book.toJson());
    favoriteBooks.remove(bookJson);
    await prefs.setStringList('favorites', favoriteBooks);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} removed from favorites!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favoriteBooks.isEmpty
          ? Center(child: Text('No favorite books yet!'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: favoriteBooks.length,
              itemBuilder: (context, index) {
                final book = favoriteBooks[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      book.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image),
                    ),
                    title: Text(book.title),
                    subtitle: Text(
                      book.price == 0.0 ? "Free" : "\$${book.price}",
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromFavorites(book),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsScreen(book: book),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}