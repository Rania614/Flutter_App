import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book_model.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({required this.book});

  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteBooks = prefs.getStringList('favorites') ?? [];
    final bookJson = jsonEncode(widget.book.toJson());
    setState(() {
      isFavorite = favoriteBooks.contains(bookJson);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteBooks = prefs.getStringList('favorites') ?? [];
    final bookJson = jsonEncode(widget.book.toJson());

    if (isFavorite) {
      favoriteBooks.remove(bookJson);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.book.title} removed from favorites!')),
      );
    } else {
      favoriteBooks.add(bookJson);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.book.title} added to favorites!')),
      );
    }

    await prefs.setStringList('favorites', favoriteBooks);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.book.image,
                    height: 250,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 200),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.book.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.book.price == 0.0 ? "Free" : "\$${widget.book.price}",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "${widget.book.rating}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "This is a placeholder description for ${widget.book.title}. You can add more details about the book here, such as the summary, author, or publication date.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  label: Text(
                    isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    List<String> cartBooks = prefs.getStringList('cart') ?? [];
                    final bookJson = jsonEncode(widget.book.toJson());
                    if (!cartBooks.contains(bookJson)) {
                      cartBooks.add(bookJson);
                      await prefs.setStringList('cart', cartBooks);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.book.title} added to cart!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.book.title} is already in cart!')),
                      );
                    }
                  },
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}