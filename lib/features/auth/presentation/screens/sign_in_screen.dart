import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignInScreenState();
  }
}

class _SignInScreenState extends State<SignInScreen> {
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(body: Column(
  //     children: [
  //       Center(child: Text("Hai")),
  //     ],
  //   ));
  // }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningUp = false; // To toggle between Sign In / Sign Up

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final authCubit = context.read<AuthCubit>();

      if (_isSigningUp) {
        // TODO: Add any extra data if needed for signup
        // Map<String, dynamic> userData = {'username': 'some_username'};
        authCubit.signUp(email, password, "");
      } else {
        authCubit.signIn(email, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        // Listen for errors or other non-UI-blocking states
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
          }
          // Optional: Show message on successful signup needing confirmation
          if (state is AuthUnauthenticated && _isSigningUp) {
            // Check if the previous state was loading to infer signup attempt
            final previousState =
                context
                    .read<AuthCubit>()
                    .state; // Not ideal, better way needed if complex
            // A better approach: Emit a specific state like AuthNeedsConfirmation from Cubit
            // For now, a simple check:
            // if (previousState is AuthLoading) { // Requires tracking previous state or specific signal
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    'Signup successful! Please check your email to confirm.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            //}
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- App Logo/Title (Optional) ---
                  Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isSigningUp ? 'Create Account' : 'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isSigningUp
                        ? 'Enter your details to sign up'
                        : 'Sign in to continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // --- Email Field ---
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

                  // --- Password Field ---
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // TODO: Add suffix icon to toggle password visibility
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- Submit Button ---
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: Text(
                          _isSigningUp ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Toggle Button ---
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSigningUp = !_isSigningUp;
                        // Optionally clear fields or errors when toggling
                        _formKey.currentState
                            ?.reset(); // Reset validation state
                        // context.read<AuthCubit>().emit(AuthInitial()); // Reset error state if desired
                      });
                    },
                    child: Text(
                      _isSigningUp
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  // Optional: Add "Forgot Password?" button later
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
