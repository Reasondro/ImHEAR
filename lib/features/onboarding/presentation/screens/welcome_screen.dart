import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/app/themes/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.haiti,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              Container(
                height: 300,
                alignment: Alignment.center,
                child: Image.asset("assets/images/Mascot - 2.png"),
              ),
              const SizedBox(height: 40),
              Text(
                'Need Help ?',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.bittersweet,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Don\'t worry! This app makes\ncommunication easy',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.white.withAlpha(230),
                ),
              ),
              const SizedBox(height: 30),

              // TODO: Page Indicators - Placeholder for now
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Colors.white24, size: 10),
                  SizedBox(width: 8),
                  Icon(Icons.circle, color: Colors.white, size: 10), // Active
                  SizedBox(width: 8),
                  Icon(Icons.circle, color: Colors.white24, size: 10),
                ],
              ),
              const Spacer(flex: 3),

              // Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.haiti, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
                onPressed: () {
                  // TODO: Navigate to Select Role Screen or Sign Up Flow
                  GoRouter.of(context).goNamed(Routes.selectRoleScreen);
                  print('Get Started Clicked!');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 28),
                    Text('Get Started', style: TextStyle(fontSize: 18)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 24),
                    SizedBox(width: 28),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Log In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withAlpha(204),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).goNamed(Routes.signInScreen);
                      print('Sign In Clicked!');
                    },
                    child: Text(
                      'Sign In',
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            AppColors
                                .columbiaBlue, // Or a specific blue from Figma
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
