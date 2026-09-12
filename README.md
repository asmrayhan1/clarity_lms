# Clarity - Modern Learning Management System

Clarity is a comprehensive Flutter-based Learning Management System (LMS) designed to bridge the gap between instructors and students. It offers a seamless experience for course creation, learning, and certification, powered by Supabase for real-time data and authentication.

## 🚀 Purpose of the Project

The primary goal of **Clarity** is to provide an intuitive platform where:
- **Instructors** can easily create, manage, and monetize their courses.
- **Students** can discover high-quality content, track their progress, and earn certificates upon successful completion.

Clarity focuses on a clean UI/UX, personalized learning paths, and robust progress tracking to ensure an engaging educational journey.

---

## ✨ Key Features

### 👤 For Students
- **Personalized Onboarding:** Tailored introduction to the platform's benefits.
- **Course Discovery:** Browse courses by categories or search for specific topics.
- **Rich Media Learning:** Integrated video players supporting both YouTube and local video formats.
- **Interactive Quizzes:** Test knowledge after course completion to qualify for certification.
- **Certification:** Earn and download certificates for completed courses.
- **Learning Dashboard:** Track active courses, completion stats, and learning streaks.
- **Profile Management:** Update bio, profile picture, and view achievements.

### 👨‍🏫 For Instructors
- **Course Creation:** Intuitive flow to upload course content, including thumbnails and videos.
- **Instructor Dashboard:** Monitor total earnings, student enrollment counts, and active courses.
- **Quiz Management:** Create and attach quizzes to courses for student assessment.
- **Student Analytics:** View enrollment statistics across all published courses.

---

## 🛠 Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Dart)
- **Backend-as-a-Service:** [Supabase](https://supabase.com/)
  - **Authentication:** Secure email/password login and signup with custom metadata (roles).
  - **Database:** PostgreSQL for storing courses, enrollments, profiles, and quizzes.
  - **Storage:** Supabase Storage for hosting course videos, thumbnails, and user avatars.
- **Video Playback:** `youtube_player_iframe`, `video_player`, and `chewie`.
- **State Management:** StatefulWidget/setState (Scalable for current scope).
- **Others:** `image_picker`, `screenshot` (for certificates), `share_plus`, `intl`.

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── constants/    # App strings, colors, assets, and API keys
│   ├── models/       # Data models (Course, Quiz, User, etc.)
│   ├── services/     # Logic for Auth, Courses, and Supabase interaction
│   ├── theme/        # Global app styling and colors
│   └── widgets/      # Reusable UI components (Buttons, Cards, Inputs)
├── features/
│   ├── auth/         # Login, Signup, and Role Selection
│   ├── courses/      # Course List, Details, Video Player, and Quiz
│   ├── home/         # Main navigation and Role-based Dashboards
│   ├── onboarding/   # Welcome and Introduction screens
│   └── profile/      # User Profile and Account Settings
└── main.dart         # App entry point and Supabase initialization
```

---

## ⚙️ Setup Instructions

Follow these steps to get the project running locally:

### 1. Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Set up an Android/iOS emulator or connect a physical device.

### 2. Clone the Repository
```bash
git clone <repository-url>
cd clarity
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Supabase Configuration
The project is already configured with a demo Supabase instance. If you wish to use your own:
1. Create a project at [Supabase.com](https://supabase.com/).
2. Set up the required tables (`profiles`, `courses`, `enrollments`, `quizzes`, `quiz_questions`, `quiz_attempts`).
3. Enable Storage buckets: `avatars`, `videos`, `thumbnails`.
4. Update `lib/core/constants/supabase_constants.dart` with your **Project URL** and **Anon Key**.

### 5. Run the App
```bash
flutter run
```

---

## 📝 Roadmap & Future Enhancements
- [ ] **Support Feature:** Currently under processing. Release soon.
- [ ] **Offline Mode:** Capability to download videos for offline viewing.
- [ ] **Push Notifications:** Reminders for learning streaks and new course releases.
- [ ] **Social Integration:** Share certificates directly to LinkedIn/Twitter.

---

## 📄 License
© 2024. All Rights Reserved.

**PERSONAL & PROPRIETARY PROPERTY**

This project is the sole property of the author. It is strictly for personal use and is **NOT** licensed for use, reproduction, distribution, or modification by any other individuals or organizations.
