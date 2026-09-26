import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/app_repository.dart';
import 'presentation/cubits/app_data_cubit.dart';
import 'presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const StreetPayApp());
}

class StreetPayApp extends StatelessWidget {
  /// Injectable so tests can supply an in-memory repository instead of the
  /// real Hive-backed one, which needs platform plugins unavailable in the
  /// widget test environment.
  final AppRepository? repository;

  const StreetPayApp({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppDataCubit(repository ?? AppRepository())..load(),
      child: MaterialApp(
        title: 'StreetPay NG',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const DashboardPage(),
      ),
    );
  }
}
