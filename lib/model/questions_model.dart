class Question {
  final String id;
  final String title;
  final Map<String, String> options;
  final String correctOption;

  Question({
    required this.id,
    required this.title,
    required this.options,
    required this.correctOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      options: (json['options'] as Map<String, dynamic>).cast<String, String>(),
      correctOption: json['correctOption'] ?? '',
    );
  }
}
