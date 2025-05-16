import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart'; // Your UserRole enum
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole selectedRole;

  const SignUpScreen({super.key, required this.selectedRole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _organizationNameController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String username = _usernameController.text.trim();
      final String fullName = _fullNameController.text.trim();
      String? organizationName;

      if (widget.selectedRole == UserRole.org_admin) {
        organizationName = _organizationNameController.text.trim();
      }
      context.read<AuthCubit>().signUpWithEmail(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        role: widget.selectedRole,
        organizationName: organizationName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      // extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      // resizeToAvoidBottomInset:
      //     widget.selectedRole == UserRole.org_admin ? true : false,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        // scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.haiti),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is AuthError) {
            context.customShowErrorSnackBar(state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),

          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign Up',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.haiti,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your new account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.haiti,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),

                // ? Username Field
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: AppColors.haiti),
                  decoration: _inputDecoration(
                    labelText: "Username",
                    hintText: 'Create your username',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a username";
                    }
                    if (value.trim().length < 3) {
                      return "Username must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ? Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: AppColors.haiti),
                  decoration: _inputDecoration(
                    labelText: "Full name",
                    hintText: 'Enter your full name',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                //?  Organization Name Field
                if (widget.selectedRole == UserRole.org_admin) ...[
                  TextFormField(
                    controller: _organizationNameController,
                    style: const TextStyle(color: AppColors.haiti),
                    decoration: _inputDecoration(
                      labelText: "Organization name",
                      hintText: 'Enter your organization name',
                      icon: Icons.business_outlined,
                    ),
                    validator: (value) {
                      if (widget.selectedRole == UserRole.org_admin &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter your organization name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                //?  Email Field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.haiti),
                  decoration: _inputDecoration(
                    labelText: "Email",
                    hintText: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ? Password Field
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: AppColors.haiti),
                  decoration: _inputDecoration(
                    labelText: "Password",
                    hintText: 'Create your password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onObscureToggle:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
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
                const SizedBox(height: 20),

                //?  confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  style: const TextStyle(color: AppColors.haiti),
                  decoration: _inputDecoration(
                    labelText: "Confirm password",
                    hintText: 'Confirm your password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onObscureToggle:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // ? submit button
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
                        backgroundColor: AppColors.bittersweet,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ? toggle sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Have an account? ',
                      style: TextStyle(color: AppColors.haiti.withAlpha(179)),
                    ),
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context).goNamed(Routes.signInScreen);
                        // print('Navigate to Sign In');
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.bittersweet,
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
      // ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onObscureToggle,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.haiti.withAlpha(122)),
      prefixIcon: Icon(icon, color: AppColors.haiti),
      suffixIcon:
          isPassword
              ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.haiti,
                ),
                onPressed: onObscureToggle,
              )
              : null,
      filled: true,
      fillColor: AppColors.white.withAlpha(122),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deluge, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.columbiaBlue, width: 2.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.paleCarmine, width: 1.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.paleCarmine, width: 2.3),
      ),
    );
  }
}
