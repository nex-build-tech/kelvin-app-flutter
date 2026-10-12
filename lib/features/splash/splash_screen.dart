import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/auth/auth_service.dart';
import '../../navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  final AuthService authService;

  const SplashScreen({
    super.key,
    required this.authService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late AnimationController _progressController;

  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // 1. Pulsing Rings Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _ringScale = Tween<double>(begin: 0.85, end: 1.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.65, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // 2. Entrance Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _entranceController.forward();

    // 3. Loading Bar Animation (0 to 65%)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 0.65).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );

    _progressController.forward();

    // Navigation after 2.6s
    Timer(const Duration(milliseconds: 2600), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final targetRoute = widget.authService.isAuthenticated
        ? AppRouter.mainRoute
        : AppRouter.loginRoute;

    Navigator.of(context).pushReplacementNamed(targetRoute);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF07174C),
                  Color(0xFF0F3BB8),
                  Color(0xFF0A2682),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Ambient Background Blobs
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Center Animated Branding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rings & Logo Box
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Pulsing Ring
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _ringScale.value,
                            child: Opacity(
                              opacity: _ringOpacity.value,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Logo Container
                      AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A56DB).withOpacity(0.5),
                                      blurRadius: 28,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.flash_on_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Brand Title & Tagline
                AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          const Text(
                            'Kelvin Mech',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'MEP OPERATIONS PLATFORM',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.68),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Animated Progress Bar
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return Column(
                      children: [
                        Container(
                          width: size.width * 0.52,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressValue.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Loading your workspace...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.48),
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Powered by Ayu Ventures · v1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
