class AppUser {
  final int userId;
  final String fullName;
  final String email;
  final String? phoneNumber;

  AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        userId: json['userId'],
        fullName: json['fullName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
      );
}

class Category {
  final int categoryId;
  final String name;
  final String? description;
  final int phrasesCount;

  Category({
    required this.categoryId,
    required this.name,
    this.description,
    this.phrasesCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json['categoryId'],
        name: json['name'],
        description: json['description'],
        phrasesCount: json['phrasesCount'] ?? 0,
      );
}

class Phrase {
  final int phraseId;
  final String text;
  final int userId;
  final int categoryId;
  final String? categoryName;
  final String? signImageUrl;

  Phrase({
    required this.phraseId,
    required this.text,
    required this.userId,
    required this.categoryId,
    this.categoryName,
    this.signImageUrl,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) => Phrase(
        phraseId: json['phraseId'],
        text: json['text'],
        userId: json['userId'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        signImageUrl: json['signImageUrl'],
      );
}
