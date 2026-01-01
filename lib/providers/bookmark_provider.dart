import 'package:flutter/material.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../utils/notification_helper.dart';

class BookmarkProvider with ChangeNotifier {
  final List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===================================
  // LOAD BOOKMARKS (DIAMBIL DARI MYSQL)
  // ===================================
  Future<void> loadBookmarks(int userId) async {
    _isLoading = true;
    // Kita panggil notify agar UI menampilkan loading indicator
    notifyListeners();

    try {
      // API kamu mengembalikan List<dynamic> secara langsung
      final List<dynamic> data = await ApiService.getBookmarks(userId);

      _bookmarks.clear();
      // Mengubah List JSON menjadi List Object Bookmark
      _bookmarks.addAll(data.map((json) => Bookmark.fromJson(json)).toList());
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memuat bookmark: ${e.toString()}";
      print("Error Load Bookmark: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================================
  // ADD BOOKMARK
  // ===================================
  Future<bool> addBookmark(int userId, Book book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.addBookmark(
        userId,
        book.id,
        book.title,
        book.author,
        book.coverImage,
      );

      // Sesuai api.php: status 1 berarti sukses
      if (response['status'] == 1) {
        // Setelah sukses di DB, kita tarik data terbaru agar sinkron
        await loadBookmarks(userId);

        await NotificationHelper.showNotification(
          'Bookmark Added',
          '"${book.title}" ditambahkan ke bookmark',
        );
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================================
  // DELETE BOOKMARK
  // ===================================
  Future<bool> deleteBookmark(Bookmark bookmark) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.deleteBookmark(bookmark.id);

      if (response['status'] == 1) {
        // Hapus dari list lokal agar UI langsung update
        _bookmarks.removeWhere((b) => b.id == bookmark.id);

        await NotificationHelper.showNotification(
          'Bookmark Deleted',
          '"${bookmark.bookTitle}" dihapus',
        );
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================================
  // HELPER UNTUK CEK STATUS (DI DETAIL)
  // ===================================
  bool isBookmarked(String bookId) {
    return _bookmarks.any((b) => b.bookId == bookId);
  }

  Bookmark? getBookmarkByBookId(String bookId) {
    try {
      return _bookmarks.firstWhere((b) => b.bookId == bookId);
    } catch (_) {
      return null;
    }
  }
}