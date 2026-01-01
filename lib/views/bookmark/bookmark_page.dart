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
    // Memanggil data setelah frame selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      bookmarkProvider.loadBookmarks(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Soft White/Blue khas Dribbble
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Modern
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF8FAFF),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'My Bookmarks',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),

          // Cek Status Login & Data
          SliverFillRemaining(
            hasScrollBody: true,
            child: authProvider.user == null 
              ? _buildEmptyState(Icons.lock_outline, "Please login to see bookmarks")
              : _buildContent(bookmarkProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BookmarkProvider bookmarkProvider) {
    if (bookmarkProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }

    if (bookmarkProvider.bookmarks.isEmpty) {
      return _buildEmptyState(Icons.bookmark_add_outlined, "No books saved yet.");
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: bookmarkProvider.bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarkProvider.bookmarks[index];
          return _buildModernBookmarkCard(bookmark);
        },
      ),
    );
  }

  Widget _buildModernBookmarkCard(Bookmark bookmark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => BookDetailPage(book: bookmark.toBook())),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Book Image with Soft Shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      bookmark.bookCover,
                      width: 85,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 85, height: 120, color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bookmark.bookAuthor,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saved: ${_formatDate(bookmark.createdAt)}',
                            style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: () => _showDeleteConfirmation(context, bookmark),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.blue.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Bookmark?'),
        content: Text('Delete "${bookmark.bookTitle}" from your saved list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<BookmarkProvider>(context, listen: false).deleteBookmark(bookmark);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Extension untuk memperbaiki error toBook() tanpa merubah model file asli
extension BookmarkToBook on Bookmark {
  Book toBook() {
    return Book(
      id: bookId,
      title: bookTitle,
      coverImage: bookCover,
      author: bookAuthor,
      category: 'Saved', 
      summary: '', // Akan di-load ulang di detail page jika perlu
      details: {},
      tags: [],
    );
  }
}