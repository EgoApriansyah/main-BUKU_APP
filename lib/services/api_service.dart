import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP ini sesuai kebutuhan Anda
  // - Untuk emulator: http://10.0.2.2
  // - Untuk HP fisik: http://[IP_KOMPUTER_ANDA]
  static const String _baseUrl = "http://10.0.2.2/buku_app/api.php";

  // User Authentication
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    return json.decode(response.body);
  }

  // Bookmark Operations
  // Bookmark Operations
  static Future<List<dynamic>> getBookmarks(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=get_bookmarks&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        // API.php mengembalikan array [] jika kosong atau ada isinya
        return json.decode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Koneksi Gagal: $e');
    }
  }

  static Future<Map<String, dynamic>> addBookmark(
    int userId, 
    String bookId, 
    String title, 
    String author, 
    String cover,
    String description, // Tambah Parameter
    Map<String, dynamic> details // Tambah Parameter
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl?action=add_bookmark"),
      body: jsonEncode({
        'user_id': userId,
        'book_id': bookId,
        'book_title': title,
        'book_author': author,
        'book_cover': cover,
        'book_description': description, // Kirim ke PHP
        'book_details': details, // Kirim ke PHP
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateBookmark(
      int id, String bookTitle, String bookAuthor, String bookCover) async {
    final response = await http.put(
      Uri.parse('$_baseUrl?action=update_bookmark'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'book_title': bookTitle,
        'book_author': bookAuthor,
        'book_cover': bookCover,
      }),
    );

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteBookmark(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl?action=delete_bookmark&id=$id'),
    );

    return json.decode(response.body);
  }
}

