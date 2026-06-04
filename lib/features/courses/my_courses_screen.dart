import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/services/course_service.dart';
import 'lesson_player_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final CourseService _courseService = CourseService();
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;
  String _filter = 'All'; // 'All', 'In Progress', 'Completed'

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() => _isLoading = true);
    try {
      // We need to fetch enrollment data including progress
      // Re-using getUserEnrollments but we might need more data
      final response = await _courseService.getUserEnrollmentsWithProgress();
      setState(() {
        _enrollments = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading enrollments: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredEnrollments {
    if (_filter == 'All') return _enrollments;
    if (_filter == 'Completed') {
      return _enrollments.where((e) => e['is_completed'] == true).toList();
    }
    return _enrollments.where((e) => e['is_completed'] == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Courses", style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEnrollments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredEnrollments.length,
                        itemBuilder: (context, index) {
                          final enrollment = _filteredEnrollments[index];
                          final course = enrollment['course'] as Course;
                          final isCompleted = enrollment['is_completed'] as bool;
                          
                          return _buildEnrollmentCard(course, isCompleted);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['All', 'In Progress', 'Completed'].map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _filter = f);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.primary),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnrollmentCard(Course course, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _getThumbnail(course.thumbnailUrl),
            width: 80,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 80, height: 60, color: Colors.grey[200]),
          ),
        ),
        title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(course.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                  size: 14,
                  color: isCompleted ? Colors.green : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  isCompleted ? "Completed" : "In Progress",
                  style: TextStyle(fontSize: 12, color: isCompleted ? Colors.green : AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LessonPlayerScreen(course: course)),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No courses found for '$_filter'", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _getThumbnail(String? url) {
    if (url == null || url.isEmpty) return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400';
    final regExp = RegExp(r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})');
    final match = regExp.firstMatch(url);
    if (match != null) return 'https://img.youtube.com/vi/${match.group(1)}/hqdefault.jpg';
    return url;
  }
}
