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
  int _selectedIndex = 0;

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
      if (mounted) {
        setState(() {
          _books = books;
        });
      }
    });
  }

  void _loadMoreBooks() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      _currentPage++;
      BukuAcakService.getBooks(page: _currentPage).then((newBooks) {
        if (mounted) {
          setState(() {
            _books.addAll(newBooks);
            _isLoadingMore = false;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
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
        title: const Text('Rak Kita', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: () async => _refreshBooks(),
          child: FutureBuilder<List<Book>>(
            future: _futureBooks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _books.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError && _books.isEmpty) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (_books.isEmpty) {
                return const Center(child: Text('No books found'));
              } else {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _books.length) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                    }
                    final book = _books[index];
                    final isBookmarked = bookmarkProvider.isBookmarked(book.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailPage(book: book))),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // --- BAGIAN PERBAIKAN GAMBAR ---
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.coverImage,
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  // Menangani jika gambar gagal load (Error 404 dll)
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 120,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.book, color: Colors.grey, size: 40),
                                    );
                                  },
                                ),
                              ),
                              // ------------------------------
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(book.author, style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 8),
                                    Text(book.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? Colors.blue : null),
                                onPressed: () async {
                                  if (isBookmarked) {
                                    final b = bookmarkProvider.getBookmarkByBookId(book.id);
                                    if (b != null) await bookmarkProvider.deleteBookmark(b);
                                  } else {
                                    await bookmarkProvider.addBookmark(authProvider.user!.id, book);
                                  }
                                },
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        elevation: 10,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarkPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
          } else if (index == 3) {
            authProvider.logout();
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Simpan'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Keluar'),
        ],
      ),
    );
  }
}