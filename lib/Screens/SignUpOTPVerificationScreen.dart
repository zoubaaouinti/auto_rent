import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:flutter/services.dart';

import '../providers/auth_provider.dart';

class SignUpOTPVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  const SignUpOTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });
  @override
  ConsumerState<SignUpOTPVerificationScreen> createState() => _SignUpOTPVerificationScreenState();
}

class _SignUpOTPVerificationScreenState extends ConsumerState<SignUpOTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String? _otpError;
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndCreateAccount() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _otpError = null;
  });

  try {
    // 1. Vérifier l'email avec l'OTP
    await ref.read(authServiceProvider).verifyEmail(
      email: widget.email,
      otp: _otpController.text.trim(),
    );

    // 2. Se connecter automatiquement après vérification réussie
    final user = await ref.read(authServiceProvider).login(
      email: widget.email,
      password: widget.password,
    );

    if (mounted) {
      // 3. Mettre à jour l'état d'authentification
      ref.read(authStateProvider.notifier).state = AsyncValue.data(user);
      
      // 4. Rediriger vers l'écran d'accueil
      Navigator.pushReplacementNamed(context, '/main');
    }
  } catch (e) {
    final errorMessage = e.toString().replaceAll('Exception: ', '');
    setState(() => _otpError = errorMessage);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  // Méthode pour coller le code OTP depuis le presse-papiers
  Future<void> _pasteOTP() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      // Nettoyer le texte collé pour ne garder que les chiffres
      final otp = clipboardData.text!.replaceAll(RegExp(r'[^0-9]'), '');
      if (otp.isNotEmpty) {
        setState(() {
          _otpController.text = otp;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bgSignUp.png"),
              fit: BoxFit.cover,
              opacity: 0.9,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.18),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    color: const Color(0xFF020020).withAlpha((0.6 * 255).toInt()),
                    elevation: 15,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.09),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: SizedBox(
                                width: screenWidth * 0.2,
                                height: screenHeight * 0.1,
                                child: Image.asset('assets/images/logo.png'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Center(
                              child: Text(
                                'VERIFY YOUR EMAIL',
                                style: TextStyle(
                                  fontFamily: 'bgbold',
                                  color: Color(0xFF5689FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            
                            // OTP Input
                            FormField<String>(
                              validator: (_) => _otpError,
                              builder: (field) {
                                return Column(
                                  children: [
                                    Pinput(
                                      length: 4,
                                      controller: _otpController,
                                      defaultPinTheme: PinTheme(
                                        width: 60,
                                        height: 60,
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5689FF),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFF5689FF)),
                                        ),
                                      ),
                                      onChanged: (_) {
                                        setState(() => _otpError = null);
                                      },
                                    ),
                                    if (_otpError != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded,
                                              color: Color(0xFFFA5450), size: 18),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              _otpError!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xFFFA5450),
                                                fontSize: 12,
                                                fontFamily: 'bgmedium',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Verify Button
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5689FF),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.06,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: _isLoading ? null : _verifyAndCreateAccount,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Verify OTP',
                                            style: TextStyle(
                                              fontFamily: 'bgmedium',
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.verified, color: Colors.white),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Resend OTP
                            Center(
                              child: GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () async {
                                  try {
                                    await ref.read(authServiceProvider).forgotPassword(widget.email);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Nouveau code envoyé avec succès'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Erreur: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  "Renvoyer le code",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'bgmedium',
                                    color: _isLoading
                                        ? Colors.grey
                                        : const Color(0xFF5689FF),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Back to Sign Up
                            Center(
                              child: GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(
                                  "Retour à l'inscription",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'bgmedium',
                                    color: _isLoading 
                                        ? Colors.grey 
                                        : const Color(0xFF5689FF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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