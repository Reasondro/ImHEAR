// features/auth/presentation/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';

// Import GoRouter or your navigation service if you want to wire up the "Sign Up" link
// import 'package:go_router/go_router.dart';
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white, // Match Figma
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.haiti),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 190,
                alignment: Alignment.center,
                child: Image.asset("assets/images/ImHEAR.png"),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign In', // Title from Figma
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.haiti,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left, // Match Figma
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.haiti),
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: 'Enter your email', // From Figma
                  hintStyle: TextStyle(
                    // color: AppColors.lavender.withAlpha(122),
                    color: AppColors.haiti.withAlpha(122),
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.haiti,
                  ),
                  filled: true,
                  fillColor: AppColors.white.withAlpha(122), // Darker input bg
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.deluge,
                      width: 1.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.columbiaBlue,
                      width: 2.3,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.paleCarmine,
                      width: 1.8,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.paleCarmine,
                      width: 1.8,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
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
                      width: 1.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.columbiaBlue,
                      width: 2.3,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.paleCarmine,
                      width: 1.8,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.paleCarmine,
                      width: 1.8,
                    ),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

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
                          AppColors.haiti, // Match Figma button color
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text(
                      'Sign In', // From Figma
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Toggle to Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need an account? ',
                    style: TextStyle(color: AppColors.haiti.withAlpha(179)),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO add routes to sign up screen
                      // GoRouter.of(context).pushReplacemen(SignUpScreen.routeName, extra: UserRole.deaf_user); // Or via SelectRole first
                      print('Navigate to Sign Up');
                    },
                    child: const Text(
                      'Sign Up', // From Figma
                      style: TextStyle(
                        color: AppColors.bittersweet, // Match Figma link color
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
      // ),
    );
  }
}
