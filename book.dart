class Book {
  final int? id;
  final String title;
  final String author;
  final int year;
  final String isbn;
  final bool isRead;
  final int rating;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.isbn,
    this.isRead = false,
    this.rating = 0,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      year: json['year'],
      isbn: json['isbn'],
      isRead: json['isRead'] == 1, // Convert int to bool
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'year': year,
      'isbn': isbn,
      'isRead': isRead ? 1 : 0, // Convert bool to int
      'rating': rating,
    };
  }
}
