import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/arenologisticslogo.png',
      'title': 'Welcome to Areno',
      'desc': 'Your trusted partner for seamless logistics and delivery solutions across Tanzania.'
    },
    {
      'image': 'assets/images/poster_placeholder.png',
      'title': 'Fast & Reliable',
      'desc': 'We ensure your packages are delivered quickly and safely, every time.'
    },
    {
      'image': 'assets/images/poster_placeholder.png',
      'title': 'Business & Personal',
      'desc': 'Whether you are a business or an individual, we have tailored solutions for you.'
    },
    {
      'image': 'assets/images/poster_placeholder.png',
      'title': 'Track & Manage',
      'desc': 'Easily track your shipments and manage your deliveries with our modern platform.'
    },
    {
      'image': 'assets/images/poster_placeholder.png',
      'title': 'Areno Movers',
      'desc': 'Areno Movers offers professional moving services for homes and offices. We handle your belongings with care and ensure a smooth relocation experience.'
    },
    {
      'image': 'assets/images/poster_placeholder.png',
      'title': 'Areno Freight',
      'desc': 'Areno Freight provides reliable freight solutions for businesses. Move your goods across cities and borders with our trusted logistics network.'
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.slate900.withOpacity(0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                page['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            page['title']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successGreen,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            page['desc']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.slate700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                  width: _currentPage == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppTheme.successGreen : AppTheme.slate300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text('Skip', style: TextStyle(fontSize: 16)),
                      )
                    else
                      const SizedBox(width: 60),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        } else {
                          _finishOnboarding();
                        }
                      },
                      child: Text(_currentPage < _pages.length - 1 ? 'Continue' : 'Get Started'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 