import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../services/bukuacak_service.dart';
import '../detail/book_detail.dart';
import '../search/search_page.dart';
import '../bookmark/bookmark_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Book>> _futureBooks;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreBooks();
    }
  }

  void _loadBooks() {
    _futureBooks = BukuAcakService.getBooks(page: _currentPage);
    _futureBooks.then((books) {
      setState(() {
        _books = books;
      });
    });
  }

  void _loadMoreBooks() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      _currentPage++;
      BukuAcakService.getBooks(page: _currentPage).then((newBooks) {
        setState(() {
          _books.addAll(newBooks);
          _isLoadingMore = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
  }

  void _refreshBooks() {
    setState(() {
      _currentPage = 1;
      _books = [];
    });
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BookmarkPage(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authProvider.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshBooks();
          },
          child: FutureBuilder<List<Book>>(
            future: _futureBooks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _books.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      Text("Loading books..."),
                    ],
                  ),
                );
              } else if (snapshot.hasError && _books.isEmpty) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (_books.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No books found'),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _books.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final book = _books[index];
                    final isBookmarked = bookmarkProvider.isBookmarked(book.id);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
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
                                  book.coverImage,
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
                                      book.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Author: ${book.author}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Category: ${book.category}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      book.summary,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Bookmark button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                            color: isBookmarked ? Colors.blue : null,
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}