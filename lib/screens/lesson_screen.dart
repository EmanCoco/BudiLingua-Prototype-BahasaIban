import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../models/lesson_model.dart';
import 'chat_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({Key? key}) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  List<String> _selectedWords = [];
  String? _selectedLeft;
  String? _selectedRight;
  Set<String> _matchedPairs = {};
  List<String>? _shuffledLeft;
  List<String>? _shuffledRight;
  String? _lastMatchingQuestionId;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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

    if (currentQ.type == 'matching') {
      if (_lastMatchingQuestionId != currentQ.id) {
        _lastMatchingQuestionId = currentQ.id;
        _shuffledLeft = currentQ.matchingPairs!.keys.toList()..shuffle();
        _shuffledRight = currentQ.matchingPairs!.values.toList()..shuffle();
        _matchedPairs.clear();
        _selectedLeft = null;
        _selectedRight = null;
      }
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

                    if (currentQ.grammarTip != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: Color(0xFF0284C7), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentQ.grammarTip!,
                                style: const TextStyle(color: Color(0xFF0369A1), fontSize: 16, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (currentQ.type == 'recognize_word') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF49C0F8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.volume_up, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            currentQ.promptIban,
                            style: const TextStyle(
                              color: Color(0xFF9C27B0),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: (currentQ.options ?? []).map((option) {
                          bool isSelected = _selectedWords.isNotEmpty && _selectedWords.first == option['text'];
                          return GestureDetector(
                            onTap: () {
                              _audioPlayer.play(AssetSource('audio/click.mp3'));
                              setState(() {
                                _selectedWords = [option['text']!];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 3 : 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.asset(option['image']!, fit: BoxFit.contain),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      option['text']!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1B365D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else if (currentQ.type == 'matching') ...[
                      const Text("Tap the matching pairs", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: _shuffledLeft!.map((leftWord) {
                                bool isMatched = _matchedPairs.contains(leftWord);
                                bool isSelected = _selectedLeft == leftWord;
                                return _buildMatchingCard(
                                  text: leftWord,
                                  isMatched: isMatched,
                                  isSelected: isSelected,
                                  onTap: isMatched ? null : () => _onLeftWordTap(leftWord, currentQ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: _shuffledRight!.map((rightWord) {
                                String originalLeft = currentQ.matchingPairs!.entries.firstWhere((e) => e.value == rightWord).key;
                                bool isMatched = _matchedPairs.contains(originalLeft);
                                bool isSelected = _selectedRight == rightWord;
                                return _buildMatchingCard(
                                  text: rightWord,
                                  isMatched: isMatched,
                                  isSelected: isSelected,
                                  onTap: isMatched ? null : () => _onRightWordTap(rightWord, currentQ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
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
                                _audioPlayer.play(AssetSource('audio/click.mp3'));
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
                            _audioPlayer.play(AssetSource('audio/click.mp3'));
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
                    ],

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
                        onPressed: _isCheckEnabled(currentQ) ? () => _checkAnswer(context, lessonProvider, currentQ) : null,
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

  bool _isCheckEnabled(QuestionModel q) {
    if (q.type == 'matching') {
      return _matchedPairs.length == (q.matchingPairs?.length ?? 0);
    }
    return _selectedWords.isNotEmpty;
  }

  void _checkAnswer(BuildContext context, LessonProvider provider, QuestionModel q) async {
    bool isCorrect = true;
    if (q.type != 'matching') {
      isCorrect = await provider.checkSequence(_selectedWords, q.correctIbanList);
    }
    if (!context.mounted) return;
    
    if (isCorrect) {
      _audioPlayer.play(AssetSource('audio/correct.mp3'));
    } else {
      _audioPlayer.play(AssetSource('audio/incorrect.mp3'));
    }
    
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
                if (provider.currentQuestion?.type == 'recognize_word' && _selectedWords.isNotEmpty) ...[
                  Builder(builder: (ctx) {
                    final selectedText = _selectedWords.first;
                    final options = provider.currentQuestion?.options ?? [];
                    final option = options.firstWhere((o) => o['text'] == selectedText, orElse: () => {});
                    final explanation = option['explanation'];
                    if (explanation != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          explanation,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF991B1B), fontStyle: FontStyle.italic),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
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
                      _selectedLeft = null;
                      _selectedRight = null;
                      _matchedPairs.clear();
                      _shuffledLeft = null;
                      _shuffledRight = null;
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

  Widget _buildMatchingCard({required String text, required bool isMatched, required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isMatched 
            ? const Color(0xFFF1F5F9)
            : (isSelected ? const Color(0xFFEEF2FF) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMatched
              ? Colors.transparent
              : (isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0)),
            width: isSelected ? 3 : 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isMatched 
              ? const Color(0xFFCBD5E1)
              : (isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1B365D)),
          ),
        ),
      ),
    );
  }

  void _onLeftWordTap(String word, QuestionModel q) {
    setState(() {
      _selectedLeft = word;
    });
    _checkMatchingPair(q);
  }

  void _onRightWordTap(String word, QuestionModel q) {
    setState(() {
      _selectedRight = word;
    });
    _checkMatchingPair(q);
  }

  void _checkMatchingPair(QuestionModel q) {
    if (_selectedLeft != null && _selectedRight != null) {
      if (q.matchingPairs![_selectedLeft!] == _selectedRight) {
        _audioPlayer.play(AssetSource('audio/correct.mp3'));
        setState(() {
          _matchedPairs.add(_selectedLeft!);
          _selectedLeft = null;
          _selectedRight = null;
        });
      } else {
        _audioPlayer.play(AssetSource('audio/incorrect.mp3'));
        setState(() {
          _selectedLeft = null;
          _selectedRight = null;
        });
      }
    }
  }
}

