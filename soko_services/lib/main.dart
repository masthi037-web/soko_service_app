import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'app/data/providers/api_provider.dart';
import 'app/data/services/api_service.dart';
import 'app/data/repositories/store_repository.dart';
import 'app/data/repositories/auth_repository.dart';
import 'app/data/services/store_service.dart';
import 'app/controllers/home_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/views/auth/login_page.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiProvider()),
        ProxyProvider<ApiProvider, ApiService>(
          update: (_, apiProvider, __) => ApiService(apiProvider),
        ),
        // Repositories
        ProxyProvider<ApiService, StoreRepository>(
          update: (_, apiService, __) => StoreRepository(apiService),
        ),
        ProxyProvider<ApiService, AuthRepository>(
          update: (_, apiService, __) => AuthRepository(apiService),
        ),
        // Services
        ProxyProvider<StoreRepository, StoreService>(
          update: (_, repository, __) => StoreService(repository),
        ),
        // Controllers
        ChangeNotifierProxyProvider<StoreService, HomeController>(
          create: (context) => HomeController(context.read<StoreService>()),
          update: (_, service, previous) => HomeController(service),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthController>(
          create: (context) => AuthController(context.read<AuthRepository>()),
          update: (_, repo, previous) => AuthController(repo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Soko Services',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const LoginPage(), // Set LoginPage as home for now
      ),
    );
  }
}
