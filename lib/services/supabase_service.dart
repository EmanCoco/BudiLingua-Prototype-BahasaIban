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
      LessonModel(id: 'l1', title: 'Family Members', difficulty: 'Beginner'),
      LessonModel(id: 'l2', title: 'Daily Actions', difficulty: 'Easy'),
      LessonModel(id: 'l3', title: 'Basic Sentences', difficulty: 'Medium'),
      LessonModel(id: 'l4', title: 'Folklore', difficulty: 'Hard'),
      LessonModel(id: 'l5', title: 'Ceremonies', difficulty: 'Expert'),
    ];
  }

  Future<List<QuestionModel>> fetchQuestions(String lessonId) async {
    final Map<String, List<QuestionModel>> allQuestions = {

      // ── LESSON 1: Family Members ───────────────────────────────────────────────
      'l1': [
        QuestionModel(
          id: 'l1q1',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Apai / Apak',
          correctIbanList: ['Father'],
          allIbanWords: [],
          options: [
            {'text': 'Father', 'image': 'assets/images/quizcharacter/father.png', 'explanation': 'Father translates to Apai / Apak.'},
            {'text': 'Mother', 'image': 'assets/images/quizcharacter/mother.png', 'explanation': 'Mother translates to Indai.'},
            {'text': 'Son', 'image': 'assets/images/quizcharacter/son.png', 'explanation': 'Son translates to Anak Laki.'},
            {'text': 'Daughter', 'image': 'assets/images/quizcharacter/daughter.png', 'explanation': 'Daughter translates to Anak Induk.'},
          ],
        ),
        QuestionModel(
          id: 'l1q2',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Indai',
          correctIbanList: ['Mother'],
          allIbanWords: [],
          options: [
            {'text': 'Baby', 'image': 'assets/images/quizcharacter/baby.png', 'explanation': 'Baby translates to Anak Mit.'},
            {'text': 'Mother', 'image': 'assets/images/quizcharacter/mother.png', 'explanation': 'Mother translates to Indai.'},
            {'text': 'Father', 'image': 'assets/images/quizcharacter/father.png', 'explanation': 'Father translates to Apai / Apak.'},
            {'text': 'Grandmother', 'image': 'assets/images/quizcharacter/grandmother.png', 'explanation': 'Grandmother translates to Inik.'},
          ],
        ),
        QuestionModel(
          id: 'l1q3',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Aki',
          correctIbanList: ['Grandfather'],
          allIbanWords: [],
          options: [
            {'text': 'Grandmother', 'image': 'assets/images/quizcharacter/grandmother.png', 'explanation': 'Grandmother translates to Inik.'},
            {'text': 'Son', 'image': 'assets/images/quizcharacter/son.png', 'explanation': 'Son translates to Anak Laki.'},
            {'text': 'Grandfather', 'image': 'assets/images/quizcharacter/grandad.png', 'explanation': 'Grandfather translates to Aki.'},
            {'text': 'Father', 'image': 'assets/images/quizcharacter/father.png', 'explanation': 'Father translates to Apai / Apak.'},
          ],
        ),
        QuestionModel(
          id: 'l1q4',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Inik',
          correctIbanList: ['Grandmother'],
          allIbanWords: [],
          options: [
            {'text': 'Daughter', 'image': 'assets/images/quizcharacter/daughter.png', 'explanation': 'Daughter translates to Anak Induk.'},
            {'text': 'Mother', 'image': 'assets/images/quizcharacter/mother.png', 'explanation': 'Mother translates to Indai.'},
            {'text': 'Baby', 'image': 'assets/images/quizcharacter/baby.png', 'explanation': 'Baby translates to Anak Mit.'},
            {'text': 'Grandmother', 'image': 'assets/images/quizcharacter/grandmother.png', 'explanation': 'Grandmother translates to Inik.'},
          ],
        ),
        QuestionModel(
          id: 'l1q5',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Anak Induk',
          correctIbanList: ['Daughter'],
          allIbanWords: [],
          options: [
            {'text': 'Son', 'image': 'assets/images/quizcharacter/son.png', 'explanation': 'Son translates to Anak Laki.'},
            {'text': 'Daughter', 'image': 'assets/images/quizcharacter/daughter.png', 'explanation': 'Daughter translates to Anak Induk.'},
            {'text': 'Mother', 'image': 'assets/images/quizcharacter/mother.png', 'explanation': 'Mother translates to Indai.'},
            {'text': 'Grandfather', 'image': 'assets/images/quizcharacter/grandad.png', 'explanation': 'Grandfather translates to Aki.'},
          ],
        ),
        QuestionModel(
          id: 'l1q6',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Anak Laki',
          correctIbanList: ['Son'],
          allIbanWords: [],
          options: [
            {'text': 'Son', 'image': 'assets/images/quizcharacter/son.png', 'explanation': 'Son translates to Anak Laki.'},
            {'text': 'Father', 'image': 'assets/images/quizcharacter/father.png', 'explanation': 'Father translates to Apai / Apak.'},
            {'text': 'Baby', 'image': 'assets/images/quizcharacter/baby.png', 'explanation': 'Baby translates to Anak Mit.'},
            {'text': 'Daughter', 'image': 'assets/images/quizcharacter/daughter.png', 'explanation': 'Daughter translates to Anak Induk.'},
          ],
        ),
        QuestionModel(
          id: 'l1q7',
          type: 'recognize_word',
          promptText: 'Select the correct image',
          promptIban: 'Anak Mit',
          correctIbanList: ['Baby'],
          allIbanWords: [],
          options: [
            {'text': 'Baby', 'image': 'assets/images/quizcharacter/baby.png', 'explanation': 'Baby translates to Anak Mit.'},
            {'text': 'Grandmother', 'image': 'assets/images/quizcharacter/grandmother.png', 'explanation': 'Grandmother translates to Inik.'},
            {'text': 'Son', 'image': 'assets/images/quizcharacter/son.png', 'explanation': 'Son translates to Anak Laki.'},
            {'text': 'Father', 'image': 'assets/images/quizcharacter/father.png', 'explanation': 'Father translates to Apai / Apak.'},
          ],
        ),
      ],

      // ── LESSON 2: Daily Actions ─────────────────────────────────────────────
      'l2': [
        QuestionModel(
          id: 'l2q1',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Nama',
          correctIbanList: ['What'],
          allIbanWords: ['What', 'Where', 'Who', 'Why', 'When', 'How'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l2q2',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Dini',
          correctIbanList: ['Where'],
          allIbanWords: ['Where', 'What', 'How', 'Who', 'When', 'Why'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l2q3',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Gaga / Gigak',
          correctIbanList: ['Do'],
          allIbanWords: ['Do', 'Make', 'Eat', 'Drink', 'Cook', 'Matter'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l2q4',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Ngawa',
          correctIbanList: ['Matter'],
          allIbanWords: ['Matter', 'Cook', 'Eat', 'Drink', 'Do', 'Say'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l2q5',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Nyumai',
          correctIbanList: ['Cooking'],
          allIbanWords: ['Cooking', 'Eating', 'Drinking', 'Running', 'Sleeping', 'Walking'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l2q6',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Dik',
          correctIbanList: ['You (informal)'],
          allIbanWords: ['You (informal)', 'I', 'You (formal)', 'He', 'She'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l2q7',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Nuan',
          correctIbanList: ['You (formal)'],
          allIbanWords: ['You (formal)', 'I', 'You (informal)', 'They', 'We'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l2q8',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Makai',
          correctIbanList: ['Eat'],
          allIbanWords: ['Eat', 'Drink', 'Cook', 'Sleep', 'Walk', 'Run'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l2q9',
          type: 'translate',
          promptText: 'What does this word mean?',
          promptIban: 'Ngirup',
          correctIbanList: ['Drink'],
          allIbanWords: ['Drink', 'Eat', 'Cook', 'Walk', 'Run', 'Sleep'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l2q10',
          type: 'matching',
          promptText: 'Match the pairs!',
          promptIban: '',
          correctIbanList: [],
          allIbanWords: [],
          matchingPairs: {
            'Nama': 'What',
            'Dini': 'Where',
            'Nyumai': 'Cooking',
            'Makai': 'Eat',
            'Ngirup': 'Drink',
          },
        ),
      ],

      // ── LESSON 3: River Life ─────────────────────────────────────────────
      'l3': [
        QuestionModel(
          id: 'l3q1',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Nama pengawa dik apai?',
          correctIbanList: ['What', 'are', 'you', 'doing,', 'dad?'],
          allIbanWords: ['What', 'are', 'you', 'doing,', 'dad?', 'mother?', 'sleeping,', 'eating,'],
          characterAsset: 'assets/images/logo.jpg',
          grammarTip: 'Using "dik" or "nuan" before a title or name (like "dik apai") is the norm in Bahasa Iban communication. It sounds much more proper and natural to the ears!',
        ),
        QuestionModel(
          id: 'l3q2',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Nama nyumai dik inik?',
          correctIbanList: ['What', 'are', 'you', 'cooking,', 'grandmother?'],
          allIbanWords: ['What', 'are', 'you', 'cooking,', 'grandmother?', 'doing,', 'eating,', 'grandfather?'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l3q3',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Nama makai kita?',
          correctIbanList: ['What', 'are', 'we', 'eating?'],
          allIbanWords: ['What', 'are', 'we', 'eating?', 'you', 'doing?', 'cooking?', 'drinking?'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l3q4',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Dini makai dik indai?',
          correctIbanList: ['Where', 'are', 'you', 'eating,', 'mom?'],
          allIbanWords: ['Where', 'are', 'you', 'eating,', 'mom?', 'dad?', 'What', 'drinking,'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l3q5',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Nuan ngirup nama, aki?',
          correctIbanList: ['What', 'are', 'you', 'drinking,', 'grandfather?'],
          allIbanWords: ['What', 'are', 'you', 'drinking,', 'grandfather?', 'eating,', 'grandmother?', 'Where'],
          characterAsset: null,
        ),
      ],

      // ── LESSON 4: Folklore ───────────────────────────────────────────────
      'l4': [
        QuestionModel(
          id: 'l4q1',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Ini cerita orang tuai.',
          correctIbanList: ['This', 'is', 'an', 'elder\'s', 'story.'],
          allIbanWords: ['This', 'is', 'an', 'elder\'s', 'story.', 'old', 'myth', 'tale', 'legend'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l4q2',
          type: 'translate',
          promptText: 'Select the missing word',
          promptIban: 'Si ______ orang gagah.',
          correctIbanList: ['Apai'],
          allIbanWords: ['Apai', 'Indai', 'Anak', 'Tuai'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l4q3',
          type: 'translate',
          promptText: 'What does this mean?',
          promptIban: 'Bunsu Petara ngambi jiwa.',
          correctIbanList: ['The', 'spirit', 'took', 'the', 'soul.'],
          allIbanWords: ['The', 'spirit', 'took', 'the', 'soul.', 'god', 'warrior', 'river', 'mountain'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l4q4',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Orang Iban berani dalam perang.',
          correctIbanList: ['The', 'Iban', 'are', 'brave', 'in', 'war.'],
          allIbanWords: ['The', 'Iban', 'are', 'brave', 'in', 'war.', 'song', 'dance', 'afraid', 'peace'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l4q5',
          type: 'translate',
          promptText: 'Complete the sentence',
          promptIban: 'Lelaki tu ______ bendar.',
          correctIbanList: ['berani'],
          allIbanWords: ['berani', 'takut', 'lelah', 'sakit'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l4q6',
          type: 'translate',
          promptText: 'Select the missing word',
          promptIban: 'Dalam ______, banyak roh jahat.',
          correctIbanList: ['alas'],
          allIbanWords: ['alas', 'sungai', 'rumah', 'ladang'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l4q7',
          type: 'translate',
          promptText: 'What does this mean?',
          promptIban: 'Manang nga ubat orang sakit.',
          correctIbanList: ['The', 'shaman', 'heals', 'the', 'sick.'],
          allIbanWords: ['The', 'shaman', 'heals', 'the', 'sick.', 'sings', 'dances', 'hunts', 'feeds'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l4q8',
          type: 'translate',
          promptText: 'Translate the phrase',
          promptIban: 'Bertanya ka orang tuai.',
          correctIbanList: ['Ask', 'the', 'elders.'],
          allIbanWords: ['Ask', 'the', 'elders.', 'Teach', 'children', 'follow', 'bring', 'forgive'],
          characterAsset: null,
        ),
      ],

      // ── LESSON 5: Ceremonies ─────────────────────────────────────────────
      'l5': [
        QuestionModel(
          id: 'l5q1',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Gawai deka datai semalam.',
          correctIbanList: ['Gawai', 'is', 'coming', 'tomorrow.'],
          allIbanWords: ['Gawai', 'is', 'coming', 'tomorrow.', 'today', 'festival', 'harvest', 'ended'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l5q2',
          type: 'translate',
          promptText: 'Select the missing word',
          promptIban: 'Meri ______ ka semua orang.',
          correctIbanList: ['salam'],
          allIbanWords: ['salam', 'tuak', 'padi', 'buah'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l5q3',
          type: 'translate',
          promptText: 'What does this mean?',
          promptIban: 'Ngajat adalah tari tradisional.',
          correctIbanList: ['Ngajat', 'is', 'a', 'traditional', 'dance.'],
          allIbanWords: ['Ngajat', 'is', 'a', 'traditional', 'dance.', 'music', 'song', 'drum', 'ancient'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l5q4',
          type: 'translate',
          promptText: 'Translate this sentence',
          promptIban: 'Pua kumbu dipakai dalam majlis.',
          correctIbanList: ['Pua', 'kumbu', 'is', 'worn', 'at', 'ceremonies.'],
          allIbanWords: ['Pua', 'kumbu', 'is', 'worn', 'at', 'ceremonies.', 'used', 'woven', 'sold', 'market'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l5q5',
          type: 'translate',
          promptText: 'Complete the sentence',
          promptIban: 'Semua orang ______ dalam Gawai.',
          correctIbanList: ['beserumpu'],
          allIbanWords: ['beserumpu', 'diau', 'ngabang', 'menyanyi'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l5q6',
          type: 'translate',
          promptText: 'Select the missing word',
          promptIban: 'Lemambang ______ timang malam tu.',
          correctIbanList: ['ngempa'],
          allIbanWords: ['ngempa', 'ngigup', 'ngajat', 'madah'],
          characterAsset: null,
        ),
        QuestionModel(
          id: 'l5q7',
          type: 'translate',
          promptText: 'What does this mean?',
          promptIban: 'Pengabang datai ari jauh.',
          correctIbanList: ['Guests', 'come', 'from', 'far', 'away.'],
          allIbanWords: ['Guests', 'come', 'from', 'far', 'away.', 'family', 'elders', 'nearby', 'left'],
          characterAsset: 'assets/images/logo.jpg',
        ),
        QuestionModel(
          id: 'l5q8',
          type: 'translate',
          promptText: 'Translate this phrase',
          promptIban: 'Gerai nyamai, lantang semangat!',
          correctIbanList: ['Good', 'health,', 'strong', 'spirit!'],
          allIbanWords: ['Good', 'health,', 'strong', 'spirit!', 'long', 'life', 'brave', 'heart!'],
          characterAsset: null,
        ),
      ],
    };

    // Return lesson-specific questions or default back to l1
    return allQuestions[lessonId] ?? allQuestions['l1']!;
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
