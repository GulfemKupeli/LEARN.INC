import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/user_provider.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDayMode = userProvider.isDayMode;

    if (!userProvider.isDataLoaded) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : const Color(0xFF263238),
        appBar: AppBar(
          backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
          title: const Text('User Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = userProvider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : const Color(0xFF263238),
        appBar: AppBar(
          backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
          title: const Text('User Settings'),
        ),
        body: Center(
          child: Text(
            'No user data available.',
            style: TextStyle(
              color: isDayMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    }

    final nameController = TextEditingController(text: user.fullName);
    String selectedAvatar = user.profileImage;

    return Scaffold(
      backgroundColor: isDayMode ? Colors.white : const Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        title: const Text('User Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 50,
                backgroundImage: selectedAvatar.startsWith('http')
                    ? NetworkImage(selectedAvatar)
                    : AssetImage(selectedAvatar) as ImageProvider,
              ),
              const SizedBox(height: 20),

              // Email (non-editable)
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: isDayMode ? Colors.black54 : Colors.white70,
                ),
              ),
              const SizedBox(height: 20),

              // Name Edit Field
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: isDayMode ? Colors.black : Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: "Your Name",
                  labelStyle: TextStyle(
                    color: isDayMode ? Colors.black54 : Colors.white70,
                  ),
                  filled: true,
                  fillColor: isDayMode ? Colors.grey[200] : Colors.grey[700],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar Selection
              Text(
                "Choose Your Avatar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final avatar in [
                      'assets/avatars/avatar1.png',
                      'assets/avatars/avatar2.png',
                      'assets/avatars/avatar3.png',
                      'assets/avatars/avatar4.png',
                      'assets/avatars/avatar5.png'
                    ])
                      GestureDetector(
                        onTap: () {
                          selectedAvatar = avatar;
                          userProvider.updateUserProfileImage(avatar);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedAvatar == avatar
                                  ? (isDayMode ? Colors.blue : Colors.white)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(avatar),
                            radius: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Role-Specific Content
              if (user.role == 'Teacher')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/manage_classes');
                  },
                  icon: const Icon(Icons.class_),
                  label: const Text("Manage Classes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : Colors.white,
                  ),
                ),
              if (user.role == 'Student')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/my_courses');
                  },
                  icon: const Icon(Icons.school),
                  label: const Text("My Courses"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : Colors.white,
                  ),
                ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: () {
                  userProvider.updateUserName(nameController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
