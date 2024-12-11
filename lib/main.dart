import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterlaravelapitodo241211/controllers/auth_controller.dart';
import 'package:flutterlaravelapitodo241211/controllers/todo_controller.dart';
import 'package:flutterlaravelapitodo241211/screends/login_screen.dart';
import 'package:flutterlaravelapitodo241211/screends/register_screen.dart';
import 'package:flutterlaravelapitodo241211/screends/todo_screen.dart';
import 'package:flutterlaravelapitodo241211/services/api_service.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  //pubspec.yaml에 사용하도록 지정해야한다.
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final apiService = Get.put(ApiService());
  final authController = Get.put(AuthController());
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/todos', page: () => const TodoScreen()),
      ],
      home: FutureBuilder<bool>(
        future: apiService.hasValidToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!) {
            return const TodoScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
