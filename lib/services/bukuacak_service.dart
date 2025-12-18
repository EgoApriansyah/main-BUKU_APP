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
    final response = await http.get(
      Uri.parse('$_baseUrl?search=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> booksJson = data['books'];
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
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