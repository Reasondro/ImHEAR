import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/themes/light_mode.dart';
import 'package:komunika/features/auth/data/supabase_auth_repository.dart';
import 'package:komunika/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:komunika/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:komunika/features/nearby_officials/data/repositories/supabase_nearby_officials_repository.dart';
import 'package:komunika/features/nearby_officials/presentation/cubit/nearby_officials_cubit.dart';
import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';

class App extends StatelessWidget {
  App({super.key});
  final SupabaseAuthRepository authRepository = SupabaseAuthRepository();
  final SupabaseNearbyOfficialsRepository nearbyOfficialsRepository =
      SupabaseNearbyOfficialsRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserLocationCubit>(
          create: (_) => UserLocationCubit(),
          //* optional: customize accuracy, distanceFilter, debounceDuration
          //* accuracy: LocationAccuracy.best,
          //* debounceDuration: const Duration(seconds: 2),
        ),

        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository: authRepository),
        ),
        BlocProvider<NearbyOfficialsCubit>(
          create:
              (_) => NearbyOfficialsCubit(
                nearbyOfficialRepository: nearbyOfficialsRepository,
              ),
        ),
      ],
      child: MaterialApp(
        title: "Kotaba",
        debugShowCheckedModeBanner: false,
        theme: kotabaLightTheme,
        home: AuthWrapper(),
      ),
    );
  }
}
