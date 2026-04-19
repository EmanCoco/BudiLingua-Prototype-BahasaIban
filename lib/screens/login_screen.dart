import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'main_layout.dart';
import 'language_preference_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isSignUpMode = false;

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B365D))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Okay", style: TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Missing Fields", "Please enter both your email and password.");
      return;
    }

    if (_isSignUpMode) {
      if (username.isEmpty) {
        _showErrorDialog("Missing Username", "Please choose a username for your profile.");
        return;
      }
      if (password != confirmPassword) {
        _showErrorDialog("Passwords Mismatch", "Your passwords do not match. Please re-type them carefully.");
        return;
      }
      if (password.length < 6) {
        _showErrorDialog("Weak Password", "Password must be at least 6 characters long.");
        return;
      }
    }

    setState(() => _isLoading = true);

    AuthResponse? response;
    try {
      response = _isSignUpMode 
        ? await _authService.signUp(email, password, username: username)
        : await _authService.signIn(email, password);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Clean up Supabase error strings to make them native and cute
      String errorMsg = e.toString();
      if (errorMsg.contains('Invalid login credentials')) {
        errorMsg = "The email or password you entered is incorrect. Double-check your spelling!";
      } else if (errorMsg.contains('User already registered')) {
        errorMsg = "An account with this email already exists! Try logging in instead.";
      } else {
         if (errorMsg.contains('message: ')) {
            final split = errorMsg.split('message: ');
            if (split.length > 1) {
              errorMsg = split[1].split(',').first;
            }
         }
      }
      
      _showErrorDialog("Authentication Failed", errorMsg);
      return;
    }

    setState(() => _isLoading = false);

    if (response != null && response.user != null) {
      if (!mounted) return;
      if (!_isSignUpMode) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLayout()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LanguagePreferenceScreen()));
      }
    } else {
      if (!mounted) return;
      _showErrorDialog("Unknown Error", "Could not complete the process. Please try again later.");
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x331B365D), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x331B365D), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B365D), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Cream background matching UIUX
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with logo
              Column(
                children: [
                   Hero(
                    tag: 'app_logo',
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "BudiLingua",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B365D)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUpMode ? "Create your account" : "Learn indigenous languages",
                    style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Form fields
              if (_isSignUpMode)
                _buildTextField("Username", "Your display name", _usernameController),
                
              _buildTextField("Email", "your@email.com", _emailController),
              _buildTextField("Password", "••••••••", _passwordController, isPassword: true),
              
              if (_isSignUpMode)
                _buildTextField("Confirm Password", "••••••••", _confirmPasswordController, isPassword: true),
              
              if (!_isSignUpMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, 
                    child: const Text("Forgot password?", style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                
              SizedBox(height: _isSignUpMode ? 16 : 0),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF1B365D),
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 18),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     elevation: 4,
                     shadowColor: const Color(0x4D1B365D),
                  ),
                  child: Text(_isSignUpMode ? "Create Account" : "Login", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 24),
              
              if (!_isSignUpMode) ...[
                Row(
                  children: [
                    Expanded(child: Divider(color: const Color(0xFF1B365D).withValues(alpha: 0.2))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("or", style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    Expanded(child: Divider(color: const Color(0xFF1B365D).withValues(alpha: 0.2))),
                  ],
                ),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: () {}, // Mock
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Color(0xFF1B365D)),
                  label: const Text("Continue with Google", style: TextStyle(color: Color(0xFF1B365D), fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: const Color(0xFF1B365D).withValues(alpha: 0.2), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isSignUpMode ? "Already have an account? " : "Don't have an account? ", style: const TextStyle(color: Color(0xFF64748B))),
                  GestureDetector(
                    onTap: () {
                       setState(() {
                         _isSignUpMode = !_isSignUpMode;
                         // Clear form when switching
                         _passwordController.clear();
                         _confirmPasswordController.clear();
                       });
                    },
                    child: Text(_isSignUpMode ? "Login" : "Sign up", style: const TextStyle(color: Color(0xFF1B365D), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
