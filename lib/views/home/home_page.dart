import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi video YouTube: 10 List Buku Terbaik 2026
    _ytController = YoutubePlayerController(
      initialVideoId: 'WRQbaNK1irI',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom Elegant App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF8FAFF),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  const Text(
                    "Rak Kita",
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.blueAccent, size: 20),
                    ),
                  )
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    "Halo, ${authProvider.user?.username ?? 'Pembaca'}! 👋",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const Text(
                    "Mau baca apa hari ini?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // YouTube Recommendation Card (Featured)
                  _buildSectionHeader("Rekomendasi Video", "Lihat Semua"),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: YoutubePlayer(
                        controller: _ytController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.blueAccent,
                        bottomActions: [
                          CurrentPosition(),
                          ProgressBar(isExpanded: true),
                          FullScreenButton(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "10 List Buku Terbaik 2026 (5 Industri)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const Text(
                    "Tips mindset, soft skills, dan produktivitas dari Fardi Yandi.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  
                  const SizedBox(height: 35),

                  // Category Selector
                  _buildSectionHeader("Kategori Populer", null),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildCategoryChip("📚 Semua", true),
                        _buildCategoryChip("🧠 Mindset", false),
                        _buildCategoryChip("💼 Bisnis", false),
                        _buildCategoryChip("🎨 Kreatif", false),
                        _buildCategoryChip("⏳ Produktif", false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Promotion / Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mulai Petualanganmu",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Jelajahi ribuan koleksi buku digital terbaik kami.",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {}, // Nanti bisa arahkan ke tab Jelajahi
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: const Text("Jelajahi", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        if (action != null)
          Text(action, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isSelected 
          ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
          : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}