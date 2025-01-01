import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileModal extends StatelessWidget {
  final String fullName;
  final String profileImage;
  final bool isDayMode;
  final String role;
  final VoidCallback onNavigateToSettings;

  const ProfileModal({
    Key? key,
    required this.fullName,
    required this.profileImage,
    required this.isDayMode,
    required this.role,
    required this.onNavigateToSettings,
  }) : super(key: key);

  Future<void> _uploadProfilePicture(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final uid = userProvider.user?.uid;

        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in.')),
          );
          return;
        }

        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(uid)
            .child('profile_picture_${DateTime.now().millisecondsSinceEpoch}.png');

        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .update({'ProfileImage': downloadUrl});

        await userProvider.updateUserProfileImage(downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected or invalid file path.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile picture: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: isDayMode ? Colors.white : const Color(0xFF37474F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 40,
              backgroundImage: profileImage.startsWith('http')
                  ? NetworkImage(profileImage)
                  : AssetImage(profileImage) as ImageProvider,
            ),
            const SizedBox(height: 10),

            // User Name
            Text(
              fullName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Upload Profile Picture Button
            ElevatedButton.icon(
              onPressed: () => _uploadProfilePicture(context),
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload New Profile Picture"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDayMode ? Colors.blueAccent : Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Navigate to Settings Button
            ListTile(
              leading: Icon(
                Icons.settings,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              onTap: onNavigateToSettings,
            ),

            // Role-Specific Navigation
            if (role == 'students')
              ListTile(
                leading: Icon(
                  Icons.school,
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
                title: Text(
                  'My Courses',
                  style: TextStyle(
                    color: isDayMode ? Colors.black87 : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/courses');
                },
              ),
            if (role == 'teachers')
              ListTile(
                leading: Icon(
                  Icons.class_,
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
                title: Text(
                  'Manage Classes',
                  style: TextStyle(
                    color: isDayMode ? Colors.black87 : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/manage_classes');
                },
              ),

            // Theme Toggle
            ListTile(
              leading: Icon(
                isDayMode ? Icons.dark_mode : Icons.light_mode,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
              title: Text(
                isDayMode ? 'Switch to Dark Mode' : 'Switch to Light Mode',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              onTap: () {
                userProvider.toggleTheme();
                Navigator.pop(context);
              },
            ),

            // Logout Button
            ListTile(
              leading: Icon(
                Icons.logout,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              onTap: () {
                userProvider.logout();
                Navigator.pop(context); // Close the modal
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

