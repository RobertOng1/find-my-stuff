import 'package:flutter/material.dart';
import 'package:find_my_stuff/pages/navbar.dart';
import '../core/utils/ui_utils.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignUp = false; // false = Sign In, true = Sign Up

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _handleSubmit() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        (isSignUp && confirmPassword.isEmpty)) {
      UiUtils.showModernSnackBar(context, "All fields must be filled!", isSuccess: false);
      return;
    }

    if (isSignUp && password != confirmPassword) {
      UiUtils.showModernSnackBar(context, "Password does not match!", isSuccess: false);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainNavbar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSignUp ? "Create Account" : "Welcome Back!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSignUp
                    ? "Please sign up to continue using the app."
                    : "Please sign in to continue using the app.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // email / phone
              _buildTextField(
                controller: emailController,
                hintText: "Email or Phone Number",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // password
              _buildTextField(
                controller: passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              if (isSignUp) ...[
                const SizedBox(height: 20),
                _buildTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 40),

              // button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff92A3FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    isSignUp ? "Sign Up" : "Sign In",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // switch to Sign Up / Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSignUp
                        ? "Already have an account? "
                        : "Don't have an account? ",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSignUp = !isSignUp;
                        emailController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      isSignUp ? "Sign In" : "Sign Up",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff92A3FD),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // custom text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
