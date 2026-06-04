import 'package:flutter/material.dart';
import '../../core/models/quiz.dart';
import '../../core/services/quiz_service.dart';
import '../../core/services/course_service.dart';
import '../../core/constants/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;

  const QuizScreen({super.key, required this.courseId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final CourseService _courseService = CourseService();
  
  Quiz? _quiz;
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  int _score = 0;
  
  // Cache shuffled options for each question to prevent reshuffling on setState
  final Map<int, List<String>> _shuffledOptionsMap = {};

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final quiz = await _quizService.getQuizForCourse(widget.courseId);
    if (mounted) {
      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });
    }
  }

  List<String> _getOptions(int index) {
    if (!_shuffledOptionsMap.containsKey(index)) {
      _shuffledOptionsMap[index] = _quiz!.questions[index].allOptions;
    }
    return _shuffledOptionsMap[index]!;
  }

  void _nextQuestion() {
    if (_selectedOption == null) return;

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];
    if (_selectedOption == currentQuestion.correctOption) {
      _score++;
    }

    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final bool isPassed = _score >= (_quiz?.passingScore ?? 7);
    
    await _quizService.submitQuizAttempt(
      quizId: _quiz!.id,
      score: _score,
      isPassed: isPassed,
    );
    
    if (isPassed) {
      await _courseService.updateProgress(widget.courseId, true);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isPassed ? "Excellent Work!" : "Quiz Completed"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You got $_score out of ${_quiz!.questions.length} correct.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (isPassed) ...[
              const Icon(Icons.workspace_premium, color: Colors.orange, size: 64),
              const SizedBox(height: 12),
              const Text(
                "Course Completed!",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18),
              ),
            ] else ...[
              const Icon(Icons.refresh, color: Colors.grey, size: 64),
              const SizedBox(height: 12),
              const Text(
                "Keep learning and try again.",
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                "Need ${_quiz!.passingScore} correct to pass.",
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ]
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 8),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, isPassed); // Back to lesson player
              },
              child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_quiz == null || _quiz!.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz_outlined, size: 64, color: Colors.black12),
              const SizedBox(height: 16),
              const Text("No quiz available for this course."),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go Back")),
            ],
          ),
        ),
      );
    }

    final question = _quiz!.questions[_currentQuestionIndex];
    final options = _getOptions(_currentQuestionIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(_quiz!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${_currentQuestionIndex + 1} of ${_quiz!.questions.length}",
                      style: const TextStyle(
                        color: AppColors.primary, 
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Choose the correct answer",
                      style: TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Score: $_score",
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _quiz!.questions.length,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(28),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Text(
                question.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = _selectedOption == option;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => setState(() => _selectedOption = option),
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03), 
                                blurRadius: 15, 
                                offset: const Offset(0, 8)
                              )
                            else
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3), 
                                blurRadius: 15, 
                                offset: const Offset(0, 8)
                              )
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.black12, 
                                  width: 2
                                ),
                              ),
                              child: Center(
                                child: isSelected
                                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                                    : Text(
                                        String.fromCharCode(65 + index),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black26,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _selectedOption != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  disabledBackgroundColor: Colors.grey[200],
                  elevation: 0,
                ),
                child: Text(
                  _currentQuestionIndex < _quiz!.questions.length - 1 ? "Next Question" : "Submit Quiz",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
