import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    debugPrint("========== APP START ==========");

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint("Firebase initialized.");

    final FirebaseAuth auth = FirebaseAuth.instance;

    // Web only
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
      debugPrint("Web persistence enabled.");
    }

    // Anonymous authentication
    if (auth.currentUser == null) {
      debugPrint("Signing in anonymously...");

      await auth.signInAnonymously();

      debugPrint(
        "Anonymous sign-in successful: ${auth.currentUser?.uid}",
      );
    } else {
      debugPrint(
        "Existing user: ${auth.currentUser?.uid}",
      );
    }

    runApp(const HugSpaceApp());
  } on FirebaseAuthException catch (e, st) {
    debugPrint("FirebaseAuthException");
    debugPrint(e.code);
    debugPrint(e.message);
    debugPrintStack(stackTrace: st);

    runApp(ErrorApp(
      title: "Authentication Error",
      message: "${e.code}\n\n${e.message}",
    ));
  } on FirebaseException catch (e, st) {
    debugPrint("FirebaseException");
    debugPrint(e.code);
    debugPrint(e.message);
    debugPrintStack(stackTrace: st);

    runApp(ErrorApp(
      title: "Firebase Error",
      message: "${e.code}\n\n${e.message}",
    ));
  } catch (e, st) {
    debugPrint("Unexpected startup error");
    debugPrint(e.toString());
    debugPrintStack(stackTrace: st);

    runApp(ErrorApp(
      title: "Startup Error",
      message: e.toString(),
    ));
  }
}

class HugSpaceApp extends StatelessWidget {
  const HugSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HugSpace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String title;
  final String message;

  const ErrorApp({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
