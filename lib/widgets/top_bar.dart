import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final int points;
  final int lives;
  final bool isDayMode;
  final VoidCallback onProfileTap;

  const TopBar({
    required this.points,
    required this.lives,
    required this.isDayMode,
    required this.onProfileTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Points Display
              Image.asset('assets/shrimp_icon.png', height: 24),
              SizedBox(width: 4),
              Text(
                '$points',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              SizedBox(width: 16),
              // Lives Display
              Image.asset('assets/heart_icon.png', height: 24),
              SizedBox(width: 4),
              Text(
                '$lives',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
            ],
          ),
          // Profile Button
          IconButton(
            icon: Icon(
              Icons.person,
              color: isDayMode ? Colors.black87 : Colors.white,
              size: 28, // Slightly larger icon for better tap recognition
            ),
            onPressed: onProfileTap,
          ),
        ],
      ),
    );
  }
}
