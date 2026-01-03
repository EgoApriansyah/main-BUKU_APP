import 'dart:convert';

class Bookmark {
  final int id;
  final int userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCover;
  final String bookDescription;
  final Map<String, dynamic> bookDetails;
  final String createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCover,
    required this.bookDescription,
    required this.bookDetails,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    // Logika untuk menangani book_details yang mungkin datang sebagai String atau Map
    Map<String, dynamic> parsedDetails = {};
    if (json['book_details'] != null) {
      if (json['book_details'] is String) {
        try {
          parsedDetails = jsonDecode(json['book_details']);
        } catch (e) {
          parsedDetails = {};
        }
      } else if (json['book_details'] is Map) {
        parsedDetails = Map<String, dynamic>.from(json['book_details']);
      }
    }

    return Bookmark(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      bookId: json['book_id'].toString(),
      bookTitle: json['book_title'] ?? '',
      bookAuthor: json['book_author'] ?? '',
      bookCover: json['book_cover'] ?? '',
      bookDescription: json['book_description'] ?? '',
      bookDetails: parsedDetails,
      createdAt: json['created_at'] ?? '',
    );
  }
}