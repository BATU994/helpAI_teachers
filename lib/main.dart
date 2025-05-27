import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';
import 'package:helpai_teachers/features/auth/presentation/forepage.dart';
import 'package:helpai_teachers/firebase_options.dart';
import 'package:helpai_teachers/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // if using FlutterFire CLI
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DataProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FirstAuthorizationPage(),
    );
  }
}
