// features/onboarding/presentation/screens/select_role_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/themes/app_colors.dart';
// Import your RoleSelectionCard widget (create this next)
import 'package:komunika/features/onboarding/presentation/widgets/role_selection_card.dart';
// Import your UserRole enum if you want to pass it
// import 'package:komunika/features/auth/domain/entities/user_role.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  // Define a route name for GoRouter
  // static const String routeName = '/select-role';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.haiti,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Or AppColors.haiti
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
          onPressed: () {
            GoRouter.of(context).pop();
            print("Back button pressed");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Select your Role",
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.bittersweet,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Role Selection Cards
            RoleSelectionCard(
              roleName: "Mimi's Friend", // Or "User with Disability"
              roleDescription:
                  "Lorem ipsum Lorem ipsumLorem ipsumLorem ipsumLorem ipsum ",

              imageAssetPath: 'assets/images/Mascot - 5.png',
              onTap: () {
                // TODO: Handle role selection, pass UserRole.deaf_user
                // context.pushNamed(SignupFormScreen.routeName, extra: UserRole.deaf_user);
                print("Selected Disabled User");
              },
            ),
            const SizedBox(height: 20),
            RoleSelectionCard(
              roleName: "Mimi's Admin",
              roleDescription:
                  "Lorem ipsum Lorem ipsumLorem ipsumLorem ipsumLorem ipsum ",
              imageAssetPath: 'assets/images/Mascot - 3.png',
              onTap: () {
                // TODO: Handle role selection, pass UserRole.org_admin
                print("Selected Organization Admin");
              },
            ),
            const SizedBox(height: 20),
            RoleSelectionCard(
              roleName: "Mimi's Helper", // Or "Employee"
              roleDescription:
                  "Lorem ipsum Lorem ipsumLorem ipsumLorem ipsumLorem ipsum ",

              imageAssetPath: 'assets/images/Mascot - 4.png',
              onTap: () {
                // TODO: Handle role selection, pass UserRole.official
                print("Selected Official Staff");
              },
            ),
            const Spacer(), // Pushes content to top if Column height is more than content
          ],
        ),
      ),
    );
  }
}
