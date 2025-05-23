// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:komunika/core/extensions/snackbar_extension.dart';
// import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
// import 'package:komunika/features/auth/presentation/screens/auth_screen.dart';
// import 'package:komunika/features/dashboard/presentation/screens/deaf_user_dashboard_screen.dart';

// ! not needed anymore as already being handled by GoRouter
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthCubit, AuthStates>(
//       builder: (_, authState) {
//         // print("AuthWrapper building with state $authState");
//         if (authState is AuthAuthenticated)
//         //? authenticated
//         {
//           return const DeafUserDashboardScreen();
//         } else if (authState is AuthUnauthenticated ||
//             authState is AuthLoading ||
//             authState is AuthError
//         // ||authState is AuthInitial
//         )
//         //? authenticating
//         {
//           return const AuthScreen();
//         } else
//         // ? unknown stuffs / errors
//         {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(),
//                   Text("$authState"),
//                 ],
//               ),
//             ),
//           );
//         }
//       },
//       listener: (ctx, state) {
//         if (state is AuthError) {
//           ctx.customShowErrorSnackBar(state.message);
//         }
//       },
//     );
//   }
// }
