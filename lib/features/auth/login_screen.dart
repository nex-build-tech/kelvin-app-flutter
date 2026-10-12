import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/app_button.dart';
import '../../components/app_text_field.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/validators.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _showDemoHints = false;
  String? _errorMessage;

  static const List<Map<String, String>> _demoAccounts = [
    {
      'role': 'Procurement Manager',
      'name': 'Suresh Iyer',
      'email': 'suresh@kelvinmech.com',
      'password': 'kelvin123',
    },
    {
      'role': 'Project Manager',
      'name': 'Priya Shah',
      'email': 'priya@kelvinmech.com',
      'password': 'kelvin123',
    },
    {
      'role': 'Admin / Architect',
      'name': 'Sachin G',
      'email': 'admin@kelvinmech.com',
      'password': 'admin123',
    },
    {
      'role': 'Demo Viewer',
      'name': 'Demo User',
      'email': 'demo@kelvinmech.com',
      'password': 'demo',
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  void _fillAccount(Map<String, String> account) {
    HapticFeedback.lightImpact();
    setState(() {
      _emailController.text = account['email']!;
      _passwordController.text = account['password']!;
      _errorMessage = null;
      _showDemoHints = false;
    });
  }

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }

    final error = await widget.authService.login(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (error != null) {
      HapticFeedback.heavyImpact();
      _triggerShake();
      setState(() {
        _errorMessage = error;
      });
    } else {
      widget.onLoginSuccess();
    }
  }

  Future<void> _handleGoogleLogin() async {
    HapticFeedback.lightImpact();
    await widget.authService.loginWithGoogle();
    if (!mounted) return;
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF071233) : const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background Gradient Blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1A56DB).withOpacity(isDark ? 0.35 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withOpacity(isDark ? 0.25 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.md,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Header
                      _buildBrandHeader(isDark),
                      const SizedBox(height: 28),

                      // Animated Shake Wrapper for Login Card
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          final offset = sin(_shakeAnimation.value * pi * 4) * 8 * (1.0 - _shakeAnimation.value);
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF111D3C) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E2F5B) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sign in to your HVAC operations workspace',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Error Banner
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFFECACA)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: Color(0xFFB91C1C),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Email Input
                                AppTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hint: 'suresh@kelvinmech.com',
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: AppValidators.validateEmail,
                                  prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF1A56DB)),
                                  onChanged: (_) {
                                    if (_errorMessage != null) setState(() => _errorMessage = null);
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password Input
                                AppTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: '••••••••',
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleLogin(),
                                  validator: AppValidators.validatePassword,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF1A56DB)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  onChanged: (_) {
                                    if (_errorMessage != null) setState(() => _errorMessage = null);
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Remember Me
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF1A56DB),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Sign In Button
                                ListenableBuilder(
                                  listenable: widget.authService,
                                  builder: (context, _) {
                                    return AppButton(
                                      text: 'Sign In',
                                      icon: Icons.login_rounded,
                                      isLoading: widget.authService.isLoading,
                                      onPressed: _handleLogin,
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[300])),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'or continue with',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[300])),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Google Sign In Button
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    side: BorderSide(color: isDark ? const Color(0xFF2E3F6D) : Colors.grey[300]!),
                                    backgroundColor: isDark ? const Color(0xFF131F42) : Colors.white,
                                  ),
                                  onPressed: _handleGoogleLogin,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEA4335),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'G',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          'Sign in with Google',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Expandable Demo Accounts Drawer
                                InkWell(
                                  onTap: () => setState(() => _showDemoHints = !_showDemoHints),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF1A56DB)),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Use a demo account',
                                          style: TextStyle(
                                            color: Color(0xFF1A56DB),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _showDemoHints ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          size: 16,
                                          color: const Color(0xFF1A56DB),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Demo Accounts List
                                if (_showDemoHints) ...[
                                  const SizedBox(height: 10),
                                  ..._demoAccounts.map((acc) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0E1A38) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF1F2D54) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(0xFF1A56DB).withOpacity(0.15),
                                          child: Text(
                                            acc['name']![0],
                                            style: const TextStyle(
                                              color: Color(0xFF1A56DB),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          acc['role']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        subtitle: Text(
                                          acc['email']!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF1A56DB)),
                                        onTap: () => _fillAccount(acc),
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer
                      Text(
                        'Powered by Ayu Ventures · v1.0.0',
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3BB8), Color(0xFF1A56DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A56DB).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.flash_on_rounded, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Kelvin Mech',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'MEP OPERATIONS PLATFORM',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1A56DB),
          ),
        ),
      ],
    );
  }
}
