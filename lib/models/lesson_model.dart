class UserProgress {
  String username;
  String? avatarUrl;
  int xp;
  int streak;
  int hearts;
  List<String> completedLessons;
  List<String>? unlockedAchievements;
  DateTime? lastLogin;

  UserProgress({
    required this.username,
    this.avatarUrl,
    required this.xp,
    required this.streak,
    required this.hearts,
    required this.completedLessons,
    this.unlockedAchievements,
    this.lastLogin,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconStr;
  final int colorVal; 

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconStr,
    required this.colorVal,
  });
}

class LanguageModel {
  final String id;
  final String name;
  final String iconStr;
  final String cultureDescription;

  LanguageModel({
    required this.id,
    required this.name,
    required this.iconStr,
    required this.cultureDescription,
  });
}

class LessonModel {
  final String id;
  final String title;
  final String difficulty;

  LessonModel({
    required this.id,
    required this.title,
    required this.difficulty,
  });
}

class QuestionModel {
  final String id;
  final String type; // e.g., "translate"
  final String promptText;
  final String promptIban;
  final List<String> correctIbanList;
  final List<String> allIbanWords;
  final String? characterAsset; // local asset for character

  QuestionModel({
    required this.id,
    required this.type,
    required this.promptText,
    required this.promptIban,
    required this.correctIbanList,
    required this.allIbanWords,
    this.characterAsset,
  });
}
