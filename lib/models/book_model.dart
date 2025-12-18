class Book {
  final String id;
  final String title;
  final String coverImage;
  final String author;
  final String category;
  final String summary;
  final Map<String, dynamic> details;
  final List<dynamic> tags;

  Book({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.author,
    required this.category,
    required this.summary,
    required this.details,
    required this.tags,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      coverImage: json['cover_image'] ?? '',
      author: json['author']?['name'] ?? '',
      category: json['category']?['name'] ?? '',
      summary: json['summary'] ?? '',
      details: json['details'] ?? {},
      tags: json['tags'] ?? [],
    );
  }
}