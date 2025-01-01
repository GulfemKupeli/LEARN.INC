import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = "None"; // Default role
  bool _isLoading = false;
  bool _isDayMode = true; // Default mode


  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Assign 'members' role if no role is explicitly selected
      final role = (_selectedRole == "None") ? "members" : _selectedRole.toLowerCase();

      // Register user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user data to Firestore
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.addNewUser(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: "assets/avatars/avatar1.png", // Default avatar
        role: role,
        uid: userCredential.user!.uid,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful!")),
      );

      // Redirect based on the role
      if (role == "teacher") {
        Navigator.pushReplacementNamed(context, '/teacher_dashboard_screen');
      } else if (role == "student") {
        Navigator.pushReplacementNamed(context, '/student_dashboard_screen');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard_screen'); // Default for 'members'
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB2DFDB), Color(0xFF00796B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Wave effect
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: [
                        Text(
                          "Are you one of these?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: _isDayMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _selectedRole = 'Teacher');
                              },
                              icon: Icon(Icons.school, size: 18),
                              label: Text(
                                "Teacher",
                                style: TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRole == 'Teacher'
                                    ? Colors.teal.shade700
                                    : (_isDayMode ? Colors.teal : Colors.grey[700]),
                                foregroundColor: _selectedRole == 'Teacher'
                                    ? Colors.white
                                    : Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: _selectedRole == 'Teacher' ? 6 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _selectedRole = 'Student');
                              },
                              icon: Icon(Icons.person, size: 18),
                              label: Text(
                                "Student",
                                style: TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRole == 'Student'
                                    ? Colors.teal.shade700
                                    : (_isDayMode ? Colors.teal : Colors.grey[700]),
                                foregroundColor: _selectedRole == 'Student'
                                    ? Colors.white
                                    : Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: _selectedRole == 'Student' ? 6 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() => _selectedRole = 'None');
                              },
                              child: Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'None'
                                      ? Colors.teal.shade700
                                      : (_isDayMode ? Colors.teal.shade200 : Colors.grey[700]),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedRole == 'None'
                                        ? Colors.teal.shade900
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "None of These",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedRole == 'None'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),


                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}
