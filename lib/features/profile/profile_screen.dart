import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/course_service.dart';
import '../../features/auth/login_screen.dart';
import '../courses/certificate_screen.dart';
import '../support/support_tickets_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _courseService = CourseService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  int _coursesCount = 0;
  int _completedCount = 0;
  List<Map<String, dynamic>> _completedEnrollments = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final role = _authService.currentRole;
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    if (role == "Instructor") {
      final courses = await _courseService.getInstructorCourses(userId);
      if (mounted) setState(() => _coursesCount = courses.length);
    } else {
      final enrollments = await _courseService.getUserEnrollmentsWithProgress();
      if (mounted) {
        setState(() {
          _completedEnrollments = enrollments.where((e) => e['is_completed'] == true).toList();
          _completedCount = _completedEnrollments.length;
          _coursesCount = enrollments.length;
        });
      }
    }
  }

  void _initControllers() {
    final user = _authService.currentUser;
    _nameController = TextEditingController(text: user?.userMetadata?['full_name'] ?? "");
    _bioController = TextEditingController(text: user?.userMetadata?['bio'] ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final url = await _authService.uploadAvatar(image);
        if (url != null) {
          await _authService.updateProfile(avatarUrl: url);
          if (mounted) {
            setState(() {}); // Refresh UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile picture updated!")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await _authService.updateProfile(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (mounted) {
        setState(() {}); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    _initControllers(); // Ensure controllers have latest data
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: "Bio",
                hintText: "Tell us about yourself...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final role = _authService.currentRole ?? "Student";
    final isStudent = role == "Student";
    final fullName = user?.userMetadata?['full_name'] ?? "User Name";
    final bio = user?.userMetadata?['bio'] ?? "No bio added yet.";
    final avatarUrl = user?.userMetadata?['avatar_url'];
    final avatarWidget = CircleAvatar(
      radius: 50,
      backgroundColor: const Color(0xFFEDF2FF),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? const Icon(Icons.person, size: 50, color: Color(0xFF1E3A8A))
          : null,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: AppColors.primaryDark),
        centerTitle: true,
        title: const Text(
          "Clarity",
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEDF2FF),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 18, color: Color(0xFF1E3A8A))
                  : null,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                /// 🔹 Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Stack(
                          children: [
                            avatarWidget,
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        role.toUpperCase() == "STUDENT" ? "ADVANCED LEARNER" : "INSTRUCTOR",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio.isEmpty ? "No bio added yet." : bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _showEditProfileDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F3F7),
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 🔹 Stats Section
                _buildStatCard(
                  icon: Icons.school,
                  iconColor: Colors.deepPurple,
                  value: isStudent ? _completedCount.toString() : _coursesCount.toString().padLeft(2, '0'),
                  label: isStudent ? "COURSES COMPLETED" : "COURSES CREATED",
                ),
                const SizedBox(height: 16),
                if (isStudent) ...[
                  _buildStatCard(
                    icon: Icons.verified,
                    iconColor: AppColors.primary,
                    value: _completedCount.toString().padLeft(2, '0'),
                    label: "ACTIVE CERTIFICATES",
                  ),
                  const SizedBox(height: 16),
                ],
                _buildStatCard(
                  icon: Icons.whatshot,
                  iconColor: Colors.orange,
                  value: "24",
                  label: "DAY LEARNING STREAK",
                ),

                const SizedBox(height: 32),

                /// 🔹 Recent Certificates (Only for Students)
                if (isStudent && _completedEnrollments.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Your Certificates",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._completedEnrollments.map((enrollment) {
                    final course = enrollment['course'] as Course;
                    final completedAt = DateTime.tryParse(enrollment['last_accessed'] ?? '') ?? DateTime.now();
                    final formattedDate = DateFormat('MMMM dd, yyyy').format(completedAt);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCertificateItem(
                        title: course.title,
                        date: "Issued $formattedDate",
                        id: "ID: CL-${course.id.substring(0, 4).toUpperCase()}",
                        icon: Icons.workspace_premium,
                        color: AppColors.primary.withOpacity(0.05),
                        iconColor: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CertificateScreen(course: course),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 32),

                /// 🔹 Account Settings
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        Icons.support_agent, 
                        _authService.currentUser?.email == 'abcd@gmail.com'
                            ? "Support Dashboard" 
                            : "Contact Support",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SupportTicketsScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildSettingsTile(Icons.notifications, "Notifications"),
                      const Divider(height: 1, indent: 56),
                      _buildSettingsTile(Icons.security, "Privacy & Security"),
                      const Divider(height: 1, indent: 56),
                      _buildSettingsTile(Icons.language, "Language", trailing: "English (US)"),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black26,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateItem({
    required String title,
    required String date,
    required String id,
    required IconData icon,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$date • $id",
                    style: const TextStyle(fontSize: 11, color: Colors.black26, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {String? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(fontSize: 12, color: Colors.black26, fontWeight: FontWeight.bold),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black12, size: 20),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }
}
