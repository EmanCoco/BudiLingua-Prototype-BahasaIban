import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/lesson_provider.dart';
import 'lesson_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lessons = lessonProvider.lessons;
    final completed = lessonProvider.completedLessons;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Cream Background
      body: lessonProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Faint Background Decoration
                Positioned.fill(
                   child: Opacity(
                      opacity: 0.05,
                      child: GridView.builder(
                         physics: const NeverScrollableScrollPhysics(),
                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 40, crossAxisSpacing: 40),
                         itemCount: 20,
                         itemBuilder: (context, i) => Icon(i % 2 == 0 ? Icons.eco : Icons.water, size: 80, color: const Color(0xFF1B365D)),
                      ),
                   )
                ),
                // Main Content
                SafeArea(
                  child: SingleChildScrollView(
              child: Column(
                children: [
                  // BudiLingua Sticky Header Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B365D), // Navy Blue
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF0F1E36), offset: Offset(0, 4))
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("UNIT 1: BEGINNER", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 4),
                            Text("Greetings & Basics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Icon(Icons.book, color: Colors.white),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Snaking Nodes
                  ...List.generate(lessons.length, (index) {
                     final lesson = lessons[index];
                     final isCompleted = completed.contains(lesson.id);
                     final isUnlocked = isCompleted || (index == completed.length);
                     
                     // Snaking curve equation
                     final double snakeOffset = math.sin(index * 0.8) * 80;

                     return Column(
                       children: [
                           // Logo removed per request
                          _buildNode(context, isUnlocked, isCompleted, lesson.id, snakeOffset),
                          const SizedBox(height: 30),
                       ],
                     );
                  }),

                  // Treasure Chest at the bottom
                  Transform.translate(
                    offset: const Offset(0, 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Icon(Icons.inventory_2, size: 80, color: const Color(0xFF1B365D).withValues(alpha: 0.8)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(BuildContext context, bool isUnlocked, bool isCompleted, String lessonId, double offsetX) {
     bool isActive = isUnlocked && !isCompleted;

     return SizedBox(
       width: double.infinity,
       child: Transform.translate(
         offset: Offset(offsetX, 0),
         child: GestureDetector(
           onTap: () async {
              if (isUnlocked) {
                 // Capture the navigator before the async gap to ensure it always pushes
                 final nav = Navigator.of(context);
                 
                 // Show a small snackbar so the user knows the button was actually pressed
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text("Loading Stage $lessonId..."), 
                     duration: const Duration(seconds: 1)
                   )
                 );

                 await context.read<LessonProvider>().fetchQuestionsForLesson(lessonId);
                 
                 nav.push(MaterialPageRoute(builder: (context) => const LessonScreen()));
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text("You need to complete the previous stage first!"), 
                     duration: Duration(seconds: 2)
                   )
                 );
              }
           },
           child: isActive ? _buildActiveNode() : _buildInactiveNode(isCompleted),
         ),
       ),
     );
  }

  Widget _buildActiveNode() {
     return Container(
       width: 80, height: 80,
       decoration: BoxDecoration(
         color: const Color(0xFFFFC857), // Warm Gold
         shape: BoxShape.circle,
         boxShadow: const [
           BoxShadow(color: Color(0xFFD4A33B), offset: Offset(0, 6))
         ]
       ),
       child: const Center(
         child: Icon(Icons.star, color: Colors.white, size: 40),
       ),
     );
  }

  Widget _buildInactiveNode(bool isCompleted) {
     return Container(
       width: 80, height: 80,
       decoration: BoxDecoration(
         color: isCompleted ? const Color(0xFFFFC857) : const Color(0xFFCBD5E1), // Warm Gold if done, Slate 300 if locked
         shape: BoxShape.circle,
         boxShadow: [
           BoxShadow(
              color: isCompleted ? const Color(0xFFD4A33B) : const Color(0xFF94A3B8), // Matching shadow
              offset: const Offset(0, 6)
           )
         ]
       ),
       child: Center(
         child: isCompleted 
           ? const Icon(Icons.check, color: Colors.white, size: 40)
           : const Icon(Icons.lock, color: Colors.white, size: 36), // Lock icon instead of character
       ),
     );
  }
}
