import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import '../auth/login_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // AVATAR
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple.shade300],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: user?.profilePicture != null
                      ? NetworkImage(
                          "http://10.0.2.2/buku_app/uploads/${user!.profilePicture}",
                        )
                      : null,
                  child: user?.profilePicture == null
                      ? Text(
                          user?.username.substring(0, 1).toUpperCase() ?? "U",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
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

            // EDIT PROFILE
            _menuTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfilePage(),
                  ),
                );

                /// 🔥 PAKSA REFRESH UI
                if (result == true) {
                  context.read<AuthProvider>().checkAuthStatus();
                }
              },
            ),

            _menuTile(icon: Icons.settings_outlined, title: "Settings"),
            _menuTile(icon: Icons.help_outline, title: "Help Center"),

            const Divider(indent: 20, endIndent: 20),

            _menuTile(
  icon: Icons.logout_rounded,
  title: "Logout",
  color: Colors.red,
  onTap: () async {
    final auth = context.read<AuthProvider>();

    await auth.logout();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  },
),

          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
    );
  }
}
