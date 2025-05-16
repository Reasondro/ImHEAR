import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/app.dart';
import 'package:komunika/app/routing/routing_service.dart';
import 'package:komunika/features/auth/data/supabase_auth_repository.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Replace all print screen (currently commented out) in ALL the files in the codebase with a logging framework

//? main entry point of the  application.
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_PROJECT_URL"]!,
    anonKey: dotenv.env["SUPABASE_API_KEY"]!,
  );

  // ? create AuthRepository and AuthCubit instance in the top level
  final SupabaseAuthRepository authRepository = SupabaseAuthRepository();
  final AuthCubit authCubit = AuthCubit(authRepository: authRepository);

  // ? pass AuthCubit to RoutingService
  GoRouter router = RoutingService(authCubit: authCubit).router;

  // ? pass AuthCubit to App iteslef
  runApp(App(router: router, authCubit: authCubit));
}
