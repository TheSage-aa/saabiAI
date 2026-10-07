import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/auth_repository.dart';
import '../../onboarding/presentation/topic_selection_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      setState(() => _error = 'Please agree to the Terms of Service to continue.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authRepositoryProvider).signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        fullName: _nameCtrl.text.trim(),
      );
      if (mounted) context.go('/onboarding/topics');
    } catch (e) {
      setState(() => _error = 'Could not create account. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (result != null && mounted) context.go('/onboarding/topics');
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  SaabiSpacing.lg, SaabiSpacing.sm, SaabiSpacing.lg, SaabiSpacing.lg),
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: SaabiSpacing.xs),
                Text('Start your health learning journey today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SaabiColors.textSecondary,
                        )),
                const SizedBox(height: SaabiSpacing.xl),

                // Full Name
                _FieldLabel('Full Name'),
                _Field(
                  controller: _nameCtrl,
                  hint: 'Your full name',
                  icon: Icons.person_outline,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: SaabiSpacing.md),

                // Email
                _FieldLabel('Email Address'),
                _Field(
                  controller: _emailCtrl,
                  hint: 'Enter your email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: SaabiSpacing.md),

                // Password
                _FieldLabel('Password'),
                _Field(
                  controller: _passwordCtrl,
                  hint: 'Create safe password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePass,
                  onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: SaabiSpacing.md),

                // Confirm Password
                _FieldLabel('Confirm Password'),
                _Field(
                  controller: _confirmCtrl,
                  hint: 'Repeat safe password',
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) =>
                      v != _passwordCtrl.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: SaabiSpacing.md),

                // Terms
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_error != null) ...[
                  const SizedBox(height: SaabiSpacing.sm),
                  SaabiErrorBanner(message: _error!),
                ],
                const SizedBox(height: SaabiSpacing.lg),

                // Create Account button
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Account'),
                ),
                const SizedBox(height: SaabiSpacing.lg),

                _OrDivider(),
                const SizedBox(height: SaabiSpacing.md),

                // Social login
                _SocialButton(
                  label: 'Google',
                  assetPath: 'google',
                  onTap: _loading ? null : _googleSignIn,
                ),
                const SizedBox(height: SaabiSpacing.xl),

                Center(
                  child: Text.rich(TextSpan(
                    text: 'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SaabiColors.textSecondary,
                        ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text('Log In',
                              style: TextStyle(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authRepositoryProvider).signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Incorrect email or password. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (result != null && mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/logo.png',
                height: 32,
                errorBuilder: (_, __, ___) => Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: SaabiColors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: SaabiSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saabi', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SaabiColors.primary, fontWeight: FontWeight.w800)),
                Text('by LUMA', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SaabiColors.green, fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  SaabiSpacing.lg, SaabiSpacing.sm, SaabiSpacing.lg, SaabiSpacing.lg),
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back!', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: SaabiSpacing.xs),
                Text('Log in to continue your health journey',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SaabiColors.textSecondary,
                        )),
                const SizedBox(height: SaabiSpacing.xl),

                _FieldLabel('Email Address'),
                _Field(
                  controller: _emailCtrl,
                  hint: 'Enter your email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    return null;
                  },
                ),
                const SizedBox(height: SaabiSpacing.md),

                _FieldLabel('Password'),
                _Field(
                  controller: _passwordCtrl,
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Please enter your password' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: SaabiColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: SaabiSpacing.sm),
                  SaabiErrorBanner(message: _error!),
                ],
                const SizedBox(height: SaabiSpacing.md),

                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Log In'),
                ),
                const SizedBox(height: SaabiSpacing.lg),

                _OrDivider(),
                const SizedBox(height: SaabiSpacing.md),

                _SocialButton(
                  label: 'Google',
                  assetPath: 'google',
                  onTap: _loading ? null : _googleSignIn,
                ),
                const SizedBox(height: SaabiSpacing.xl),

                Center(
                  child: Text.rich(TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SaabiColors.textSecondary,
                        ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: const Text('Sign Up',
                              style: TextStyle(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

// ─── Forgot Password Screen ───────────────────────────────────────────────────

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).resetPassword(_emailCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = 'Could not send reset link. Please check your email and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
              child: _sent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: SaabiColors.greenLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mark_email_read_outlined,
                              color: SaabiColors.green, size: 32),
                        ),
                        const SizedBox(height: SaabiSpacing.lg),
                        Text('Check your email',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: SaabiSpacing.sm),
                        Text(
                          'We sent a password reset link to ${_emailCtrl.text.trim()}. Please check your inbox and follow the link to reset your password.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SaabiColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SaabiSpacing.xl),
                        ElevatedButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Return to Login'),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reset Password',
                              style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: SaabiSpacing.xs),
                          Text(
                            'Enter your email address to receive password reset instructions.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SaabiColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: SaabiSpacing.xl),
                          _FieldLabel('Email Address'),
                          _Field(
                            controller: _emailCtrl,
                            hint: 'Enter your email',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Please enter your email';
                              if (!v.contains('@')) return 'Enter a valid email address';
                              return null;
                            },
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: SaabiSpacing.sm),
                            SaabiErrorBanner(message: _error!),
                          ],
                          const SizedBox(height: SaabiSpacing.xl),
                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Send Reset Link'),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SaabiSpacing.sm),
      child: Text(label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: SaabiColors.textPrimary,
                fontWeight: FontWeight.w700,
              )),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: SaabiColors.textHint, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: SaabiColors.textHint,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SaabiSpacing.md),
        child: Text('or continue with',
            style: Theme.of(context).textTheme.bodySmall),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.assetPath, this.onTap});
  final String label;
  final String assetPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: SaabiColors.surface,
          borderRadius: BorderRadius.circular(SaabiRadius.xxl),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon placeholder — replace with actual asset
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text('G',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4))),
              ),
            ),
            const SizedBox(width: SaabiSpacing.md),
            Text(label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SaabiColors.textPrimary,
                    )),
          ],
        ),
      ),
    );
  }
}
