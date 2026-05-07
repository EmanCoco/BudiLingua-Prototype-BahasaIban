import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final allAchievements = lessonProvider.allAchievements;
    final unlockedIds = lessonProvider.unlockedAchievementsList;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Cream
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: const Color(0xFF1B365D),
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: const [BoxShadow(color: Color(0xFF0F1E36), offset: Offset(0, 4))],
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.emoji_events, color: Color(0xFFFFC857), size: 48),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text("Great Progress!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 4),
                           Text(
                             "You've unlocked ${unlockedIds.length} out of ${allAchievements.length} achievements", 
                             style: const TextStyle(color: Colors.white70, fontSize: 14),
                           ),
                         ],
                       ),
                     )
                   ],
                 ),
               ),
               const SizedBox(height: 32),
               const Text("All Achievements", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(height: 16),
               Expanded(
                 child: ListView.separated(
                   itemCount: allAchievements.length,
                   separatorBuilder: (_, __) => const SizedBox(height: 12),
                   itemBuilder: (context, index) {
                     final ach = allAchievements[index];
                     final isUnlocked = unlockedIds.contains(ach.id);

                     return Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                       ),
                       child: Row(
                         children: [
                           Container(
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: isUnlocked ? Color(ach.colorVal) : const Color(0xFFF1F5F9),
                               shape: BoxShape.circle,
                             ),
                             child: Icon(
                               _getIconData(ach.iconStr),
                               color: isUnlocked ? Colors.white : const Color(0xFF94A3B8),
                               size: 28,
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   ach.title,
                                   style: TextStyle(
                                     fontSize: 16,
                                     fontWeight: FontWeight.bold,
                                     color: isUnlocked ? const Color(0xFF1B365D) : const Color(0xFF64748B),
                                   ),
                                 ),
                                 const SizedBox(height: 4),
                                 Text(
                                   ach.description,
                                   style: TextStyle(
                                     fontSize: 14,
                                     color: isUnlocked ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           if (isUnlocked)
                             const Icon(Icons.check_circle, color: Color(0xFF10B981))
                           else
                             const Icon(Icons.lock, color: Color(0xFFCBD5E1))
                         ],
                       ),
                     );
                   },
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String str) {
    switch (str) {
      case 'local_fire_department': return Icons.local_fire_department;
      case 'calendar_month': return Icons.calendar_month;
      case 'bolt': return Icons.bolt;
      case 'school': return Icons.school;
      default: return Icons.star;
    }
  }
}
