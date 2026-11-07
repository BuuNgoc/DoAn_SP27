import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/network/connectivity_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/destination_discovery/presentation/bloc/destination_cubits.dart';
import 'features/qr_checkin_loyalty/presentation/bloc/loyalty_cubit.dart';

/// Widget gốc: cung cấp các Cubit toàn cục, Router và Theme Ice-Mint.
class SmartTravelApp extends StatefulWidget {
  const SmartTravelApp({super.key});

  @override
  State<SmartTravelApp> createState() => _SmartTravelAppState();
}

class _SmartTravelAppState extends State<SmartTravelApp> {
  late final AuthCubit _auth = sl<AuthCubit>();
  late final GoRouter _router = AppRouter.create(_auth);

  @override
  void initState() {
    super.initState();
    _auth.checkSession();
    sl<FavoritesCubit>().load();
    sl<LoyaltyCubit>().load(null);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _auth),
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<FavoritesCubit>()),
        BlocProvider.value(value: sl<LoyaltyCubit>()),
        BlocProvider.value(value: sl<ConnectivityCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (a, b) => a.user?.uid != b.user?.uid,
        // Đăng nhập / đăng xuất → tải lại điểm thưởng, lịch sử check-in theo tài khoản.
        listener: (context, state) => context.read<LoyaltyCubit>().load(state.user?.uid),
        child: MaterialApp.router(
          title: 'SmartTravel – Ngũ Hành Sơn',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
