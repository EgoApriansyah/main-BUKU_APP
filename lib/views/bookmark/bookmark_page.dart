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
    // Load bookmarks when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
      bookmarkProvider.loadBookmarks(authProvider.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: bookmarkProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : bookmarkProvider.bookmarks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No bookmarks yet'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await bookmarkProvider.loadBookmarks(authProvider.user!.id);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarkProvider.bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarkProvider.bookmarks[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Navigate to book detail page
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BookDetailPage(
                                    book: bookmark.toBook(),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Book cover
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      bookmark.bookCover,
                                      width: 100,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 150,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.book, size: 50),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Book info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bookmark.bookTitle,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Author: ${bookmark.bookAuthor}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Added on ${_formatDate(bookmark.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        const Spacer(),
                                        
                                        // Action buttons
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                _showDeleteConfirmation(context, bookmark);
                                              },
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
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete "${bookmark.bookTitle}" from your bookmarks?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final bookmarkProvider =
              Provider.of<BookmarkProvider>(context, listen: false);
              await bookmarkProvider.deleteBookmark(bookmark);

            },
          ),
        ],
      ),
    );
  }
}

// Extension to convert Bookmark to Book
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