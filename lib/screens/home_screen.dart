import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import 'progress_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    
    // Dynamic Calculations
    int completedCount = lessonProvider.completedLessons.length;
    int totalLessons = lessonProvider.lessons.isNotEmpty ? lessonProvider.lessons.length : 5;
    double mainProgressVal = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;
    
    int goal = 5;
    int dailyProgress = completedCount % goal;
    double dailyVal = dailyProgress / goal;
    
    String nextLessonTitle = "Basic Greetings";
    if (completedCount < totalLessons && lessonProvider.lessons.isNotEmpty) {
       nextLessonTitle = lessonProvider.lessons[completedCount].title;
    } else if (completedCount >= totalLessons && totalLessons > 0) {
       nextLessonTitle = "Course Complete!";
    }
    double nextLessonProgress = (completedCount >= totalLessons) ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Cream
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic Header Bar
            _buildHeader(context, lessonProvider),
            
            // Body Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Learning Path section
                  const Text("Your Learning Path", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B365D))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Active Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if(lessonProvider.languages.isNotEmpty) {
                              context.read<LessonProvider>().fetchLessonsForLanguage(lessonProvider.languages.first.id);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressScreen()));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1B365D), Color(0xFF2d4a7c)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("🦅", style: TextStyle(fontSize: 28)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        children: [
                                          CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                                          SizedBox(width: 4),
                                            Text("Active", style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text("Bahasa Iban", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Text("Indigenous language", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: mainProgressVal,
                                          backgroundColor: Colors.white24,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text("${(mainProgressVal * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 12))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Inactive column
                      const Expanded(
                        child: Column(
                          children: [
                            _MockLockedLangCard(emoji: '🌿', title: 'Bahasa Bidayuh', subtitle: 'Coming Soon'),
                            SizedBox(height: 12),
                            _MockLockedLangCard(emoji: '🏝️', title: 'Bahasa Melanau', subtitle: 'Coming Soon'),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Daily Goal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Goal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B365D))),
                      Text("$dailyProgress/$goal lessons", style: const TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1) , blurStyle: BlurStyle.inner)],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: dailyVal > 0 ? dailyVal : 0.01,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFFFFC857)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(completedCount >= totalLessons ? "All lessons finished!" : "${goal - dailyProgress} more lessons to reach your goal!", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 32),

                  // Continue Learning Button
                  const Text("Continue Learning", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B365D))),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                           if(lessonProvider.languages.isNotEmpty) {
                              context.read<LessonProvider>().fetchLessonsForLanguage(lessonProvider.languages.first.id);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressScreen()));
                            }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(16)
                                ),
                                child: const Center(child: Text("🎯", style: TextStyle(fontSize: 28))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nextLessonTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B365D))),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: nextLessonProgress,
                                              backgroundColor: const Color(0xFFF4F6F8),
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("${(nextLessonProgress * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.chevron_right, color: Color(0xFF1B365D), size: 30)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LessonProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1B365D),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 65, height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 4),
                    ),
                    child: ClipOval(
                      child: provider.avatarUrl != null
                          ? Image.network(
                              provider.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 65,
                              height: 65,
                              errorBuilder: (c, e, s) => const Icon(Icons.person, color: Color(0xFF1B365D), size: 35),
                            )
                          : const Icon(Icons.person, color: Color(0xFF1B365D), size: 35),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1B365D), width: 2),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 16),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Row(
                      children: [
                        Flexible(
                          child: Text(provider.username, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70, size: 16),
                          onPressed: () {
                             // Show Edit Dialog
                             final controller = TextEditingController(text: provider.username);
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
                  ],
                ),
              ),
              // Chatbot & Row end
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Dynamic Streak Pill
                  Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     decoration: BoxDecoration(
                       color: provider.streak > 0 
                           ? const Color(0xFFFFC857).withValues(alpha: 0.2)
                           : Colors.white.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(20)
                     ),
                     child: Row(
                       children: [
                         Icon(
                           Icons.local_fire_department, 
                           color: provider.streak > 0 ? const Color(0xFFFFC857) : Colors.white60, 
                           size: 24
                         ),
                         const SizedBox(width: 8),
                         Column(
                           children: [
                             Text("${provider.streak}", style: TextStyle(color: provider.streak > 0 ? const Color(0xFFFFC857) : Colors.white60, fontSize: 20, fontWeight: FontWeight.bold, height: 1.0)),
                             Text("days", style: TextStyle(color: provider.streak > 0 ? Colors.white70 : Colors.white38, fontSize: 10)),
                           ],
                         )
                       ],
                     ),
                  ),
                  const SizedBox(width: 12),
                  // AI Chat Bot
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(Icons.emoji_events, "XP", "${provider.xp}", const Color(0xFFFFC857)),
              _buildStatCard(Icons.my_library_books, "Lessons", "24", const Color(0xFF10B981)),
              _buildStatCard(Icons.star, "Achievements", "${provider.unlockedAchievementsList.length}", const Color(0xFFEEF2FF)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color iconColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
           color: Colors.white.withValues(alpha: 0.1),
           borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MockLockedLangCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _MockLockedLangCard({Key? key, required this.emoji, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Align(alignment: Alignment.topRight, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)), child: const Text("Soon", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))))),
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B365D))),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
             ],
          ),
          Positioned.fill(
             child: Container(
               decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16)),
               child: const Center(child: CircleAvatar(backgroundColor: Colors.white, radius: 14, child: Text("🔒", style: TextStyle(fontSize: 14)))),
             ),
          )
        ],
      )
    );
  }
}
