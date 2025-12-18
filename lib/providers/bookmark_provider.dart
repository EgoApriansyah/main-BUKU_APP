import 'package:flutter/material.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../utils/notification_helper.dart';

class BookmarkProvider with ChangeNotifier {
  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load bookmarks for a user
  Future<void> loadBookmarks(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bookmarks = await ApiService.getBookmarks(userId);
      _bookmarks = bookmarks.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add a bookmark
  Future<bool> addBookmark(int userId, Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.addBookmark(
        userId,
        book.id,
        book.title,
        book.author,
        book.coverImage,
      );
      
      if (response['status'] == 1) {
        // Refresh bookmarks
        await loadBookmarks(userId);
        
        // Show notification
        await NotificationHelper.showNotification(
          'Bookmark Added',
          'You have added "${book.title}" to your bookmarks',
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

  // Update a bookmark
  Future<bool> updateBookmark(Bookmark bookmark) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.updateBookmark(
        bookmark.id,
        bookmark.bookTitle,
        bookmark.bookAuthor,
        bookmark.bookCover,
      );
      
      if (response['status'] == 1) {
        // Refresh bookmarks
        await loadBookmarks(bookmark.userId);
        
        // Show notification
        await NotificationHelper.showNotification(
          'Bookmark Updated',
          'You have updated "${bookmark.bookTitle}" bookmark',
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

  // Delete a bookmark
  Future<bool> deleteBookmark(Bookmark bookmark) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteBookmark(bookmark.id);
      
      if (response['status'] == 1) {
        // Refresh bookmarks
        await loadBookmarks(bookmark.userId);
        
        // Show notification
        await NotificationHelper.showNotification(
          'Bookmark Deleted',
          'You have removed "${bookmark.bookTitle}" from your bookmarks',
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

  // Check if a book is bookmarked
  bool isBookmarked(String bookId) {
    return _bookmarks.any((bookmark) => bookmark.bookId == bookId);
  }

  // Get bookmark by book ID
  Bookmark? getBookmarkByBookId(String bookId) {
    try {
      return _bookmarks.firstWhere((bookmark) => bookmark.bookId == bookId);
    } catch (e) {
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}