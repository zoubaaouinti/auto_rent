import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const OTPVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String? _otpError;
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void validateOTP() async {
    setState(() => _otpError = null);
    
    if (_otpController.text.length < 4) {
      setState(() => _otpError = 'Please enter a valid 4-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Rediriger vers le formulaire de réinitialisation avec l'OTP
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: {
            'email': widget.email,
            'otp': _otpController.text.trim(),
          },
        );
      }
    } catch (e) {
      setState(() => _otpError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                            SizedBox(height: screenHeight * 0.01),
                            const Center(
                              child: Text(
                                'ENTER OTP CODE',
                                style: TextStyle(
                                  fontFamily: 'bgbold',
                                  color: Color(0xFF5689FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // OTP Input with validation
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
                                      onChanged: (value) {
                                        setState(() {
                                          _otpError = null; // clear error on input
                                        });
                                      },
                                    ),
                                    if (_otpError != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFA5450), size: 18),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              _otpError!,
                                              style: const TextStyle(
                                                color: Color(0xFFFA5450),
                                                fontSize: 12,
                                                fontFamily: 'bgmedium',
                                              ),
                                              textAlign: TextAlign.center,
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

                            // Verify OTP Button
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
                                onPressed: _isLoading ? null : validateOTP,
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
                                onTap: _isLoading ? null : () async {
                                  try {
                                    await ref.read(authServiceProvider).forgotPassword(widget.email);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Nouveau code envoyé avec succès'),
                                          backgroundColor: Colors.green,
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
                                  "Didn't receive an OTP? Resend",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'bgmedium',
                                    color: _isLoading ? Colors.grey : const Color(0xFF5689FF),
                                  ),
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