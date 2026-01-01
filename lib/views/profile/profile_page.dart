import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Colors.blue, Colors.purple.shade300]),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.username.substring(0, 1).toUpperCase() ?? "U",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.username ?? "User Name",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "email@example.com",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            
            // Profile Menu Items
            _buildMenuTile(Icons.person_outline, "Edit Profile"),
            _buildMenuTile(Icons.settings_outlined, "Settings"),
            _buildMenuTile(Icons.help_outline, "Help Center"),
            const Divider(indent: 20, endIndent: 20),
            _buildMenuTile(
              Icons.logout_rounded, 
              "Logout", 
              color: Colors.red, 
              onTap: () => authProvider.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.blueGrey),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
    );
  }
}