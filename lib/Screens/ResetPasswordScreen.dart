import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _password = '';
  String _confirmPassword = '';
  String? passwordError;
  String? confirmPasswordError;

  void validateFields() {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;

      if (_password.isEmpty) {
        passwordError = 'Please provide your password';
      } else if (_password.length < 8) {
        passwordError = 'Password must be at least 8 characters';
      }

      if (_confirmPassword.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
      } else if (_confirmPassword.length < 8) {
        confirmPasswordError = 'Password must be at least 8 characters';
      } else if (_password != _confirmPassword) {
        confirmPasswordError = 'Passwords do not match';
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
                  SizedBox(height: screenHeight * 0.15),
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

                            // New Password Field
                            _buildPasswordField(
                              hintText: "New Password",
                              isObscured: !_isPasswordVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              onChanged: (value) {
                                _password = value;
                              },
                            ),
                            if (passwordError != null) ...[
                              const SizedBox(height: 8),
                              errorWithIcon(passwordError!),
                            ],

                            SizedBox(height: screenHeight * 0.02),

                            // Confirm New Password Field
                            _buildPasswordField(
                              hintText: "Confirm Password",
                              isObscured: !_isConfirmPasswordVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                              onChanged: (value) {
                                _confirmPassword = value;
                              },
                            ),
                            if (confirmPasswordError != null) ...[
                              const SizedBox(height: 8),
                              errorWithIcon(confirmPasswordError!),
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
                                onPressed: () {
                                  validateFields();
                                  if (passwordError == null && confirmPasswordError == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Password Reset Successfully!"),
                                      ),
                                    );
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                },
                                child: const Row(
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

                            SizedBox(height: screenHeight * 0.03),
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

  // Reusable Password Field
  Widget _buildPasswordField({
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    required Function(String) onChanged,
  }) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: TextFormField(
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF5689FF)),
            suffixIcon: IconButton(
              icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF5689FF)),
              onPressed: onToggleVisibility,
            ),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}