import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final isBookmarked = bookmarkProvider.isBookmarked(book.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// ===============================
          /// APP BAR + COVER
          /// ===============================
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    book.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.book, size: 100),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (isBookmarked) {
                    final bookmark =
                        bookmarkProvider.getBookmarkByBookId(book.id);
                    if (bookmark != null) {
                      await bookmarkProvider.deleteBookmark(bookmark);
                    }
                  } else {
                    await bookmarkProvider.addBookmark(
                      authProvider.user!.id,
                      book,
                    );
                  }
                },
              ),
            ],
          ),

          /// ===============================
          /// CONTENT
          /// ===============================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// AUTHOR & CATEGORY
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(book.author),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      Chip(
                        label: Text(book.category),
                        backgroundColor: Colors.green.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// BOOK DETAILS
                  const Text(
                    'Book Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (_isValid(book.details['isbn']))
                          _buildDetailRow(
                              'ISBN', book.details['isbn']),
                        if (_isValid(book.details['price']))
                          _buildDetailRow(
                              'Price', book.details['price']),
                        if (_isValid(book.details['total_pages']))
                          _buildDetailRow(
                              'Total Pages',
                              book.details['total_pages']),
                        if (_isValid(book.details['size']))
                          _buildDetailRow(
                              'Size', book.details['size']),
                        if (_isValid(book.details['published_date']))
                          _buildDetailRow(
                              'Published Date',
                              book.details['published_date']),
                        if (_isValid(book.details['format']))
                          _buildDetailRow(
                              'Format', book.details['format']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// SUMMARY
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.summary,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  /// TAGS (🔥 FIXED)
                  if (book.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: book.tags.map((tag) {
                        final tagName = tag is Map
                            ? tag['name']?.toString() ?? ''
                            : tag.toString();

                        if (tagName.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Chip(
                          label: Text(
                            tagName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          backgroundColor: Colors.purple.shade100,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// HELPER
  /// ===============================
  static bool _isValid(dynamic value) {
    return value != null && value.toString().isNotEmpty && value != '0';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
