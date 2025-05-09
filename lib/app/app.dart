import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/themes/light_mode.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
import 'package:komunika/features/auth/data/supabase_auth_repository.dart';
import 'package:komunika/features/auth/domain/repositories/auth_repository.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:komunika/features/chat/data/repositories/supabase_chat_repository.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
import 'package:komunika/features/nearby_officials/data/repositories/supabase_nearby_officials_repository.dart';
import 'package:komunika/features/nearby_officials/domain/repositories/nearby_officials_repository.dart';
import 'package:komunika/features/nearby_officials/presentation/cubit/nearby_officials_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => SupabaseAuthRepository(),
        ),
        RepositoryProvider<NearbyOfficialsRepository>(
          create: (_) => SupabaseNearbyOfficialsRepository(),
        ),

        // ? for  chat cubit in dashboard
        RepositoryProvider<ChatRepository>(
          create: (_) => SupabaseChatRepository(),
        ),
        RepositoryProvider<CustomBluetoothService>(
          create: (_) => CustomBluetoothService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserLocationCubit>(
            create: (context) => UserLocationCubit(),
            //* optional: customize accuracy, distanceFilter, debounceDuration
            //* accuracy: LocationAccuracy.best,
            //* debounceDuration: const Duration(seconds: 2),
          ),

          BlocProvider<AuthCubit>(
            create:
                (context) =>
                    AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<NearbyOfficialsCubit>(
            create:
                (context) => NearbyOfficialsCubit(
                  nearbyOfficialRepository:
                      context.read<NearbyOfficialsRepository>(),
                ),
          ),
        ],
        child: MaterialApp(
          title: "Kotaba",
          debugShowCheckedModeBanner: false,
          theme: imHearLightTheme,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
