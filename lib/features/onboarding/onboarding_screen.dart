import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../auth/signup_screen.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              /// 🔹 Top Image
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  AppAssets.onboardingImage,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 32),

              /// 🔹 Title
              Text(
                AppStrings.welcomeTitle,
                style: const TextStyle(
                  letterSpacing: 2,
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.tagLine,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              /// 🔹 Buttons
              CustomButton(
                text: AppStrings.signUp,
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              CustomButton(
                text: AppStrings.login,
                isPrimary: false,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Text(
                AppStrings.startJourney,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black26,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔹 Feature Cards
              _buildFeatureCards(),

              const SizedBox(height: 40),

              /// 🔹 Footer
              _buildFooter(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Feature Section
  Widget _buildFeatureCards() {
    return Column(
      children: [
        /// Personalized Paths
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.personalizedPaths,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.personalizedPathsDesc,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppStrings.exploreCurriculum,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_right_alt, color: AppColors.primary, size: 18),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        /// Trusted Experts (Blue)
        CustomCard(
          isBlue: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user, color: Colors.white, size: 28),
              const SizedBox(height: 16),
              Text(
                AppStrings.trustedExperts,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.trustedExpertsDesc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        /// Weekly Digest
        CustomCard(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  AppAssets.learningImage,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.weeklyDigest,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.weeklyDigestDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink(AppStrings.privacy),
            _footerDivider(),
            _footerLink(AppStrings.terms),
            _footerDivider(),
            _footerLink(AppStrings.contact),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.copyright,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _footerDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text("|", style: TextStyle(color: Colors.black12)),
    );
  }
}