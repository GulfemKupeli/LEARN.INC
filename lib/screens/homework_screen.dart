import 'package:flutter/material.dart';

class HomeworkScreen extends StatelessWidget {
  final bool isDayMode;

  const HomeworkScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238);
    final Color cardColor = isDayMode ? const Color(0xFFFFFFFF) : const Color(0xFF37474F);
    final Color textColor = isDayMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final Color buttonColor = isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF546E7A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        title: const Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pending Homework",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            // Homework 1
            _buildHomeworkCard(
              title: "Math: Solve 10 Algebra Problems",
              deadline: "Deadline: Jan 5, 2025",
              cardColor: cardColor,
              textColor: textColor,
              buttonColor: buttonColor,
            ),
            const SizedBox(height: 16),
            // Homework 2
            _buildHomeworkCard(
              title: "English: Write a Short Story",
              deadline: "Deadline: Jan 8, 2025",
              cardColor: cardColor,
              textColor: textColor,
              buttonColor: buttonColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkCard({
    required String title,
    required String deadline,
    required Color cardColor,
    required Color textColor,
    required Color buttonColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              deadline,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // "View Details" tıklandığında yapılacaklar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text("View Details"),
            ),
          ],
        ),
      ),
    );
  }
}
