import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late bool _isDayMode;

  @override
  void initState() {
    super.initState();
    _updateThemeBasedOnTime();
  }

  void _updateThemeBasedOnTime() {
    final hour = DateTime.now().hour;
    _isDayMode = hour >= 6 && hour < 18; // Day mode for 6 AM - 6 PM
  }

  bool _validateInputs() {
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return false;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long.")),
      );
      return false;
    }
    return true;
  }

  Future<void> _login() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _checkUserRole();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for this email.";
          break;
        case 'wrong-password':
          errorMessage = "Invalid password. Please try again.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        default:
          errorMessage = "Login failed. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc.data()?['Role']?.toLowerCase() ?? 'member';

        if (role == 'students') {
          Navigator.pushReplacementNamed(context, '/student_dashboard_screen');
        } else if (role == 'teachers') {
          Navigator.pushReplacementNamed(context, '/teacher_dashboard_screen');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard_screen');
        }
        return;
      }

      print("No role found for user: ${user.uid}");
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error checking user role: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDayMode
                    ? [Color(0xFF80DEEA), Color(0xFF00796B)] // Day mode colors
                    : [Color(0xFF37474F), Color(0xFF263238)], // Night mode colors
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Waves Decoration
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(isDayMode: _isDayMode),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mascot Image
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDayMode = !_isDayMode; // Toggle theme
                        });
                      },
                      child: Image.asset(
                        _isDayMode
                            ? 'assets/morning_mascot.png'
                            : 'assets/night_mascot.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Welcome Text
                    Text(
                      _isDayMode ? "Good Morning" : "Good Evening",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Input
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // Password Input
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDayMode
                            ? Colors.teal.shade700
                            : Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sign Up Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class WavePainter extends CustomPainter {
  final bool isDayMode;

  WavePainter({required this.isDayMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDayMode
          ? Colors.white.withOpacity(0.2) // Light waves for day mode
          : Colors.black.withOpacity(0.3); // Darker waves for night mode
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
