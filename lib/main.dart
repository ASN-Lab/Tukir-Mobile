import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_colors.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/garage_cubit.dart';
import 'repositories/auth_repository.dart';
import 'repositories/device_repository.dart';
import 'screens/login_screen.dart';
import 'screens/garage_control_screen.dart';

void main() {
  runApp(const TukirApp());
}

class TukirApp extends StatelessWidget {
  const TukirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepository())..tryRestoreSession()),
      ],
      child: MaterialApp(
        title: 'Tukir.ID',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(AppColors.background),
          appBarTheme: AppBarTheme(backgroundColor: Color(AppColors.surface)),
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return BlocProvider(
                create: (_) => GarageCubit(DeviceRepository(state.accessToken)),
                child: GarageControlScreen(),
              );
            }
            return LoginScreen();
          },
        ),
        routes: {
          '/garage': (context) => BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return BlocProvider(
                      create: (_) => GarageCubit(DeviceRepository(state.accessToken)),
                      child: GarageControlScreen(),
                    );
                  }
                  return LoginScreen();
                },
              ),
        },
      ),
    );
  }
}
