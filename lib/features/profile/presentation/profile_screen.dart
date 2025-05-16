import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/features/auth/domain/entities/app_user.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;

  //? more secure if for some reason user is null inside the app
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();

    final AuthStates authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
      _usernameController = TextEditingController(
        text: _currentUser?.username ?? "",
      );
      _fullNameController = TextEditingController(
        text: _currentUser?.fullName ?? "",
      );
      _emailController = TextEditingController(text: _currentUser?.email ?? "");
    } else {
      // ? SHOULD NOT HAPPEN but just in case
      _usernameController = TextEditingController();
      _fullNameController = TextEditingController();
      _fullNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: call AuthCubit to update user profile

      // final String newUsername = _usernameController.text.trim();
      // final String newFullName = _fullNameController.text.trim();
      // final String newEmail = _emailController.text.trim(); //! hope this doesn't go in prototyping--> hard to implement

      // print("Save Changes Clicked!");
      context.customShowSnackBar("Profile update functionality padding.");
    }
  }

  Widget _buildInfoField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = false, //? make fields read-only initially
  }) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.haiti.withAlpha(204)),
        prefixIcon: Icon(icon, color: AppColors.deluge),
        filled: true,
        suffixIcon:
            (isEmail || isPassword)
                ? null
                : IconButton(
                  onPressed: () {
                    // print(enabled);
                    setState(() {
                      enabled = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
        fillColor: Colors.grey.withAlpha(50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.deluge.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.haiti.withAlpha(122),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.columbiaBlue.withAlpha(122),
            width: 2.5,
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
            width: 2.3,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.deluge.withAlpha(77)),
        ),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
    );
    // );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    context.watch<AuthCubit>(); //? esnrues rebuildif AuthStates chagnes
    return _currentUser == null
        ? const Center(child: CircularProgressIndicator()) //? or error
        : Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              // top: 12.0,
              top: 0.0,
              bottom: 8.0,
              left: 24.0,
              right: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ? header with name
                  Text(
                    _currentUser!.fullName.isNotEmpty
                        ? _currentUser!.fullName
                        : _currentUser!.username,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.haiti,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.deluge,
                    child:
                        _currentUser!.avatarUrl == null ||
                                _currentUser!.avatarUrl!.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.lavender.withAlpha(179),
                            )
                            : null, //? use image at some point
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // TODO: implmeent change profile picture
                      // print("Change Profile Picture clicked");
                    },
                    child: Text(
                      "Change Profile Picture",
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.bittersweet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoField(
                    context: context,
                    controller: _usernameController,
                    label: "Username",
                    icon: Icons.person_outlined,
                    // enabled: false
                    validator:
                        (value) =>
                            value!.isEmpty ? "Username cannot be empty" : null,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoField(
                    context: context,
                    controller: _fullNameController,
                    label: "Full Name",
                    icon: Icons.badge_outlined,
                    // enabled: false,
                    validator:
                        (value) =>
                            value!.isEmpty ? "Full name cannot be empty" : null,
                  ),
                  const SizedBox(height: 10),

                  _buildInfoField(
                    context: context,
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    enabled: false, //? email not editable directly
                    isEmail: true,
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
                  const SizedBox(height: 10),

                  _buildInfoField(
                    context: context,
                    controller: TextEditingController(text: "••••••••••"),
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    enabled: false, //? change via seperate flow
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.haiti,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Save Changes",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        // side: const BorderSide(color: AppColors.deluge),
                        backgroundColor: AppColors.paleCarmine,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Sign Out",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    // Center(
    //   child: ElevatedButton(
    //     onPressed: () {
    //       context.read<AuthCubit>().signOut();
    //     },
    //     child: const Icon(Icons.logout),
    //   ),
    // );
  }
}
