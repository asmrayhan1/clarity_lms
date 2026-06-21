import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/course_service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _selectedCategory = 'Design & Arts';
  bool _isLoading = false;
  Uint8List? _videoBytes;
  String? _videoName;
  Uint8List? _thumbBytes;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Design & Arts',
    'Development',
    'Business',
    'Marketing',
    'Lifestyle'
  ];

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final bytes = await video.readAsBytes();
      setState(() {
        _videoBytes = bytes;
        _videoName = video.name;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _thumbBytes = bytes);
    }
  }

  final List<Map<String, dynamic>> _quizQuestions = List.generate(10, (index) => {
    'question_text': '',
    'correct_option': '',
    'distractors': ['', '', ''],
  });

  Future<void> _publishCourse() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate Quiz
    for (int i = 0; i < 10; i++) {
      if (_quizQuestions[i]['question_text'].isEmpty || 
          _quizQuestions[i]['correct_option'].isEmpty ||
          (_quizQuestions[i]['distractors'] as List).any((d) => d.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please complete all 10 quiz questions (Question ${i+1} is incomplete)")),
        );
        return;
      }
    }

    if (_videoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a course video")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final courseService = CourseService();
      
      String? videoUrl;
      String? thumbnailUrl;

      // 1. Upload Video
      final videoName = "video_${DateTime.now().millisecondsSinceEpoch}_${_videoName ?? 'course.mp4'}";
      videoUrl = await courseService.uploadVideo(_videoBytes!, videoName);
      
      // 2. Upload Thumbnail (Optional)
      if (_thumbBytes != null) {
        final thumbName = "thumb_${DateTime.now().millisecondsSinceEpoch}.jpg";
        thumbnailUrl = await courseService.uploadThumbnail(_thumbBytes!, thumbName);
      }

      // 3. Create Course Record
      final newCourse = Course(
        id: '', 
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        instructorId: authService.currentUser!.id,
        category: _selectedCategory,
        price: double.tryParse(_priceController.text) ?? 0,
        level: 'Beginner',
        duration: _durationController.text.trim().isNotEmpty ? _durationController.text.trim() : 'Self-paced',
        createdAt: DateTime.now(),
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
      );

      final courseId = await courseService.createCourse(newCourse);
      
      // 4. Create Quiz
      await courseService.createQuiz(courseId, _quizQuestions);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Course and Quiz published successfully!")),
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

  Widget _buildQuizSection() {
    return _buildSectionCard(
      icon: Icons.quiz_outlined,
      title: "Final Assessment (10 Questions)",
      children: [
        const Text(
          "Create 10 multiple choice questions for your students to pass the course.",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          separatorBuilder: (context, index) => const Divider(height: 40),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Question ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: _inputDecoration("Enter question text"),
                  onChanged: (v) => _quizQuestions[index]['question_text'] = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: _inputDecoration("Correct Answer").copyWith(
                    prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                  ),
                  onChanged: (v) => _quizQuestions[index]['correct_option'] = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: _inputDecoration("False Option 1").copyWith(
                    prefixIcon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                  ),
                  onChanged: (v) => _quizQuestions[index]['distractors'][0] = v,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _inputDecoration("False Option 2").copyWith(
                    prefixIcon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                  ),
                  onChanged: (v) => _quizQuestions[index]['distractors'][1] = v,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _inputDecoration("False Option 3").copyWith(
                    prefixIcon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                  ),
                  onChanged: (v) => _quizQuestions[index]['distractors'][2] = v,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CURRICULUM DESIGNER",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create Course",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Transform your expertise into a luminous learning journey.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),

              _buildSectionCard(
                icon: Icons.map_outlined,
                title: "Foundation & Context",
                children: [
                  _buildLabel("Course Title"),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration("e.g. Masterclass in Minimalist Architecture"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Category"),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _inputDecoration(""),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Price (Taka)"),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("0.00 Tk"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                icon: Icons.description_outlined,
                title: "The Scholar's Invitation",
                children: [
                  _buildLabel("Course Description"),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: _inputDecoration("Describe the journey your students will take..."),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Video Hours"),
                  TextFormField(
                    controller: _durationController,
                    decoration: _inputDecoration("e.g. 10 Hours"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                icon: Icons.video_library_outlined,
                title: "Curriculum & Assets",
                children: [
                  _buildLabel("Course Video"),
                  InkWell(
                    onTap: _pickVideo,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            _videoBytes != null ? "Video Selected" : "Upload Main Course Video",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (_videoBytes != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(_videoName ?? "course_video.mp4", style: const TextStyle(fontSize: 10, color: Colors.black38)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Course Thumbnail (Optional)"),
                  InkWell(
                    onTap: _pickThumbnail,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F8),
                        borderRadius: BorderRadius.circular(20),
                        image: _thumbBytes != null 
                          ? DecorationImage(image: MemoryImage(_thumbBytes!), fit: BoxFit.cover) 
                          : null,
                      ),
                      child: _thumbBytes == null ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, size: 24, color: Colors.black.withOpacity(0.2)),
                          const SizedBox(height: 8),
                          const Text("PICK THUMBNAIL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                        ],
                      ) : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildQuizSection(),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDF2FF),
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Return", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _publishCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Publish Course", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F8).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
