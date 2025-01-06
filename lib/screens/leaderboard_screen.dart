import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  // Mock user data
  final List<Map<String, dynamic>> users = [
    {'name': 'Alihan', 'shrimp': 150},
    {'name': 'Birce', 'shrimp': 120},
    {'name': 'Altuğ', 'shrimp': 100},
    {'name': 'Güneş', 'shrimp': 90},
    {'name': 'Ali', 'shrimp': 75},
  ];

  @override
  Widget build(BuildContext context) {
    // Sort users by shrimp points in descending order
    users.sort((a, b) => b['shrimp'].compareTo(a['shrimp']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: const Color(0xFF4DD0E1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh leaderboard functionality can be added here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4DD0E1),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFF4DD0E1),
                        child: Text('#${index + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      title: Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        index == 0
                            ? '🥇 Champion!'
                            : index == 1
                            ? '🥈 Runner-up!'
                            : index == 2
                            ? '🥉 Third Place!'
                            : '',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/shrimp_icon.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 8),
                          Text('${user['shrimp']} shrimps',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality for sharing leaderboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Share',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality for viewing full leaderboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.list, color: Colors.white),
                  label: const Text(
                    'View All',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

