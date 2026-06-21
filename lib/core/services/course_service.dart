import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class CourseService {
  final _supabase = Supabase.instance.client;

  // --- COURSE MANAGEMENT ---

  Future<List<Course>> getCourses() async {
    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false);

    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getAllCourses() => getCourses();

  Future<List<Course>> getInstructorCourses(String instructorId) async {
    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .eq('instructor_id', instructorId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getInstructorActiveCourses(String instructorId) => getInstructorCourses(instructorId);

  Future<Map<String, dynamic>> getInstructorStats(String instructorId) async {
    try {
      // 1. Fetch all courses for this instructor
      final List coursesResponse = await _supabase
          .from('courses')
          .select('id, price')
          .eq('instructor_id', instructorId);

      double totalEarnings = 0.0;
      int totalStudentsCount = 0;

      // 2. For each course, fetch enrollment count individually via separate query
      for (final course in coursesResponse) {
        final String courseId = course['id'];
        final double price = double.tryParse(course['price']?.toString() ?? '0') ?? 0.0;

        final List enrollmentsResponse = await _supabase
            .from('enrollments')
            .select('id')
            .eq('course_id', courseId);

        final int count = enrollmentsResponse.length;
        totalStudentsCount += count;
        totalEarnings += (count * price);
      }

      return {
        'earnings': totalEarnings,
        'students': totalStudentsCount,
        'courses': coursesResponse.length,
      };
    } catch (e) {
      debugPrint("CourseService Error (getInstructorStats): $e");
      return {'earnings': 0.0, 'students': 0, 'courses': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getInstructorCoursesWithEnrollmentCount(String instructorId) async {
    try {
      // 1. Fetch instructor courses
      final List coursesData = await _supabase
          .from('courses')
          .select('*')
          .eq('instructor_id', instructorId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> results = [];

      // 2. For each course, fetch its specific enrollment count
      for (final json in coursesData) {
        final String courseId = json['id'];

        final List enrollmentsData = await _supabase
            .from('enrollments')
            .select('id')
            .eq('course_id', courseId);

        results.add({
          'course': Course.fromJson(json),
          'enrollment_count': enrollmentsData.length,
        });
      }

      return results;
    } catch (e) {
      debugPrint("CourseService Error (getInstructorCoursesWithEnrollmentCount): $e");
      return [];
    }
  }

  Future<String> createCourse(Course course) async {
    final response = await _supabase
        .from('courses')
        .insert(course.toJson())
        .select('id')
        .single();
    return response['id'];
  }

  Future<Course?> getCourseWithInstructor(String courseId) async {
    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .eq('id', courseId)
        .maybeSingle();
    
    if (response == null) return null;
    return Course.fromJson(response);
  }

  // --- STORAGE ---

  Future<String> uploadVideo(Uint8List bytes, String fileName) async {
    final path = 'course_videos/$fileName';
    await _supabase.storage.from('videos').uploadBinary(path, bytes);
    return _supabase.storage.from('videos').getPublicUrl(path);
  }

  Future<String> uploadThumbnail(Uint8List bytes, String fileName) async {
    final path = 'thumbnails/$fileName';
    await _supabase.storage.from('images').uploadBinary(path, bytes);
    return _supabase.storage.from('images').getPublicUrl(path);
  }

  // --- ENROLLMENT & PROGRESS ---

  Future<void> enrollInCourse(String courseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('enrollments').upsert({
      'user_id': userId,
      'course_id': courseId,
      'last_accessed': DateTime.now().toIso8601String(),
    });
  }

  Future<void> enrollUser(String courseId) => enrollInCourse(courseId);

  Future<bool> isEnrolled(String courseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('enrollments')
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();

    return response != null;
  }

  Future<List<Course>> getUserEnrollments() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final enrollments = await _supabase
        .from('enrollments')
        .select('course_id')
        .eq('user_id', userId);

    if (enrollments.isEmpty) return [];

    final courseIds = enrollments.map((e) => e['course_id'] as String).toList();

    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .inFilter('id', courseIds);

    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getUserEnrollmentsWithProgress() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final enrollmentRecords = await _supabase
          .from('enrollments')
          .select('course_id, is_completed, last_accessed')
          .eq('user_id', userId)
          .order('last_accessed', ascending: false);

      if (enrollmentRecords.isEmpty) return [];

      final List<String> courseIds = enrollmentRecords
          .map((e) => e['course_id'] as String)
          .toList();

      final coursesResponse = await _supabase
          .from('courses')
          .select('*, profiles(full_name)')
          .inFilter('id', courseIds);

      final List<Course> courses = (coursesResponse as List)
          .map((json) => Course.fromJson(json))
          .toList();

      return enrollmentRecords.map((record) {
        final course = courses.firstWhere((c) => c.id == record['course_id']);
        return {
          'course': course,
          'is_completed': record['is_completed'] ?? false,
          'last_accessed': record['last_accessed'],
        };
      }).toList();
    } catch (e) {
      debugPrint("Error in getUserEnrollmentsWithProgress: $e");
      return [];
    }
  }

  Future<void> updateProgress(String courseId, bool isCompleted) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('enrollments')
        .update({
          'is_completed': isCompleted,
          'last_accessed': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('course_id', courseId);
  }

  Future<bool> isCourseCompleted(String courseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('enrollments')
        .select('is_completed')
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();

    return response?['is_completed'] ?? false;
  }

  // --- SEARCH & CATEGORIES ---

  Future<List<Course>> searchCourses(String query) async {
    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .ilike('title', '%$query%')
        .order('created_at', ascending: false);

    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getCoursesByCategory(String category) async {
    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .eq('category', category)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getRecommendedCourses({int limit = 6}) async {
    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .limit(limit)
        .order('created_at', ascending: false);
    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getRecentlyViewedCourses({int limit = 5}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final enrollments = await _supabase
        .from('enrollments')
        .select('course_id')
        .eq('user_id', userId)
        .order('last_accessed', ascending: false)
        .limit(limit);

    if (enrollments.isEmpty) return [];
    final courseIds = enrollments.map((e) => e['course_id'] as String).toList();

    final response = await _supabase
        .from('courses')
        .select('*, profiles(full_name)')
        .inFilter('id', courseIds);

    return (response as List).map((json) => Course.fromJson(json)).toList();
  }

  // --- QUIZ MANAGEMENT ---

  Future<void> createQuiz(String courseId, List<Map<String, dynamic>> questions) async {
    try {
      final quizResponse = await _supabase
          .from('quizzes')
          .insert({
            'course_id': courseId,
            'title': 'Certification Quiz', // Default title if not provided
          })
          .select()
          .single();

      final quizId = quizResponse['id'];

      final List<Map<String, dynamic>> questionsData = questions.map((q) => {
            'quiz_id': quizId,
            'question_text': q['question_text'],
            'correct_option': q['correct_option'],
            'distractors': q['distractors'],
          }).toList();

      await _supabase.from('quiz_questions').insert(questionsData);
    } catch (e) {
      debugPrint("Error creating quiz: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getQuizForCourse(String courseId) async {
    try {
      final quiz = await _supabase
          .from('quizzes')
          .select('*, quiz_questions(*)')
          .eq('course_id', courseId)
          .maybeSingle();
      return quiz;
    } catch (e) {
      debugPrint("Error fetching quiz: $e");
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
        'attempted_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Error submitting quiz attempt: $e");
    }
  }

  Future<bool> hasPassedQuiz(String courseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final quiz = await _supabase
          .from('quizzes')
          .select('id')
          .eq('course_id', courseId)
          .maybeSingle();

      if (quiz == null) return false;

      final attempt = await _supabase
          .from('quiz_attempts')
          .select('is_passed')
          .match({'user_id': userId, 'quiz_id': quiz['id'], 'is_passed': true}).maybeSingle();

      return attempt != null;
    } catch (e) {
      debugPrint("Error checking quiz pass status: $e");
      return false;
    }
  }
}
