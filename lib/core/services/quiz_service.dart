import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';

class QuizService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Quiz?> getQuizForCourse(String courseId) async {
    try {
      final quizResponse = await _supabase
          .from('quizzes')
          .select()
          .eq('course_id', courseId)
          .maybeSingle();

      if (quizResponse == null) return null;

      final questionsResponse = await _supabase
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizResponse['id']);

      return Quiz.fromJson(
        quizResponse,
        questionsResponse as List<dynamic>,
      );
    } catch (e) {
      print("Error fetching quiz: $e");
      return null;
    }
  }

  Future<void> submitQuizAttempt({
    required String quizId,
    required int score,
    required bool isPassed,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('quiz_attempts').insert({
        'user_id': userId,
        'quiz_id': quizId,
        'score': score,
        'is_passed': isPassed,
      });
    } catch (e) {
      print("Error submitting quiz attempt: $e");
    }
  }
}
