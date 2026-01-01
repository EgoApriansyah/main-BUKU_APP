import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../models/bookmark_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../detail/book_detail.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil data setelah frame selesai untuk menghindari error build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    
    // Perbaikan: Pastikan user tidak null sebelum memanggil ID
    if (authProvider.user != null) {
      bookmarkProvider.loadBookmarks(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // listen: true di sini agar UI update saat isLoading berubah
    final authProvider = Provider.of<AuthProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        // Cek apakah user sudah login
        child: authProvider.user == null 
          ? const Center(child: Text("Silahkan login terlebih dahulu"))
          : _buildContent(bookmarkProvider, authProvider),
      ),
    );
  }

  Widget _buildContent(BookmarkProvider bookmarkProvider, AuthProvider authProvider) {
    if (bookmarkProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookmarkProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(bookmarkProvider.errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _loadData, child: const Text("Coba Lagi"))
          ],
        ),
      );
    }

    if (bookmarkProvider.bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada bookmark.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarkProvider.bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarkProvider.bookmarks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => BookDetailPage(book: bookmark.toBook())),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        bookmark.bookCover,
                        width: 80, height: 120, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80, height: 120, color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bookmark.bookTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
                          const SizedBox(height: 4),
                          Text('Penulis: ${bookmark.bookAuthor}', style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Text('Simpan: ${_formatDate(bookmark.createdAt)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, bookmark),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) { return dateString; }
  }

  void _showDeleteConfirmation(BuildContext context, Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Bookmark'),
        content: Text('Yakin ingin menghapus "${bookmark.bookTitle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<BookmarkProvider>(context, listen: false).deleteBookmark(bookmark);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

extension BookmarkToBook on Bookmark {
  Book toBook() {
    return Book(
      id: bookId,
      title: bookTitle,
      coverImage: bookCover,
      author: bookAuthor,
      category: '',
      summary: '',
      details: {},
      tags: [],
    );
  }
}