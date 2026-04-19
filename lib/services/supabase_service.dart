import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/lesson_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      print("SignIn Error: $e");
      rethrow;
    }
  }

  Future<AuthResponse?> signUp(String email, String password, {String? username}) async {
    try {
       final res = await _supabase.auth.signUp(email: email, password: password);
       
       // Explicitly provision a new default profile natively after user assigns account
       if (res.user != null) {
          try {
             String finalName = (username != null && username.trim().isNotEmpty) 
                 ? username.trim() 
                 : "Explorer${math.Random().nextInt(9000) + 1000}";
                 
              await _supabase.from('profiles').upsert({
                'id': res.user!.id,
                'username': finalName, 
                'xp': 0,
                'streak': 0,
                'hearts': 5,
                'completed_lessons': [],
                'unlocked_achievements': [],
                'avatar_url': null,
                'last_login': DateTime.now().toIso8601String(),
             });
          } catch(e) {
             print("Database Provision Warning: $e");
          }
       }
       
       return res;
    } catch (e) {
      print("SignUp Error: $e");
      rethrow; 
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}

class DatabaseService {
  final _supabase = Supabase.instance.client;

  Future<List<LanguageModel>> fetchLanguages() async {
    return [
      LanguageModel(id: 'iban', name: 'Iban', iconStr: 'eco', cultureDescription: 'Native phraseology covering the Gawai festival and river life.'),
      LanguageModel(id: 'murut', name: 'Murut', iconStr: 'water', cultureDescription: 'Mountain life and historic warrior phrases.'),
      LanguageModel(id: 'bidayuh', name: 'Bidayuh', iconStr: 'landscape', cultureDescription: 'Learn phrases of the Land Dayaks.'),
    ];
  }

  Future<List<LessonModel>> fetchLessons(String langId) async {
    return [
      LessonModel(id: 'l1', title: 'Greetings', difficulty: 'Beginner'),
      LessonModel(id: 'l2', title: 'Gawai Prep', difficulty: 'Easy'),
      LessonModel(id: 'l3', title: 'River Life', difficulty: 'Medium'),
      LessonModel(id: 'l4', title: 'Folklore', difficulty: 'Hard'),
      LessonModel(id: 'l5', title: 'Ceremonies', difficulty: 'Expert'),
    ];
  }

  Future<List<QuestionModel>> fetchQuestions(String lessonId) async {
    return [
      QuestionModel(
        id: 'q1',
        type: 'translate',
        promptText: 'Translate this sentence',
        promptIban: 'Selamat Hari Gawai!',
        correctIbanList: ['Happy', 'Gawai', 'Festival'],
        allIbanWords: ['Happy', 'Gawai', 'River', 'Festival', 'Rice', 'Harvest', 'Dance'],
        characterAsset: 'assets/images/logo.jpg', 
      ),
       QuestionModel(
        id: 'q2',
        type: 'translate',
        promptText: 'Select the missing word',
        promptIban: 'Manah _ nuan',
        correctIbanList: ['tuju'],
        allIbanWords: ['tuju', 'jalan', 'tuai', 'rumah'],
        characterAsset: null, 
      )
    ];
  }

  // --- NEW LIVE PRODUCTION DATABASE ENDPOINTS ---

  Future<UserProgress?> getUserProgress(String uid) async {
    try {
       final response = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
       
       if (response == null) {
         debugPrint("No profile found for UID: $uid. A new one will be created upon first save.");
         return null;
       }

       int streak = response['streak'] ?? 0;
       DateTime? lastLogin;
       
       try {
           if (response.containsKey('last_login') && response['last_login'] != null) {
              lastLogin = DateTime.parse(response['last_login']);
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final lastDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
              final diff = today.difference(lastDate).inDays;

              if (diff == 1) {
                 streak += 1;
                 await _supabase.from('profiles').update({'streak': streak, 'last_login': now.toIso8601String()}).eq('id', uid);
              } else if (diff > 1) {
                 streak = 1;
                 await _supabase.from('profiles').update({'streak': streak, 'last_login': now.toIso8601String()}).eq('id', uid);
              }
           } else {
              streak = 1;
              await _supabase.from('profiles').update({'streak': streak, 'last_login': DateTime.now().toIso8601String()}).eq('id', uid);
           }
       } catch (e) {
           debugPrint("Warning updating streak/last_login: $e");
       }

       // Handle completed_lessons (could be List or String depending on Supabase column type)
       List<String> parsedLessons = [];
       final lessonsData = response['completed_lessons'];
       if (lessonsData is List) {
         parsedLessons = List<String>.from(lessonsData);
       } else if (lessonsData is String && lessonsData.isNotEmpty) {
         parsedLessons = lessonsData.split(',').map((e) => e.trim()).toList();
       }

       // Handle unlocked_achievements
       List<String> parsedAchievements = [];
       final achievementsData = response['unlocked_achievements'];
       if (achievementsData is List) {
         parsedAchievements = List<String>.from(achievementsData);
       } else if (achievementsData is String && achievementsData.isNotEmpty) {
         parsedAchievements = achievementsData.split(',').map((e) => e.trim()).toList();
       }

       return UserProgress(
          username: response['username'] ?? "Explorer",
          avatarUrl: response['avatar_url'],
          xp: response['xp'] ?? 0,
          streak: streak,
          hearts: response['hearts'] ?? 5,
          completedLessons: parsedLessons,
          unlockedAchievements: parsedAchievements,
          lastLogin: lastLogin,
       );
    } catch (e) {
       debugPrint("Failed fetching profile: $e");
       return null;
    }
  }

  Future<void> updateUserProgress(String uid, UserProgress progress) async {
    try {
       // Since we upgraded the columns to text[], we save lists directly
       await _supabase.from('profiles').upsert({
         'id': uid,
         'xp': progress.xp,
         'streak': progress.streak,
         'hearts': progress.hearts,
         'completed_lessons': progress.completedLessons, 
         'unlocked_achievements': progress.unlockedAchievements ?? [],
         'username': progress.username,
         'avatar_url': progress.avatarUrl,
         'last_login': DateTime.now().toIso8601String(),
       });
       debugPrint("Profile successfully persisted to Supabase.");
    } catch (e) {
       debugPrint("Failed updating profile: $e");
    }
  }
}
