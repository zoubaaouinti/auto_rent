import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? emailError;
  String _email = '';
  bool _isLoading = false;

  void validateEmail() {
    setState(() {
      emailError = null;

      if (_email.isEmpty) {
        emailError = 'Please Provide your E-mail';
      } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email)) {
        emailError = 'Please Provide a valid E-mail';
      }
    });
  }

  Widget errorWithIcon(String errorMessage) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_outlined, color: Color(0xFFFA5450), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Color(0xFFFA5450), fontSize: 12, fontFamily: 'bgmedium'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset("assets/images/bgSignUp.png").image,
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
                    color: const Color(0xFF020020).withAlpha((0.60 * 255).toInt()),
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
                            SizedBox(height: screenHeight * 0.01),
                            const Center(
                              child: Text(
                                'RESET YOUR PASSWORD',
                                style: TextStyle(
                                  fontFamily: 'bgbold',
                                  color: Color(0xFF5689FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // Email Field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                                    blurRadius: 8,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenWidth * 0.01,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015,
                                        horizontal: screenWidth * 0.05),
                                    hintText: 'Enter your email',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(Icons.email,
                                        color: Color(0xFF5689FF)),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  onChanged: (value) {
                                    _email = value;
                                  },
                                ),
                              ),
                            ),
                            if (emailError != null) ...[
                              const SizedBox(height: 8),
                              errorWithIcon(emailError!),
                            ],
                            SizedBox(height: screenHeight * 0.03),

                            // Reset Password Button
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
                                onPressed: _isLoading ? null : () async {
                                  validateEmail();
                                  if (emailError == null) {
                                    setState(() => _isLoading = true);
                                    try {
                                      // Appeler forgotPassword pour envoyer l'OTP
                                      await ref.read(authServiceProvider).forgotPassword(_email);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Code OTP envoyé par email'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        // Rediriger vers la page de vérification OTP
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/forgot-password-otp',
                                          arguments: _email,
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
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
                                },
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
                                            'Reset Password',
                                            style: TextStyle(
                                              fontFamily: 'bgmedium',
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.refresh, color: Colors.white),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Back to Login
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, '/login'); // Navigate back to Login
                                },
                                child: const Text(
                                  "Back to Login",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'bgmedium',
                                    color: Color(0xFF5689FF),
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