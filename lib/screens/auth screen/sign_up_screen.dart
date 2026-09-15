import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/screens/auth%20screen/login_screen.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/stories_byp_logo.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'components/social_auth_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the signup form fields.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the screen is removed.
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _signUp() async {
    // Validate all form fields before calling Firebase.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AuthProvider>();

    final success = await provider.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Unable to create account.',
          ),
        ),
      );

      return;
    }

    // For now, go back to Login.
    // Later authentication-state routing will handle this automatically.
    Navigator.pop(context);
  }

  Future<void> _signUpWithGoogle() async {
    final provider = context.read<AuthProvider>();

    final success = await provider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Google sign-in failed.',
          ),
        ),
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
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),

                      // App logo.
                      StoriesLogo(
                        color: Colors.black,
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 40),

                      Row(
                        children: [
                          Expanded(
                            child: AuthTextField(
                              controller: _firstNameController,
                              hintText: 'First name',
                              obscureText: false,
                              prefixIcon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter first name.';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: AuthTextField(
                              controller: _lastNameController,
                              hintText: 'Last name',
                              obscureText: false,
                              prefixIcon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter last name.';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Email.
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        obscureText: false,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your email.';
                          }

                          if (!value.contains('@')) {
                            return 'Please enter a valid email.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password.
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        showPasswordToggle: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password.';
                          }

                          if (value.length < 6) {
                            return 'Password must be at least 6 characters.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm password.
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm password',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password.';
                          }

                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Create account button.
                      AuthButton(
                        text: 'Create Account',
                        isLoading: provider.isLoading,
                        onPressed: _signUp,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.white38,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Text('OR'),
                          ),
                          Expanded(
                            child: Divider(color: Colors.white38,),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google sign-in.
                      SocialAuthButton(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        isLoading: provider.isLoading,
                        onPressed: _signUpWithGoogle,
                      ),

                      const SizedBox(height: 12),

                      // Apple sign-in.
                      // SocialAuthButton(
                      //   text: 'Continue with Apple',
                      //   icon: Icons.apple,
                      //   isLoading: provider.isLoading,
                      //   onPressed: () {
                      //     // Apple Sign-In will be connected
                      //     // after its Firebase configuration.
                      //   },
                      // ),

                      const SizedBox(height: 0),

                      // Navigate back to Login.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Sign In'),
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