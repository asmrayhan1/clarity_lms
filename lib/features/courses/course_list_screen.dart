import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/course_service.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  final String? initialCategory;
  const CourseListScreen({super.key, this.initialCategory});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _courseService = CourseService();
  final _authService = AuthService();
  bool _isLoading = true;
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String _selectedCategory = 'All Topics';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoading = true);
    try {
      final role = _authService.currentRole;
      if (role == 'Instructor') {
        final userId = _authService.currentUser?.id;
        if (userId != null) {
          _allCourses = await _courseService.getInstructorCourses(userId);
        }
      } else {
        _allCourses = await _courseService.getAllCourses();
      }
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching courses: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        final matchesCategory = _selectedCategory == 'All Topics' || course.category == _selectedCategory;
        final matchesSearch = course.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (course.description?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = _authService.currentRole;
    final isInstructor = role == 'Instructor';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Color(0xFF1E3A8A)),
        centerTitle: true,
        title: const Text(
          "Clarity",
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEDF2FF),
              backgroundImage: _authService.currentUser?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(_authService.currentUser!.userMetadata!['avatar_url'])
                  : null,
              child: _authService.currentUser?.userMetadata?['avatar_url'] == null
                  ? const Icon(Icons.person, color: Color(0xFF1E3A8A))
                  : null,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DISCOVER WISDOM",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Expand your\nhorizons",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilters(),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.black26),
                        hintText: "What would you like to learn?",
                        hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip("All Topics"),
                        _buildCategoryChip("Design & Arts"),
                        _buildCategoryChip("Development"),
                        _buildCategoryChip("Business"),
                        _buildCategoryChip("Marketing"),
                        _buildCategoryChip("Lifestyle"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _filteredCourses.isEmpty
                      ? _buildEmptyState(isInstructor)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            return _buildCourseCard(_filteredCourses[index]);
                          },
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0052CC) : const Color(0xFFEDF2FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isInstructor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            isInstructor ? "You haven't created any courses yet." : "No courses available at the moment.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black38, fontSize: 14),
          ),
        ],
      ),
    );
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

  Widget _buildCourseCard(Course course) {
    // Mock data for UI elements not in DB
    final String tag = course.price > 100 ? "BESTSELLER" : "NEW RELEASE";
    final double rating = 4.5 + (course.title.length % 5) / 10;
    final String reviews = "${(course.title.length * 123) % 3000}";

    final String displayImageUrl = _getThumbnail(course.thumbnailUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  displayImageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), letterSpacing: 0.5),
                  ),
                ),
              ),
              // Play icon overlay if it's a video
              if (course.thumbnailUrl?.contains('youtube') ?? false)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "($reviews reviews)",
                      style: const TextStyle(fontSize: 12, color: Colors.black26),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${course.price.toStringAsFixed(2)} Tk",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(courseId: course.id, course: course),
                          ),
                        );
                      },
                      icon: const Text(
                        "View Course",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                      label: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1E3A8A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
