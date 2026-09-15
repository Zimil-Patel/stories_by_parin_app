import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/screens/auth%20screen/sign_up_screen.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/stories_byp_logo.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'components/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AuthProvider>();

    final success = await provider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Unable to sign in.')),
      );

      return;
    }

    // Dashboard navigation will be added once
    // authentication state routing is implemented.
  }

  Future<void> _signInWithGoogle() async {
    final provider = context.read<AuthProvider>();

    final success = await provider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Google sign-in failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
        
                      // App title.
                      StoriesLogo(color: Colors.black,),
        
                      const SizedBox(height: 30),
        
                      Text(
                        'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
        
                      const SizedBox(height: 40),
        
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        obscureText: false,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email.';
                          }
        
                          if (!value.contains('@')) {
                            return 'Please enter a valid email.';
                          }
        
                          return null;
                        },
                      ),
        
                      const SizedBox(height: 16),
        
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        showPasswordToggle: true,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
        
                          return null;
                        },
                      ),
        
                      const SizedBox(height: 24),
        
                      AuthButton(
                        text: 'Sign In',
                        isLoading: provider.isLoading,
                        onPressed: _signIn,
                      ),
        
                      const SizedBox(height: 20),
        
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white38,)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR'),
                          ),
                          Expanded(child: Divider(color: Colors.white38,)),
                        ],
                      ),
        
                      const SizedBox(height: 20),
        
                      SocialAuthButton(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        isLoading: provider.isLoading,
                        onPressed: _signInWithGoogle,
                      ),
        
                      const SizedBox(height: 12),
        
                      SocialAuthButton(
                        text: 'Continue with Apple',
                        icon: Icons.apple,
                        isLoading: provider.isLoading,
                        onPressed: () {
                          // Apple Sign-In will be connected
                          // after its Firebase configuration.
                        },
                      ),
        
                      const SizedBox(height: 28),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
