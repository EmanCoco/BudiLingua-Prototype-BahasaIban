import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "DONE",
              style: TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Section
            _buildSectionTitle("Account"),
            _buildSettingsGroup([
              "Preferences",
              "Profile",
              "Notifications",
              "Courses",
              "BudiLingua for Schools", // Custom brand name
              "Social accounts",
              "Privacy settings",
            ]),

            const SizedBox(height: 32),

            // Subscription Section
            _buildSectionTitle("Subscription"),
            _buildSettingsGroup(["Choose a plan"]),

            const SizedBox(height: 32),

            // Support Section
            _buildSectionTitle("Support"),
            _buildSettingsGroup([
              "Help Center",
              "Feedback"
            ]),

            const SizedBox(height: 48),

            // Sign out button
            ElevatedButton(
              onPressed: () async {
                 await AuthService().signOut();
                 if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                 }
              },
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 foregroundColor: const Color(0xFFFF4B4B), // Red out sign out text
                 padding: const EdgeInsets.symmetric(vertical: 20),
                 side: const BorderSide(color: Color(0xFFCBD5E1), width: 2), // Slate 300
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 elevation: 0,
              ),
              child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
            ),

            const SizedBox(height: 32),
            
            // Footer Links
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("TERMS", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 16),
                  Text("PRIVACY POLICY", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 16),
                  Text("ACKNOWLEDGEMENTS", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 32),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1B365D), // Navy Blue
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int idx = entry.key;
          String item = entry.value;
          bool isLast = idx == items.length - 1;

          return Column(
            children: [
              ListTile(
                title: Text(item, style: const TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                onTap: () {},
              ),
              if (!isLast)
                const Divider(height: 1, color: Color(0xFFCBD5E1), indent: 0, endIndent: 0),
            ],
          );
        }).toList(),
      ),
    );
  }
}
