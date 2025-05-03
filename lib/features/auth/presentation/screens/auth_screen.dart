import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSigningUp = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  UserRole _selectedRole = UserRole.deaf_user; //? default value just in case
  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      final AuthCubit authCubit = context.read<AuthCubit>();

      if (_isSigningUp) {
        final String username = _usernameController.text.trim();
        final String fullName = _fullNameController.text.trim();
        authCubit.signUpWithEmail(
          email: email,
          password: password,
          username: username,
          fullName: fullName,
          role: _selectedRole,
        );
      } else {
        authCubit.signInWithEmail(email: email, password: password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //? --- app Logo/Title nanti ---
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

                //? only when sigining up

                // ?username field
                if (_isSigningUp) ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (_isSigningUp && (value == null || value.isEmpty)) {
                        return "Please enter a username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  //? full name field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (_isSigningUp && (value == null || value.isEmpty)) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  //? role dropdown
                  DropdownButtonFormField<UserRole>(
                    value: UserRole.deaf_user, //? deafult
                    decoration: InputDecoration(
                      labelText: "User Type",
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        UserRole.values.map((UserRole role) {
                          // String displayName =
                          //     role == UserRole.deaf_user
                          //         ? "Deaf User"
                          //         : "Officials";

                          late String displayName;
                          if (role == UserRole.deaf_user) {
                            displayName = "Deaf User";
                          } else if (role == UserRole.official) {
                            displayName = "Officials";
                          } else if (role == UserRole.org_admin) {
                            displayName = "Org Admin";
                          }
                          return DropdownMenuItem<UserRole>(
                            value: role,
                            child: Text(displayName),
                          );
                        }).toList(),
                    onChanged: (UserRole? newValue) {
                      setState(() {
                        _selectedRole = newValue ?? UserRole.deaf_user;
                        print(_selectedRole.name);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // ? role dropdown

                //?--- email field ---
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

                //? --- password  field ---
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                //? confirm password field --
                if (_isSigningUp)
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (_isSigningUp) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 30),

                // ?--- submit Button ---
                BlocBuilder<AuthCubit, AuthStates>(
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Text(
                      _isSigningUp
                          ? 'Already have an account?'
                          : 'Don\'t have an account?',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    //? --- change auth type button ---
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSigningUp = !_isSigningUp;
                          _formKey.currentState
                              ?.reset(); //? reset validation state
                          _usernameController.clear();
                          _fullNameController.clear();
                          _emailController.clear();

                          _passwordController.clear();
                          _confirmPasswordController.clear();
                          _obscurePassword = true;
                          _obscureConfirmPassword = true;
                        });
                      },
                      child: Text(
                        _isSigningUp ? 'Sign In' : 'Sign up',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    //? todo  "Forgot Password?" button later
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
}
