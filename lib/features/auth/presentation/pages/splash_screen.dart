import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../customer/presentation/pages/customer_home_screen.dart';
import '../../../driver/presentation/pages/driver_home_screen.dart';
import '../../../agent/presentation/pages/agent_home_screen.dart';
import '../../../supervisor/presentation/pages/supervisor_home_screen.dart';
import 'user_type_selection_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
    final authState = ref.read(authProvider);
    
    if (authState.user != null) {
      // User is logged in, navigate based on user type
      switch (authState.userType) {
        case 'customer':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
          );
          break;
        case 'driver':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          );
          break;
        case 'agent':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AgentHomeScreen()),
          );
          break;
        case 'supervisor':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SupervisorHomeScreen()),
          );
          break;
        default:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
      }
    } else {
      // User is not logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const UserTypeSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.slate900.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/arenologisticslogo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // App Name
                      Text(
                        'Areno Express',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tagline
                      Text(
                        'Logistics Management',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slate600,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Loading Indicator
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
