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
          // App bar with book cover
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
                    errorBuilder: (context, error, stackTrace) {
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
                    // Remove bookmark
                    final bookmark = bookmarkProvider.getBookmarkByBookId(book.id);
                    if (bookmark != null) {
                      await bookmarkProvider.deleteBookmark(bookmark);
                    }
                  } else {
                    // Add bookmark
                    await bookmarkProvider.addBookmark(
                      authProvider.user!.id,
                      book,
                    );
                  }
                },
              ),
            ],
          ),
          
          // Book details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Author and category
                  Row(
                    children: [
                      Chip(
                        label: Text('Author: ${book.author}'),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('Category: ${book.category}'),
                        backgroundColor: Colors.green.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Book details
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
                        if (book.details['isbn'] != null && book.details['isbn'] != '0')
                          _buildDetailRow('ISBN', book.details['isbn']),
                        if (book.details['price'] != null && book.details['price'] != '')
                          _buildDetailRow('Price', book.details['price']),
                        if (book.details['total_pages'] != null && book.details['total_pages'] != '')
                          _buildDetailRow('Total Pages', book.details['total_pages']),
                        if (book.details['size'] != null && book.details['size'] != '')
                          _buildDetailRow('Size', book.details['size']),
                        if (book.details['published_date'] != null && book.details['published_date'] != '')
                          _buildDetailRow('Published Date', book.details['published_date']),
                        if (book.details['format'] != null && book.details['format'] != '')
                          _buildDetailRow('Format', book.details['format']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Summary
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
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tags
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
                        return Chip(
                          label: Text(tag.toString()),
                          backgroundColor: Colors.purple.shade100,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}