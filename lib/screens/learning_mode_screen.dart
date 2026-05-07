import 'package:flutter/material.dart';
import 'main_layout.dart';

class LearningModeScreen extends StatefulWidget {
  const LearningModeScreen({Key? key}) : super(key: key);

  @override
  State<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends State<LearningModeScreen> {
  String? _selectedMode = 'Gamified Learning';

  Widget _buildModePill(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Progress (Orange, Orange, empty)
              Row(
                children: [
                   Expanded(child: Container(height: 4, color: const Color(0xFFFFC857))),
                   const SizedBox(width: 8),
                   Expanded(child: Container(height: 4, color: const Color(0xFFFFC857))),
                   const SizedBox(width: 8),
                   Expanded(child: Container(height: 4, color: const Color(0xFFCBD5E1))),
                ],
              ),
              const SizedBox(height: 40),

              const Text(
                'Choose your learning style',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B365D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick the mode that best fits your learning preference',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              // Gamified Mode
              _buildOptionCard(
                title: 'Gamified Learning',
                subtitle: 'Earn XP, maintain streaks, unlock achievements, and progress through levels',
                icon: Icons.sports_esports,
                pills: ['Daily streaks', 'XP & levels', 'Achievements', 'Leaderboards'],
                isSelected: _selectedMode == 'Gamified Learning',
                onTap: () => setState(() => _selectedMode = 'Gamified Learning'),
              ),
              const SizedBox(height: 16),

              // Basic Mode
              _buildOptionCard(
                title: 'Basic Learning',
                subtitle: 'Focus on learning without gamification elements',
                icon: Icons.menu_book,
                pills: ['Simple lessons', 'Progress tracking', 'No pressure', 'Learn at your pace'],
                isSelected: _selectedMode == 'Basic Learning',
                onTap: () => setState(() => _selectedMode = 'Basic Learning'),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: _selectedMode != null
                    ? () {
                        // Normally you would save this to Provider to affect UI state if needed
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MainLayout()),
                          (route) => false,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Learning', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> pills,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B365D) : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: isSelected ? const Color(0xFF1B365D) : const Color(0xFFEEF2FF),
                     borderRadius: BorderRadius.circular(10),
                   ),
                   child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF1B365D), size: 24),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         title,
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                           color: isSelected ? const Color(0xFF1B365D) : const Color(0xFF334155),
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         subtitle,
                         style: TextStyle(
                           fontSize: 13,
                           color: isSelected ? const Color(0xFF1e40af) : const Color(0xFF64748B),
                         ),
                       ),
                     ],
                   ),
                 ),
                 if (isSelected)
                   const Padding(
                     padding: EdgeInsets.only(left: 8.0),
                     child: Icon(Icons.check_circle, color: Color(0xFF1B365D)),
                   ),
               ],
             ),
             const SizedBox(height: 16),
             Wrap(
               children: pills.map((p) => _buildModePill(p)).toList(),
             ),
          ],
        ),
      ),
    );
  }
}
