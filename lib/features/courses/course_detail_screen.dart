import 'package:flutter/material.dart';
import '../../core/services/course_service.dart';
import '../../core/models/course.dart';
import 'payment_screen.dart';
import 'lesson_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final Course? course;

  const CourseDetailScreen({super.key, required this.courseId, this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _courseService = CourseService();
  bool _isLoading = true;
  Course? _course;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _course = widget.course;
      _isLoading = false;
    }
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    setState(() => _isLoading = true);
    try {
      final data = await _courseService.getCourseWithInstructor(widget.courseId);
      setState(() {
        _course = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  String _getThumbnail(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800';
    }

    final regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final videoId = match.group(1);
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_course == null) {
      return const Scaffold(body: Center(child: Text("Course not found")));
    }

    final instructorName = "Instructor"; // TODO: Extract from Course model if profile is joined
    final instructorAvatar = "https://ui-avatars.com/api/?name=${Uri.encodeComponent(instructorName)}&background=random";
    
    final title = _course!.title;
    final description = _course!.description ?? "";
    final price = _course!.price.toString();
    final duration = _course!.duration;
    final thumbnailUrl = _course!.thumbnailUrl ?? "";
    
    // Use the improved thumbnail logic
    final displayImageUrl = _getThumbnail(thumbnailUrl);

    double mainPrice = double.parse(price) * 1.1;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Clarity",
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E3A8A), size: 20),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFEDF2FF),
              child: Icon(Icons.person, size: 16, color: Color(0xFF1E3A8A)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Card
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: NetworkImage(displayImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "BESTSELLER",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructor Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(instructorAvatar),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("INSTRUCTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                          Text(instructorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _StatRow(icon: Icons.star, value: "4.9", label: "(2.1k reviews)", iconColor: Colors.blue),
                      _StatRow(icon: Icons.access_time_filled, value: duration, label: "DURATION", iconColor: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              "About this course",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, height: 1.6, fontSize: 14),
            ),

            const SizedBox(height: 32),

            // Pricing Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("LIFETIME ACCESS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("\$$price", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Text("\$${mainPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.black26, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow(Icons.check_circle, "Full Lifetime Access"),
                  _buildFeatureRow(Icons.tablet_android, "Access on Mobile and TV"),
                  _buildFeatureRow(Icons.workspace_premium, "Certificate of Completion"),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Check if already enrolled
                        try {
                          final enrolled = await _courseService.getUserEnrollments();
                          final isEnrolled = enrolled.any((c) => c.id == widget.courseId);
                          
                          if (isEnrolled && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LessonPlayerScreen(
                                  course: _course!,
                                ),
                              ),
                            );
                            return;
                          }
                        } catch (_) {}

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(courseData: _course!.toJson()..['id'] = _course!.id),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Enroll in Course", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text("30-DAY MONEY-BACK GUARANTEE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black26)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumItem(String number, String title, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black26),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 20),
            _buildLessonItem(Icons.play_circle_fill, "Introduction to Architecture Philosophy", "12:40"),
            _buildLessonItem(Icons.article_outlined, "The 7 Pillars of Scalability", "Reading"),
          ]
        ],
      ),
    );
  }

  Widget _buildLessonItem(IconData icon, String title, String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black26),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Text(info, style: const TextStyle(fontSize: 11, color: Colors.black26)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatRow({required this.icon, required this.value, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black26, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
