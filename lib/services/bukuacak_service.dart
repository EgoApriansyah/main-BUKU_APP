import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class BukuAcakService {
  static const String _baseUrl = "https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1/book";

  static Future<List<Book>> getBooks({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> booksJson = data['books'];
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  static Future<List<Book>> searchBooks(String query) async {
  // 1. Ambil semua buku dulu (atau gunakan endpoint search yang benar jika ada)
  final response = await http.get(Uri.parse(_baseUrl));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> booksJson = data['books'];
    
    // 2. Ubah jadi list object Book
    List<Book> allBooks = booksJson.map((json) => Book.fromJson(json)).toList();

    // 3. Filter manual berdasarkan judul atau penulis
    return allBooks.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      final searchLower = query.toLowerCase();
      
      return titleLower.contains(searchLower) || authorLower.contains(searchLower);
    }).toList();
  } else {
    throw Exception('Failed to load books');
  }
}

  static Future<Book> getBookById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Failed to load book');
    }
  }
}