class Course {
  final String id;
  final String title;
  final String? description;
  final String instructorId;
  final String? thumbnailUrl;
  final String? videoUrl; // Added videoUrl
  final String category;
  final double price;
  final String level;
  final String duration;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    this.description,
    required this.instructorId,
    this.thumbnailUrl,
    this.videoUrl,
    required this.category,
    required this.price,
    required this.level,
    required this.duration,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      instructorId: json['instructor_id'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'], // Added videoUrl mapping
      category: json['category'] ?? 'General',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      level: json['level'] ?? 'Beginner',
      duration: json['duration']?.toString() ?? 'Self-paced',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl, // Added videoUrl
      'category': category,
      'price': price,
      'level': level,
      'duration': duration,
    };
  }
}
