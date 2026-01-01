import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../services/bukuacak_service.dart';
import '../detail/book_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      // Pastikan di BukuAcakService sudah diubah ke ?title=$query
      final results = await BukuAcakService.searchBooks(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Soft clean blue-white
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Explore Books',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Search Input Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Find your next favorite book...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueAccent),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),

          // Search Results
          SliverFillRemaining(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_rounded, size: 80, color: Colors.blue.shade100),
            const SizedBox(height: 16),
            const Text(
              'Looking for something special?',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/6134/6134065.png',
              width: 150,
              opacity: const AlwaysStoppedAnimation(0.5),
            ),
            const SizedBox(height: 16),
            const Text('Oops! Book not found', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index];
        return _buildModernBookCard(book);
      },
    );
  }

  Widget _buildModernBookCard(Book book) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isBookmarked = bookmarkProvider.isBookmarked(book.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(book: book))),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Book Image with Shadow
                Hero(
                  tag: 'book-${book.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        book.coverImage,
                        width: 90,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 130,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
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
                        book.category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.blueAccent.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('FREE', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (isBookmarked) {
                                final b = bookmarkProvider.getBookmarkByBookId(book.id);
                                if (b != null) await bookmarkProvider.deleteBookmark(b);
                              } else {
                                await bookmarkProvider.addBookmark(authProvider.user!.id, book);
                              }
                            },
                            icon: Icon(
                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                              color: isBookmarked ? Colors.blueAccent : Colors.grey,
                            ),
                          ),
                        ],
                      )
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
}