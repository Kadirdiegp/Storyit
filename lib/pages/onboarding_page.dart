import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/story.dart';
import 'main_page.dart';

class OnboardingPage extends StatefulWidget {
  final StorageService storageService;

  const OnboardingPage({Key? key, required this.storageService})
      : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _animationController;
  bool _isLoading = false;
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.eco,
      title: 'Nachhaltig & Digital',
      description:
          'Spare Papier und schone die Umwelt: Unbegrenzt neue Geschichten ohne Ressourcenverbrauch.',
      backgroundColor: Color(0xFF4CAF50),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      ),
    ),
    OnboardingStep(
      icon: Icons.auto_stories,
      title: 'Magische Geschichten',
      description:
          'Erschaffe einzigartige Geschichten, die dein Kind verzaubern werden.',
      backgroundColor: Color(0xFF6C63FF),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6C63FF), Color(0xFF4B45FF)],
      ),
    ),
    OnboardingStep(
      icon: Icons.psychology,
      title: 'Perfekt angepasst',
      description:
          'Jede Geschichte wird speziell für das Alter deines Kindes geschrieben.',
      backgroundColor: Color(0xFF9C27B0),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      ),
    ),
    OnboardingStep(
      icon: Icons.auto_awesome,
      title: 'Willkommen bei Story.it',
      description:
          'Für nur 4,99€ im Monat:\n✓ Unbegrenzt neue Geschichten\n✓ Personalisiert für dein Kind\n✓ 100% nachhaltig & digital',
      backgroundColor: Color(0xFF2196F3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.forward(from: 0);
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      const apiKey = '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';
      await widget.storageService.setApiKey(apiKey);
      await widget.storageService.completeOnboarding();
      Story.setApiKey(apiKey);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Starten der App')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          return _buildPage(_steps[index]);
        },
      ),
    );
  }

  Widget _buildPage(OnboardingStep step) {
    return Container(
      decoration: BoxDecoration(
        gradient: step.gradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentPage == 0) ...[
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 200,
                          height: 200,
                        ),
                      ],
                      const SizedBox(height: 40),
                      Icon(
                        step.icon,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        step.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        step.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildNavigationButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              'Zurück',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          SizedBox(width: 80),
        if (_currentPage < _steps.length - 1)
          ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _steps[_currentPage].backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Weiter'),
          )
        else
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _steps[_currentPage].backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _steps[_currentPage].backgroundColor,
                      ),
                    ),
                  )
                : Text('Los geht\'s'),
          ),
      ],
    );
  }
}

class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final LinearGradient gradient;

  OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.gradient,
  });
}
