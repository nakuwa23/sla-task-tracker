import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import 'user_selection_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() => _submitting = true);
    try {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UserSelectionScreen(
            email: _emailController.text.trim(),
            rememberMe: _rememberMe,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Something went wrong signing in. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SLA Task Tracker',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        Text(
                          'Tasks, tracked on time',
                          style: TextStyle(
                              fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to monitor projects, resolve SLA risks, and keep your team moving.',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, Color(0xFF2A3454)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/sign_in_image.jpg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Work email',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                    hintText: 'you@company.com',
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                const Text('Password',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    hintText: 'Enter your password',
                  ),
                  validator: (value) =>
                      Validators.minLength(value, 6, field: 'Password'),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            activeColor: AppColors.primaryDark,
                          ),
                          const Text('Remember me',
                              style: TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Not needed — there is no real backend for this demo.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Forgot password?',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: const Text(
                    'Demo sign-in — no password is checked.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}