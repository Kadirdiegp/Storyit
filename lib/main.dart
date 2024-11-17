import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/storage_service.dart';
import 'models/story.dart';
import 'pages/onboarding_page.dart';
import 'pages/main_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storageService = await StorageService.init();

  // Debug: Reset Storage zum Testen des Onboardings
  await storageService.reset(); // Diese Zeile zum Testen hinzugefügt

  final apiKey = storageService.getApiKey();
  if (apiKey != null) {
    Story.setApiKey(apiKey);
  }

  runApp(StoryItApp(
    storageService: storageService,
  ));
}

class StoryItApp extends StatelessWidget {
  final StorageService storageService;

  const StoryItApp({
    Key? key,
    required this.storageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasCompletedOnboarding = storageService.hasCompletedOnboarding();

    return MaterialApp(
      title: 'StoryIt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: hasCompletedOnboarding ? '/' : '/onboarding',
      routes: {
        '/': (context) => MainPage(storageService: storageService),
        '/onboarding': (context) =>
            OnboardingPage(storageService: storageService),
        '/profile': (context) => ProfilePage(storageService: storageService),
      },
    );
  }
}
