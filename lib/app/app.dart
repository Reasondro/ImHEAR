import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/themes/light_mode.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/chat/data/repositories/supabase_chat_repository.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
import 'package:komunika/features/hear_ai/presentation/cubit/hear_ai_cubit.dart';
import 'package:komunika/features/nearby_officials/data/repositories/supabase_nearby_officials_repository.dart';
import 'package:komunika/features/nearby_officials/domain/repositories/nearby_officials_repository.dart';
import 'package:komunika/features/nearby_officials/presentation/cubit/nearby_officials_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';

//* root widget of the application.
// * sets up the necessary providers (RepositoryProvider, BlocProvider)
//*  and initializes the MaterialApp with GoRouter for navigation.
class App extends StatefulWidget {
  const App({super.key, required this.router, required this.authCubit});
  final GoRouter router;
  final AuthCubit authCubit;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiRepositoryProvider(
      providers: [
        // RepositoryProvider<AuthRepository>(
        //   create: (_) => SupabaseAuthRepository(),
        // ),
        RepositoryProvider<NearbyOfficialsRepository>(
          create: (_) => SupabaseNearbyOfficialsRepository(),
        ),
        RepositoryProvider<ChatRepository>(
          create: (_) => SupabaseChatRepository(),
        ),
        RepositoryProvider<CustomBluetoothService>(
          create: (_) => CustomBluetoothService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BlocProvider<AuthCubit>(
          //   create:
          //       (context) =>
          //           AuthCubit(authRepository: context.read<AuthRepository>()),
          // ),
          BlocProvider<AuthCubit>.value(value: widget.authCubit),
          BlocProvider<UserLocationCubit>(
            create: (context) => UserLocationCubit(),
            //? optional: customize accuracy, distanceFilter, debounceDuration
            //? accuracy: LocationAccuracy.best,
            //? debounceDuration: const Duration(seconds: 2),
          ),

          BlocProvider<NearbyOfficialsCubit>(
            create:
                (context) => NearbyOfficialsCubit(
                  nearbyOfficialRepository:
                      context.read<NearbyOfficialsRepository>(),
                ),
          ),
          BlocProvider<HearAiCubit>(create: (context) => HearAiCubit()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'ImHEAR',
          theme: imHearLightTheme,
          routerConfig: widget.router,
        ),
      ),
    );
  }
}
