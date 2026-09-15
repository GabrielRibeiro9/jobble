import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_tcc/core/theme/app_theme.dart';
import 'package:flutter_tcc/features/onboard/presentation/pages/intro_page.dart';
import 'package:flutter_tcc/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_bloc.dart';
import 'package:flutter_tcc/core/theme/theme_cubit.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Contratos mostram datas por extenso em português; sem os símbolos
  // carregados, `DateFormat` com locale pt_BR lança em tempo de execução.
  await initializeDateFormatting('pt_BR');

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<ConfigBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Base Brasil',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const IntroPage(),
          );
        },
      ),
    );
  }
}
