import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isDataLoaded = false;
  bool _isDayMode = true; // Default to day mode

  UserModel? get user => _user;

  bool get isDataLoaded => _isDataLoaded;

  bool get isDayMode => _isDayMode;

  // Toggle Day/Night Mode
  void toggleTheme() {
    _isDayMode = !_isDayMode;
    notifyListeners();
  }

// UserProvider içine ekleyin
  Future<void> updateUserName(String newName) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Firestore'da kullanıcı adını güncelle
        await FirebaseFirestore.instance.collection('Users').doc(uid).update({
          'FullName': newName,
        });

        // Local user verisini güncelle
        _user = _user?.copyWith(fullName: newName);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating name: $e");
    }
  }

  // Update user profile image
  Future<void> updateUserProfileImage(String newImageUrl) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Update Firestore with the new image URL
        await FirebaseFirestore.instance.collection('Users').doc(uid).update({
          'ProfileImage': newImageUrl,
        });

        // Update local user data
        _user = _user?.copyWith(profileImage: newImageUrl);
        notifyListeners();
      }
    } catch (e) {
      print("Error updating profile image: $e");
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      _isDataLoaded = false;
      _isDayMode = true; // Optionally reset theme
      notifyListeners();
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Future<void> loadUserData(String uid) async {
    try {
      _isDataLoaded = false;
      notifyListeners();

      // Fetch shared data from main document
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(
          uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final role = data?['Role']?.toLowerCase() ?? 'member';

        // Fetch role-specific data from subcollections
        Map<String, dynamic> roleSpecificData = {};
        if (role != 'member') {
          final roleDataSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(uid)
              .collection(role) // For example: 'students', 'teachers'
              .doc('details') // Specific document for role details
              .get();

          if (roleDataSnapshot.exists) {
            roleSpecificData = roleDataSnapshot.data()!;
          }
        }

        // Combine shared and role-specific data
        _user = UserModel.fromJson(data!, uid, roleSpecificData);
      }
    } catch (e) {
      print("Error loading user data: $e");
      _user = null;
    } finally {
      _isDataLoaded = true;
      notifyListeners();
    }
  }


  Future<void> addNewUser({
    required String fullName,
    required String email,
    required String profileImage,
    required String role,
    required String uid,
  }) async {
    final userData = {
      "FullName": fullName,
      "Email": email,
      "ProfileImage": profileImage,
      "Role": role,
      "Points": 0,
      "Lives": 3,
      "StreakDays": 0,
    };

    // Role-specific default data
    final roleSpecificData = {
      "students": {"grade": 0, "enrolledCourses": []},
      "teachers": {"subjects": [], "assignedClasses": []},
      "members": {"preferences": "General Access"},
    };

    try {
      // Add user to the 'Users' collection
      await FirebaseFirestore.instance.collection('Users').doc(uid).set(
          userData);

      // Add user to the role-specific top-level collection
      await FirebaseFirestore.instance
          .collection(role.toLowerCase()) // Collection name matches the role
          .doc(uid)
          .set(userData);

      // Add role-specific data as a subcollection in the 'Users' document
      if (roleSpecificData.containsKey(role.toLowerCase())) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .collection(role.toLowerCase()) // Subcollection matches role
            .doc('details') // Fixed document name
            .set(roleSpecificData[role.toLowerCase()]!);
      }

      print("User successfully added to $role collection.");
    } catch (e) {
      print("Error adding new user: $e");
    }
  }
  Future<void> updateLives(int newLives) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        print('Updating lives in Firestore: $newLives');
        // Firebase'de kullanıcı canını güncelle
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .update({'Lives': newLives});

        // Local kullanıcı verisini güncelle
        _user = _user?.copyWith(lives: newLives);
        notifyListeners();
      } catch (e) {
        print('Error updating lives: $e');
      }
    }
  }

}
