import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/lesson_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null) return;

    // Trigger the Cropper
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.png, // PNG supports transparency for circular corners
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Profile Picture',
          toolbarColor: const Color(0xFF1B365D),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false, // Allow flexibility to adjust crop area
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: 'Adjust Profile Picture',
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception("Authentication required for profile update.");
      }

      final bytes = await croppedFile.readAsBytes();
      // Use consistent png extension for all avatars to support transparency
      final fileName = '${user.id}_avatar.png';

      // Upload with upsert: true to replace existing file
      await _supabase.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
      );

      // Get public URL with cache-busting timestamp
      final rawUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      final publicUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      if (mounted) {
        await context.read<LessonProvider>().updateAvatarUrl(publicUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint("Avatar Upload Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    
    // Dynamic Stat Calculations
    int totalXP = lessonProvider.xp;
    String league = "Bronze";
    Color leagueColor = const Color(0xFFCD7F32); // Bronze
    if (totalXP >= 500) {
      league = "Gold";
      leagueColor = const Color(0xFFFFD700);
    } else if (totalXP >= 200) {
      league = "Silver";
      leagueColor = const Color(0xFFC0C0C0);
    }
    
    int topFinishes = (lessonProvider.completedLessons.length / 5).floor();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Navy Blue Header Section
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                 decoration: const BoxDecoration(
                   color: Color(0xFF1B365D), // Navy blue header
                   borderRadius: BorderRadius.only(
                     bottomLeft: Radius.circular(32),
                     bottomRight: Radius.circular(32),
                   ),
                 ),
                 child: Column(
                    children: [
                       Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             IconButton(icon: const Icon(Icons.ios_share, color: Colors.white), onPressed: () {}),
                             IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                             }),
                          ],
                       ),
                       Center(
                         child: GestureDetector(
                           onTap: _pickImage,
                           child: Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: _isUploading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : ClipOval(
                                      child: lessonProvider.avatarUrl != null
                                          ? Image.network(
                                              lessonProvider.avatarUrl!, 
                                              fit: BoxFit.cover,
                                              width: 90, height: 90,
                                              errorBuilder: (c, e, s) => const Icon(Icons.person, size: 50, color: Color(0xFF1B365D)),
                                            )
                                          : const Icon(Icons.person, size: 50, color: Color(0xFF1B365D)),
                                    ),
                           ),
                         ),
                       ),
                       const SizedBox(height: 16),
                       Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(lessonProvider.username, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                             IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                                onPressed: () {
                                     final controller = TextEditingController(text: lessonProvider.username);
                                     showDialog(
                                       context: context,
                                       builder: (context) {
                                         return AlertDialog(
                                           title: const Text("Edit Username"),
                                           backgroundColor: Colors.white,
                                           content: TextField(
                                              controller: controller,
                                              autofocus: true,
                                              decoration: const InputDecoration(labelText: "New Username"),
                                           ),
                                           actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                              ElevatedButton(
                                                onPressed: () {
                                                   if (controller.text.trim().isNotEmpty) {
                                                      context.read<LessonProvider>().updateUsername(controller.text.trim());
                                                   }
                                                   Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                                child: const Text("Save"),
                                              )
                                           ],
                                         );
                                       }
                                     );
                                },
                             )
                          ],
                       ),
                       const SizedBox(height: 4),
                       Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text("@${lessonProvider.username.replaceAll(' ', '').toLowerCase()} • Joined 2025", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                       ),
                       const SizedBox(height: 32),
                       // Stats Display
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                             _buildHeaderStat("1", "Courses"),
                             Container(width: 1, height: 40, color: Colors.white24),
                             _buildHeaderStat("0", "Following"),
                             Container(width: 1, height: 40, color: Colors.white24),
                             _buildHeaderStat("0", "Followers"),
                          ],
                       )
                    ],
                 ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     // Add Friends
                     OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF1B365D)),
                        label: const Text("ADD FRIENDS", style: TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold, fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                           backgroundColor: Colors.white,
                        ),
                     ),
                     const SizedBox(height: 32),

                     // Statistics
                     const Text("STATISTICS", style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                     const SizedBox(height: 16),
                     GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                           _buildStatCard(Icons.local_fire_department, "${lessonProvider.streak}", "Day streak", const Color(0xFFFF9800)),
                           _buildStatCard(Icons.bolt, "${lessonProvider.xp}", "Total XP", const Color(0xFFFFC857)),
                           _buildStatCard(Icons.eco, league, "Current league", leagueColor),
                           _buildStatCard(Icons.school, "$topFinishes", "Top 3 finishes", const Color(0xFF49C0F8)),
                        ],
                     ),
                     const SizedBox(height: 32),
                     
                     // Achievements Showcase
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           const Text("ACHIEVEMENTS", style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                           TextButton(onPressed: () {}, child: const Text("VIEW ALL", style: TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold))),
                        ]
                     ),
                     const SizedBox(height: 12),
                     ...lessonProvider.allAchievements.take(3).map((ach) {
                         final isUnlocked = lessonProvider.unlockedAchievementsList.contains(ach.id);
                         return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                            ),
                            child: Row(
                               children: [
                                  Icon(Icons.star, color: isUnlocked ? Color(ach.colorVal) : const Color(0xFFCBD5E1), size: 32),
                                  const SizedBox(width: 16),
                                  Expanded(
                                     child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                           Text(ach.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B365D))),
                                           Text(ach.description, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                                        ]
                                     )
                                  ),
                               ]
                            )
                         );
                     }).toList(),
                     const SizedBox(height: 40),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
     return Column(
        children: [
           Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
           Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
     );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color iconColor) {
     return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
        ),
        child: Row(
           children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(value, style: const TextStyle(color: Color(0xFF1B365D), fontSize: 18, fontWeight: FontWeight.bold)),
                       Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]
                 )
              )
           ]
        ),
     );
  }
}
