import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book_model.dart';
import 'book_details_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';

class BookStoreScreen extends StatefulWidget {
  @override
  _BookStoreScreenState createState() => _BookStoreScreenState();
}

class _BookStoreScreenState extends State<BookStoreScreen> {
  List<Book> books = [];
  bool isLoading = false;
  String errorMessage = '';
  String selectedCategory = 'All';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      final response = await dio.get('https://www.dbooks.org/api/recent');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['status'] == 'ok') {
          final List<dynamic> bookList = data['books'];
          setState(() {
            books = bookList.map((json) => Book.fromJson(json)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load books from API';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load books: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  List<Book> getFilteredBooks() {
    if (selectedCategory == 'All') return books;
    return books.where((book) {
      if (selectedCategory == 'Fiction' && book.subject.toLowerCase().contains('fiction')) return true;
      if (selectedCategory == 'Fiction' && book.subject.toLowerCase().contains('novel')) return true;
      if (selectedCategory == 'History' && book.subject.toLowerCase().contains('history')) return true;
      if (selectedCategory == 'Science' && book.subject.toLowerCase().contains('science')) return true;
      if (selectedCategory == 'Science' && book.subject.toLowerCase().contains('technology')) return true;
      return false;
    }).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoritesScreen()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Book Store',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryButton(label: "All", isSelected: selectedCategory == 'All', onTap: () {
                    setState(() {
                      selectedCategory = 'All';
                    });
                  }),
                  SizedBox(width: 10),
                  CategoryButton(label: "Fiction", isSelected: selectedCategory == 'Fiction', onTap: () {
                    setState(() {
                      selectedCategory = 'Fiction';
                    });
                  }),
                  SizedBox(width: 10),
                  CategoryButton(label: "History", isSelected: selectedCategory == 'History', onTap: () {
                    setState(() {
                      selectedCategory = 'History';
                    });
                  }),
                  SizedBox(width: 10),
                  CategoryButton(label: "Science", isSelected: selectedCategory == 'Science', onTap: () {
                    setState(() {
                      selectedCategory = 'Science';
                    });
                  }),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                      : ListView.builder(
                          itemCount: getFilteredBooks().length,
                          itemBuilder: (context, index) {
                            final book = getFilteredBooks()[index];
                            return BookCard(
                              image: book.image,
                              title: book.title,
                              price: book.price.toString(),
                              rating: book.rating,
                              book: book,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  CategoryButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.redAccent : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: isSelected ? 5 : 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class BookCard extends StatefulWidget {
  final String image;
  final String title;
  final String price;
  final double rating;
  final Book book;

  BookCard({
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
    required this.book,
  });

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
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

  Future<void> _addToCart() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: widget.book),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.image,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.price == "0.0" ? "Free" : "\$${widget.price}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: _addToCart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}