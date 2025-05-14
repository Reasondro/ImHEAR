import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/routing/routes.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/features/auth/domain/entities/user_role.dart';
import 'package:komunika/features/onboarding/presentation/widgets/role_selection_card.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.haiti,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              "Select Your Role",
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.bittersweet,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            //? role selection cards
            RoleSelectionCard(
              roleName: "Mimi's Friend", //? or "User with Disability"
              roleDescription:
                  "For individuals seeking assistance & connection. Communicate effectively and get the support you need.",

              imageAssetPath: 'assets/images/Mascot - 5.png',
              onTap: () {
                GoRouter.of(
                  context,
                ).goNamed(Routes.signUpScreen, extra: UserRole.deaf_user);
                print("Selected Disabled User");
              },
            ),
            const SizedBox(height: 20),
            RoleSelectionCard(
              roleName: "Mimi's Admin",
              roleDescription:
                  "Manage organization's presence. Create and oversee dedicated subspaces for seamless communication.",
              imageAssetPath: 'assets/images/Mascot - 3.png',
              onTap: () {
                GoRouter.of(
                  context,
                ).goNamed(Routes.signUpScreen, extra: UserRole.org_admin);
                print("Selected Organization Admin");
              },
            ),
            const SizedBox(height: 20),
            RoleSelectionCard(
              roleName: "Mimi's Helper", //? or "Employee"
              roleDescription:
                  "Provide direct support and assistance to users within your organization's dedicated subspaces.",

              imageAssetPath: 'assets/images/Mascot - 4.png',
              onTap: () {
                GoRouter.of(
                  context,
                ).goNamed(Routes.signUpScreen, extra: UserRole.official);
                print("Selected Official Staff");
              },
            ),
            const Spacer(), //?  pushes content to top if Column height is more than content
          ],
        ),
      ),
    );
  }
}
