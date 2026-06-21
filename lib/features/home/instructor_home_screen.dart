import 'package:flutter/material.dart';
import '../../core/models/course.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/course_service.dart';
import '../courses/create_course_screen.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  final _courseService = CourseService();
  final _authService = AuthService();
  
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'totalEarnings': 0.0,
    'totalStudents': 0,
    'totalCourses': 0,
  };
  List<Map<String, dynamic>> _enrollments = [];
  List<Map<String, dynamic>> _activeCoursesData = [];
  List<Map<String, dynamic>> _filteredCoursesData = [];
  
  String _searchQuery = "";
  String _selectedCategory = "All";
  
  final List<String> _categories = [
    'All',
    'Design & Arts',
    'Development',
    'Business',
    'Marketing',
    'Lifestyle'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final instructorId = _authService.currentUser!.id;
      final stats = await _courseService.getInstructorStats(instructorId);
      final coursesWithCount = await _courseService.getInstructorCoursesWithEnrollmentCount(instructorId);
      final enrollments = await _courseService.getUserEnrollmentsWithProgress();
      
      setState(() {
        _stats = {
          'totalEarnings': stats['earnings'] ?? 0.0,
          'totalStudents': stats['students'] ?? 0,
          'totalCourses': stats['courses'] ?? 0,
        };
        _activeCoursesData = coursesWithCount;
        _enrollments = enrollments;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCoursesData = _activeCoursesData.where((data) {
        final course = data['course'] as Course;
        final matchesSearch = course.title
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == "All" ||
            course.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? "Professor";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu, color: Color(0xFF1E3A8A)),
        ),
        centerTitle: true,
        title: const Text(
          "Clarity",
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEDF2FF),
              backgroundImage: user?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(user!.userMetadata!['avatar_url'])
                  : null,
              child: user?.userMetadata?['avatar_url'] == null
                  ? const Icon(Icons.person, color: Color(0xFF1E3A8A))
                  : null,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "INSTRUCTOR DASHBOARD",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Welcome back,\n$userName",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E1E),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
                    );
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                    shadowColor: const Color(0xFF0052CC).withOpacity(0.3),
                  ),
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: const Text("Create Course", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              if (_enrollments.isNotEmpty) ...[
                const SizedBox(height: 48),
                const Text(
                  "CONTINUE YOUR LEARNING",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black26,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _enrollments.length,
                    itemBuilder: (context, index) {
                      final enrollment = _enrollments[index];
                      final course = enrollment['course'] as Course;
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEDF2FF)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                course.thumbnailUrl ?? "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=200",
                                width: 60, height: 60, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                course.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 48),

              _buildVerticalStatCard(
                title: "Total Earnings",
                value: "${_stats['totalEarnings'].toStringAsFixed(2)} Tk",
                badgeText: "+8.4% this month",
                badgeColor: Colors.green,
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 24),
              _buildVerticalStatCard(
                title: "Students Enrolled",
                value: _stats['totalStudents'].toString(),
                badgeText: "${_stats['totalStudents']} total students",
                badgeColor: const Color(0xFF6366F1),
                icon: Icons.people_rounded,
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Active\nCourses",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1E1E),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_filteredCoursesData.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text("No courses found", style: TextStyle(color: Colors.black26, fontSize: 16))),
                )
              else
                ..._filteredCoursesData.map((data) {
                  final course = data['course'] as Course;
                  final enrollmentCount = data['enrollment_count'] as int;
                  return _buildActiveCourseItem(
                    title: course.title,
                    students: "$enrollmentCount students",
                    rating: "4.9",
                    imageUrl: (course.thumbnailUrl != null && course.thumbnailUrl!.startsWith('http')) 
                        ? course.thumbnailUrl!
                        : "https://images.unsplash.com/photo-1558655146-d09347e92766?w=400",
                  );
                }),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalStatCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title == "Total Earnings")
                        const Icon(Icons.trending_up, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: badgeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 64, color: const Color(0xFFF1F3F7)),
        ],
      ),
    );
  }

  Widget _buildActiveCourseItem({
    required String title,
    required String students,
    required String rating,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl, 
              width: 100, height: 75, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], width: 100, height: 75, child: const Icon(Icons.image, color: Colors.black12)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.black26),
                    const SizedBox(width: 6),
                    Text(students, style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 20),
                    const Icon(Icons.star_rounded, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E))),
                    const Text(" rating", style: TextStyle(fontSize: 12, color: Colors.black26)),
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