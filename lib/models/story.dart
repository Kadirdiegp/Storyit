class Story {
  static String? huggingFaceApiKey;

  final String id;
  final String title;
  final String content;
  final String theme;
  final int ageGroup;
  final String childName;
  final DateTime createdAt;
  final DateTime expiresAt;
  bool isFavorite;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.theme,
    required this.ageGroup,
    required this.childName,
    required this.createdAt,
    required this.expiresAt,
    this.isFavorite = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Konvertierung zu/von JSON für lokale Speicherung
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'theme': theme,
        'ageGroup': ageGroup,
        'childName': childName,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        theme: json['theme'],
        ageGroup: json['ageGroup'],
        childName: json['childName'],
        createdAt: DateTime.parse(json['createdAt']),
        expiresAt: DateTime.parse(json['expiresAt']),
        isFavorite: json['isFavorite'],
      );

  static void setApiKey(String apiKey) {
    huggingFaceApiKey = apiKey;
  }
}
