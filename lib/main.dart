import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'Pages/splash_screen.dart';
import 'services/auth/auth_service.dart';
import 'services/quiz/quiz_services.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {

  //firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyAUbLddhJlcCTVZa0SHTzg79TGUf-pVTq8',
              appId: "1:235353604058:android:d0988599e6ada44c6b8ae3",
              messagingSenderId: "235353604058",
              projectId: "quiz-app-f9333"))
      : await Firebase.initializeApp();

//notification initialization

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher',); 

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
   
  );

  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider<QuizService>(create: (_) => QuizService()), 
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
