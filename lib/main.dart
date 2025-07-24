import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'shared/providers/auth_provider.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'features/auth/presentation/pages/onboarding_screen.dart';
import 'features/customer/presentation/pages/customer_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleSignIn.instance.initialize(
    serverClientId: '980259886387-13ae5l7hpg8ie9mo3alhqluqcgnjpd1g.apps.googleusercontent.com',
  );
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: ArenoExpressApp(),
    ),
  );
}

class ArenoExpressApp extends ConsumerWidget {
  const ArenoExpressApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => SignupScreen(userType: 'customer'),
        '/onboarding': (context) => const OnboardingScreen(),
        '/customer_home': (context) => const CustomerHomeScreen(),
      },
    );
  }
}
