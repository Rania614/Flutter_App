class Book {
  final String title;
  final double price;
  final double rating;
  final String image;
  final String subject;

  Book({
    required this.title,
    required this.price,
    required this.rating,
    required this.image,
    required this.subject,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? 'Unknown Title',
      price: json['price'] != null
          ? (json['price'] is String
              ? double.parse(json['price'])
              : json['price'].toDouble())
          : 0.0,
      rating: json['rating']?.toDouble() ?? 4.0,
      image: json['image'] ?? 'https://via.placeholder.com/150',
      subject: json['subject'] ?? 'Unknown Subject',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price.toString(),
      'rating': rating,
      'image': image,
      'subject': subject,
    };
  }
}