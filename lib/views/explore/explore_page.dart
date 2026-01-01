import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/bukuacak_service.dart';
import '../detail/book_detail.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();
  List<Book> _books = [];
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchBooks();
      }
    });
  }

  Future<void> _fetchBooks() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final newBooks = await BukuAcakService.getBooks(page: _currentPage);
      setState(() {
        _books.addAll(newBooks);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Jelajahi Buku", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: _books.length + (_isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _books.length) return _buildLoadingCard();
          final book = _books[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(book: book))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(book.coverImage, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 8),
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(book.author, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)));
}