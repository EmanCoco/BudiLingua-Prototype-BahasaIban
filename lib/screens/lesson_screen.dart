import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../models/lesson_model.dart';
import 'chat_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({Key? key}) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  List<String> _selectedWords = [];

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final currentQ = lessonProvider.currentQuestion;

    if (currentQ == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Off-white
        appBar: AppBar(backgroundColor: const Color(0xFF1B365D)),
        body: const Center(child: Text("Loading or No Questions Available.")),
      );
    }

    final remainingWords = List<String>.from(currentQ.allIbanWords)
      ..removeWhere((word) => _selectedWords.contains(word));

    // Progress
    double progress = 0.0;
    if (lessonProvider.questions.isNotEmpty) {
       progress = (lessonProvider.currentQuestionIndex + 1) / lessonProvider.questions.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFF1B365D),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                     children: [
                       const Icon(Icons.star, color: Color(0xFFFFC857)),
                       const SizedBox(width: 4),
                       Text("${lessonProvider.xp}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                     ],
                  )
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question text
                    Text(
                      currentQ.promptText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1B365D),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Translate Context (Replaces the big dark blue box)
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEEF2FF), width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Text(
                        currentQ.promptIban,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF1B365D),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Sentence Building Area 
                    Container(
                      constraints: const BoxConstraints(minHeight: 100),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1B365D), width: 2, style: BorderStyle.none),
                      ),
                      child: _selectedWords.isEmpty 
                       ? const Center(child: Text("Tap words below to build the sentence", style: TextStyle(color: Color(0xFF64748B))))
                       : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: _selectedWords.map((word) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedWords.remove(word);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B365D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(word, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )).toList(),
                         ),
                    ),
                    const SizedBox(height: 40),

                    // Word Bank
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.center,
                      children: remainingWords.map((word) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWords.add(word);
                          });
                        },
                        child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: const Color(0xFF1B365D), width: 2),
                           ),
                           child: Text(word, style: const TextStyle(fontSize: 18, color: Color(0xFF1B365D), fontWeight: FontWeight.bold)),
                        ),
                      )).toList(),
                    ),

                    if (lessonProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
            
            // Interaction Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                   GestureDetector(
                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
                     child: Container(
                         width: 55, height: 55,
                         decoration: BoxDecoration(
                           color: const Color(0xFFEEF2FF),
                           borderRadius: BorderRadius.circular(16)
                         ),
                         child: const Icon(Icons.chat_bubble, color: Color(0xFF1B365D)),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedWords.isNotEmpty ? const Color(0xFF10B981) : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _selectedWords.isNotEmpty ? () => _checkAnswer(context, lessonProvider, currentQ) : null,
                        child: const Text('Check', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                   )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _checkAnswer(BuildContext context, LessonProvider provider, QuestionModel q) async {
    bool isCorrect = await provider.checkSequence(_selectedWords, q.correctIbanList);
    if (!context.mounted) return;
    _showSlidingModal(context, isCorrect, provider);
  }

  void _showSlidingModal(BuildContext context, bool isCorrect, LessonProvider provider) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                   Icon(
                    isCorrect ? Icons.check_circle : Icons.error,
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isCorrect ? "Awesome!" : "Not quite:",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 10),
                Text(
                  provider.currentQuestion?.correctIbanList.join(' ') ?? '', 
                  style: const TextStyle(fontSize: 18, color: Color(0xFF7F1D1D), fontWeight: FontWeight.w600),
                ),
                if (provider.aiFeedback != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("LinguaBuddy says: ${provider.aiFeedback}", style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFF1B365D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context); // close modal
                  if (provider.currentQuestionIndex < provider.questions.length - 1) {
                    setState(() {
                      _selectedWords.clear();
                    });
                    provider.nextQuestion();
                  } else {
                    // Completed all questions in the lesson
                    if (provider.currentLessonId != null) {
                      provider.completeLesson(provider.currentLessonId!);
                    }
                    Navigator.pop(context); // go back to path
                  }
                },
                child: const Text('CONTINUE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
