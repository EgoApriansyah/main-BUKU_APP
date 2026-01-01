import 'package:buku_app/views/explore/explore_page.dart';
import 'package:flutter/material.dart';
import 'home/home_page.dart'; // Sesuaikan path-nya
import 'search/search_page.dart'; // Sesuaikan path-nya
import 'bookmark/bookmark_page.dart'; // Sesuaikan path-nya
import 'profile/profile_page.dart'; // Sesuaikan path-nya

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ExplorePage(),
    const BookmarkPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga keadaan (state) halaman agar tidak reset saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded), 
              label: 'Jelajahi'
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_rounded),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}