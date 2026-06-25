import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lyrica_flutter/presentation/auth/viewmodel/auth_cubit.dart';
import 'package:lyrica_flutter/presentation/home/view/home_screen.dart';
import '../../../core/theme/app_theme.dart';

import '../../shared/widgets/glass_card.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureSignup = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background ambient glows
            Positioned(
              top: -100,
              left: -80,
              child: _glowOrb(AppColors.accentPrimary, 300),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: _glowOrb(AppColors.accentSecondary, 250),
            ),
            Positioned(
              top: 200,
              right: -50,
              child: _glowOrb(AppColors.accentTertiary, 200),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    _buildLogo()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 48),

                    // Tab bar
                    _buildTabBar().animate().fadeIn(
                      delay: 200.ms,
                      duration: 400.ms,
                    ),

                    const SizedBox(height: 8),

                    // Tab content
                    SizedBox(
                      height: 380,
                      child: TabBarView(
                        controller: _tabController,
                        children: [_buildLoginTab(), _buildSignupTab()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.25), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppGradients.brand.createShader(bounds),
          child: const Text(
            'Lyrica',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Music that moves you',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      borderRadius: 14,
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Form(
          key: _loginFormKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v?.isEmpty == true ? 'Email is required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureLogin,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureLogin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureLogin = !_obscureLogin),
                  ),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Password is required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    label: 'Sign In',
                    isLoading: state is AuthLoading,
                    onTap: () {
                      if (_loginFormKey.currentState?.validate() == true) {
                        context.read<AuthCubit>().login(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignupTab() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Form(
          key: _signupFormKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'your_username',
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      v?.isEmpty == true ? 'Username is required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _signupEmailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v?.isEmpty == true ? 'Email is required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _signupPasswordController,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureSignup,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureSignup
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureSignup = !_obscureSignup),
                  ),
                  validator: (v) =>
                      v != null && v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    label: 'Create Account',
                    isLoading: state is AuthLoading,
                    onTap: () {
                      if (_signupFormKey.currentState?.validate() == true) {
                        context.read<AuthCubit>().signup(
                          username: _usernameController.text.trim(),
                          email: _signupEmailController.text.trim(),
                          password: _signupPasswordController.text,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
        filled: true,
        fillColor: AppColors.glass,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
