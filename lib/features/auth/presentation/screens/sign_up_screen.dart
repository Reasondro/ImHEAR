// features/auth/presentation/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';

// Import GoRouter or your navigation service if you want to wire up the "Sign Up" link
// import 'package:go_router/go_router.dart';
// import 'sign_up_screen.dart'; // Assuming SignUpScreen.routeName
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  // static const String routeName = '/signin'; // For GoRouter

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      context.read<AuthCubit>().signInWithEmail(
        email: email,
        password: password,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Or use AppColors directly

    return Scaffold(
      backgroundColor: AppColors.haiti, // Match Figma
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
          onPressed: () {
            // TODO: context.pop(); if using GoRouter
            // if (Navigator.canPop(context)) Navigator.pop(context);
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Your App Logo/Icon would go well here matching WelcomeScreen style
                // For now, using placeholder from Figma
                // const SizedBox(height: 40),
                Text(
                  'Login.', // Title from Figma
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left, // Match Figma
                ),
                const SizedBox(height: 30),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Input Email', // From Figma
                    hintStyle: TextStyle(
                      color: AppColors.lavender.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.lavender,
                    ),
                    filled: true,
                    fillColor: AppColors.deluge.withOpacity(
                      0.5,
                    ), // Darker input bg
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.deluge, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.columbiaBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    /* ... your email validator ... */
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: AppColors.haiti),
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: 'Enter your password', // From Figma
                    hintStyle: TextStyle(color: AppColors.haiti.withAlpha(122)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.haiti,
                    ),
                    suffixIcon: IconButton(
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.haiti,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.white.withAlpha(122),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.deluge,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.columbiaBlue,
                        width: 2.5,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    /* ... your password validator ... */
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                BlocBuilder<AuthCubit, AuthStates>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            AppColors.bittersweet, // Match Figma button color
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text(
                        'Log In', // From Figma
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Toggle to Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Need an account? ',
                      style: TextStyle(
                        color: AppColors.lavender.withOpacity(0.7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to SignUpScreen
                        // context.pushReplacementNamed(SignUpScreen.routeName, extra: UserRole.deaf_user); // Or via SelectRole first
                        print('Navigate to Sign Up');
                      },
                      child: Text(
                        'Sign Up', // From Figma
                        style: TextStyle(
                          color:
                              AppColors.bittersweet, // Match Figma link color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
