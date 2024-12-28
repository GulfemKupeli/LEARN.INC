import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout() async {
    try {
      await _auth.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print("Error during logout: $e");
      // Optionally rethrow the error to handle it at a higher level
      throw e;
    }
  }
}