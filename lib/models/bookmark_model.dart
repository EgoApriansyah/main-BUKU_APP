class Bookmark {
  final int id;
  final int userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCover;
  final String createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCover,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookId: json['book_id'] ?? '',
      bookTitle: json['book_title'] ?? '',
      bookAuthor: json['book_author'] ?? '',
      bookCover: json['book_cover'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}