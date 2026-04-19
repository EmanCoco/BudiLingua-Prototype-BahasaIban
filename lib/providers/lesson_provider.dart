import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson_model.dart';
import '../services/supabase_service.dart';
import '../services/openai_service.dart';

class LessonProvider with ChangeNotifier {
  int _xp = 0;
  int _hearts = 5;
  int _streak = 0;
  List<String> _completedLessons = [];
  List<String> _unlockedAchievements = [];
  
  String _username = "Explorer";
  String? _avatarUrl;
  bool _isLoading = false;
  String? _aiFeedback;

  final DatabaseService _dbService = DatabaseService();
  final IbanAIService _aiService = IbanAIService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<LanguageModel> _languages = [];
  List<LessonModel> _lessons = [];
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;

  List<LanguageModel> get languages => _languages;
  List<LessonModel> get lessons => _lessons;
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  String get username => _username;
  String? get avatarUrl => _avatarUrl;
  int get xp => _xp;
  int get hearts => _hearts;
  int get streak => _streak;
  List<String> get completedLessons => _completedLessons;
  bool get isLoading => _isLoading;
  String? get aiFeedback => _aiFeedback;
  List<String> get unlockedAchievementsList => _unlockedAchievements;

  final List<Achievement> allAchievements = [
    Achievement(id: 'streak_3', title: 'On a Roll', description: 'Maintain a 3-day streak', iconStr: 'local_fire_department', colorVal: 0xFFFF9800),
    Achievement(id: 'streak_7', title: 'Week Warrior', description: 'Maintain a 7-day streak', iconStr: 'calendar_month', colorVal: 0xFFFFC857),
    Achievement(id: 'xp_100', title: 'Getting Started', description: 'Earn 100 XP', iconStr: 'bolt', colorVal: 0xFF49C0F8),
    Achievement(id: 'lesson_1', title: 'First Steps', description: 'Finish 1 lesson', iconStr: 'school', colorVal: 0xFF58CC02),
  ];

  LessonProvider() {
    _fetchUserProgress();
    _fetchLanguages();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        _fetchUserProgress();
      }
    });
  }

  Future<void> _fetchLanguages() async {
    _isLoading = true;
    notifyListeners();
    _languages = await _dbService.fetchLanguages();
    if (_languages.isNotEmpty) {
      _lessons = await _dbService.fetchLessons(_languages.first.id);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLessonsForLanguage(String langId) async {
    _isLoading = true;
    notifyListeners();
    _lessons = await _dbService.fetchLessons(langId);
    _isLoading = false;
    notifyListeners();
  }

  String? _currentLessonId;
  String? get currentLessonId => _currentLessonId;

  Future<void> fetchQuestionsForLesson(String lessonId) async {
    _isLoading = true;
    _currentLessonId = lessonId;
    _currentQuestionIndex = 0;
    notifyListeners();
    _questions = await _dbService.fetchQuestions(lessonId);
    _isLoading = false;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProgress() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    
    _isLoading = true;
    notifyListeners();

    UserProgress? progress = await _dbService.getUserProgress(uid);
    if (progress != null) {
      _username = progress.username;
      _avatarUrl = progress.avatarUrl;
      _xp = progress.xp;
      _hearts = progress.hearts;
      _streak = progress.streak;
      _completedLessons = progress.completedLessons;
      _unlockedAchievements = progress.unlockedAchievements ?? [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    if (!_completedLessons.contains(lessonId)) {
      _completedLessons.add(lessonId);
      _xp += 10;
      await _playCorrectSound();
      _checkAchievements();
      _saveProgress();
    }
    notifyListeners();
  }

  void _checkAchievements() {
    bool newlyUnlocked = false;
    
    if (_streak >= 3 && !_unlockedAchievements.contains('streak_3')) {
      _unlockedAchievements.add('streak_3');
      newlyUnlocked = true;
    }
    if (_streak >= 7 && !_unlockedAchievements.contains('streak_7')) {
      _unlockedAchievements.add('streak_7');
      newlyUnlocked = true;
    }
    if (_xp >= 100 && !_unlockedAchievements.contains('xp_100')) {
      _unlockedAchievements.add('xp_100');
      newlyUnlocked = true;
    }
    if (_completedLessons.isNotEmpty && !_unlockedAchievements.contains('lesson_1')) {
      _unlockedAchievements.add('lesson_1');
      newlyUnlocked = true;
    }

    if (newlyUnlocked) {
      // In a full app, we would show a toast or dialog indicating unlocking
    }
  }

  Future<bool> checkAnswer(String userAnswer, String correctAnswer) async {
    _aiFeedback = null;
    notifyListeners();

    if (userAnswer == correctAnswer) {
      return true; 
    } else {
      if (_hearts > 0) {
        _hearts -= 1;
      }
      
      _isLoading = true;
      notifyListeners();

      _aiFeedback = await _aiService.explainMistake(userAnswer, correctAnswer);
      
      _isLoading = false;
      _saveProgress();
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkSequence(List<String> userSequence, List<String> correctSequence) async {
    _aiFeedback = null;
    notifyListeners();

    final userStr = userSequence.join(' ').toLowerCase();
    final correctStr = correctSequence.join(' ').toLowerCase();

    if (userStr == correctStr) {
      return true; // we defer the XP gain to completeLesson when they finish all questions
    } else {
      if (_hearts > 0) {
        _hearts -= 1;
      }
      
      _isLoading = true;
      notifyListeners();

      _aiFeedback = await _aiService.explainMistake(userStr, correctStr);
      
      _isLoading = false;
      _saveProgress();
      notifyListeners();
      return false;
    }
  }

  Future<void> _playCorrectSound() async {
    try {
      print("Playing correct sound!");
      // await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print("Warning: Missing correct.mp3 audio asset. $e");
    }
  }

  Future<void> updateAvatarUrl(String newUrl) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    
    _avatarUrl = newUrl;
    notifyListeners();
    
    try {
      debugPrint('Syncing avatar URL to database: $newUrl');
      await Supabase.instance.client.from('profiles').upsert({
        'id': uid,
        'avatar_url': newUrl,
      });
      debugPrint('Database sync successful.');
    } catch (e) {
      debugPrint('Error updating avatar in database: $e');
    }
  }

  Future<void> updateUsername(String newName) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    
    _username = newName;
    notifyListeners();
    
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': uid,
        'username': newName,
      });
    } catch (e) {
      debugPrint('Error updating username: $e');
    }
  }

  void _saveProgress() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    UserProgress progress = UserProgress(
      username: _username,
      avatarUrl: _avatarUrl,
      xp: _xp,
      streak: _streak,
      hearts: _hearts,
      completedLessons: _completedLessons,
      unlockedAchievements: _unlockedAchievements,
    );
    _dbService.updateUserProgress(uid, progress);
  }
}
