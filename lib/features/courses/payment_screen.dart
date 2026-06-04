import 'package:flutter/material.dart';
import '../../core/services/course_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const PaymentScreen({super.key, required this.courseData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _courseService = CourseService();
  bool _isProcessing = false;

  /// Extracts YouTube thumbnail if the URL is a video link, otherwise returns the URL.
  String _getThumbnail(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400';
    }
    
    // Improved YouTube ID extraction regex
    final regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final videoId = match.group(1);
      // hqdefault is reliable across most videos
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return url;
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    try {
      await _courseService.enrollUser(widget.courseData['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enrollment Successful! Welcome to the course."),
            backgroundColor: Color(0xFF0052CC),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Pop payment and details to go back to course list/home
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = "Enrollment failed. Please try again.";
      final errStr = e.toString().toLowerCase();
      
      if (errStr.contains("unique") || errStr.contains("already enrolled")) {
        errorMessage = "You are already enrolled in this course!";
      } else if (errStr.contains("row-level security") || errStr.contains("rls") || errStr.contains("permission")) {
        errorMessage = "Access Denied: Please ensure the 'enrollments' table has an INSERT policy for authenticated users.";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    final double horizontalPadding = screenSize.width * 0.06;

    final title = widget.courseData['title'] ?? "Untitled Course";
    final price = double.tryParse(widget.courseData['price']?.toString() ?? "0") ?? 0.0;
    final instructor = widget.courseData['profiles']?['full_name'] ?? "Expert Instructor";
    final category = widget.courseData['category'] ?? "General";
    final thumbnailUrl = _getThumbnail(widget.courseData['thumbnail_url']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E3A8A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Checkout",
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              Row(
                children: [
                  _buildBreadcrumb("ENROLL", false),
                  _buildArrow(),
                  _buildBreadcrumb("PAYMENT", true),
                  _buildArrow(),
                  _buildBreadcrumb("SUCCESS", false),
                ],
              ),
              SizedBox(height: screenSize.height * 0.03),
              Text(
                "Complete your\nenrollment.",
                style: TextStyle(
                  fontSize: isTablet ? 42 : 34,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You're one step away from unlocking premium content and professional growth.",
                style: TextStyle(color: Colors.black54, height: 1.5, fontSize: 14),
              ),
              SizedBox(height: screenSize.height * 0.04),

              // Course Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        thumbnailUrl,
                        width: screenSize.width * 0.22,
                        height: screenSize.width * 0.22,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: screenSize.width * 0.22,
                          height: screenSize.width * 0.22,
                          color: const Color(0xFFEDE9FE),
                          child: const Icon(Icons.image_not_supported, color: Colors.deepPurple),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.deepPurple,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: isTablet ? 18 : 16,
                              color: const Color(0xFF1E3A8A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.black38),
                              const SizedBox(width: 4),
                              Text(
                                instructor, 
                                style: const TextStyle(fontSize: 12, color: Colors.black45),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildTrustItem(Icons.verified_user_outlined, "SECURE 256-BIT ENCRYPTION"),
              const SizedBox(height: 12),
              _buildTrustItem(Icons.card_membership_outlined, "LIFETIME CONTENT ACCESS"),

              SizedBox(height: screenSize.height * 0.04),

              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 24),
                    _buildSummaryRow("Course Price", "\$${price.toStringAsFixed(2)}"),
                    const Divider(height: 32, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "\$${price.toStringAsFixed(2)}", 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 26, 
                            color: Color(0xFF0052CC),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: _isProcessing 
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Confirm & Enroll", 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(String text, bool active) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: active ? const Color(0xFF1E3A8A) : Colors.black26,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Icon(Icons.chevron_right, size: 16, color: Colors.black12),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE).withOpacity(0.5), 
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.deepPurple),
        ),
        const SizedBox(width: 12),
        Text(
          text, 
          style: const TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.w700, 
            color: Colors.black54, 
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
