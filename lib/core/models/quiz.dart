class Quiz {
  final String id;
  final String courseId;
  final String title;
  final List<QuizQuestion> questions;
  final int passingScore;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
    this.passingScore = 7,
  });

  factory Quiz.fromJson(Map<String, dynamic> json, List<dynamic> questionsJson) {
    return Quiz(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      title: json['title'] ?? '',
      questions: questionsJson.map((q) => QuizQuestion.fromJson(q)).toList(),
      passingScore: json['passing_score'] ?? 7,
    );
  }
}

class QuizQuestion {
  final String id;
  final String text;
  final String correctOption;
  final List<String> distractors;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.correctOption,
    required this.distractors,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      text: json['question_text'] ?? '',
      correctOption: json['correct_option'] ?? '',
      distractors: List<String>.from(json['distractors'] ?? []),
    );
  }

  List<String> get allOptions {
    final list = [correctOption, ...distractors];
    list.shuffle();
    return list;
  }
}
