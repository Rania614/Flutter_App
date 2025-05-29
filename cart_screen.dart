import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book_model.dart';
import 'book_details_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Book> cartBooks = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartBooksJson = prefs.getStringList('cart') ?? [];
    setState(() {
      cartBooks = cartBooksJson
          .map((bookJson) => Book.fromJson(jsonDecode(bookJson)))
          .toList();
    });
  }

  Future<void> _removeFromCart(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartBooks = prefs.getStringList('cart') ?? [];
    final bookJson = jsonEncode(book.toJson());
    cartBooks.remove(bookJson);
    await prefs.setStringList('cart', cartBooks);
    _loadCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} removed from cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartBooks.isEmpty
          ? Center(child: Text('Your cart is empty!'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: cartBooks.length,
              itemBuilder: (context, index) {
                final book = cartBooks[index];
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
                      onPressed: () => _removeFromCart(book),
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
      bottomNavigationBar: cartBooks.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proceeding to checkout...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Checkout (\$${cartBooks.fold(0.0, (sum, book) => sum + book.price).toStringAsFixed(2)})',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}