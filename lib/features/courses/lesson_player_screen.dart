import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../core/models/course.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/course_service.dart';
import 'quiz_screen.dart';
import 'certificate_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Course course;

  const LessonPlayerScreen({
    super.key,
    required this.course,
  });

  @override
  State<LessonPlayerScreen> createState() =>
      _LessonPlayerScreenState();
}

class _LessonPlayerScreenState
    extends State<LessonPlayerScreen> {
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService();

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _checkProgress();
  }

  Future<void> _checkProgress() async {
    final completed = await _courseService.isCourseCompleted(widget.course.id);
    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  void _onQuizCompleted(dynamic result) {
    if (result == true) {
      _checkProgress();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Prioritize the explicit video_url field, fallback to thumbnailUrl for legacy compatibility
      final String videoUrl = widget.course.videoUrl ?? widget.course.thumbnailUrl ?? '';

      if (videoUrl.isEmpty) throw Exception("No video source found for this course.");

      debugPrint("INITIALIZING VIDEO: $videoUrl");

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        aspectRatio: 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: Colors.white.withOpacity(0.3),
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("VIDEO ERROR: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? 'Scholar';
    final String? avatarUrl = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lesson Player",
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(fullName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))
                  : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _hasError
                    ? const Center(child: Text("Unable to load video", style: TextStyle(color: Colors.white)))
                    : Chewie(controller: _chewieController!),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata Row
                  Row(
                    children: [
                      _buildBadge(widget.course.category.toUpperCase()),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 18, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text("4.9", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.course.title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.course.description ?? "Embark on this learning journey. This module covers core concepts hosted securely on Supabase.",
                    style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.6),
                  ),

                  const SizedBox(height: 32),

                  // Certificate Section
                  if (_isCompleted)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CertificateScreen(course: widget.course),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.workspace_premium, color: Colors.green),
                            SizedBox(width: 12),
                            Text(
                              "View Certificate",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Only show "Take Quiz" if not completed
                    _buildNextUpCard(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNextUpCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(courseId: widget.course.id),
          ),
        );
        _onQuizCompleted(result);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.bolt, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NEXT STEP", style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  Text("Certification Quiz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}