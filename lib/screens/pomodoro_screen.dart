import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  int focusDuration = 25; // Default Focus Time in Minutes
  int breakDuration = 5; // Default Break Time in Minutes
  bool isBreakTime = false; // Track Focus or Break
  Timer? _timer;
  int remainingSeconds = 0;
  AnimationController? _mascotController;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mascotController?.dispose();
    super.dispose();
  }

  void startTimer() {
    stopTimer(); // Önceki bir timer çalışıyorsa durdur
    setState(() {
      remainingSeconds = (isBreakTime ? breakDuration : focusDuration) * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--; // Her saniyede bir azalt
        });
      } else {
        timer.cancel(); // Timer'ı durdur
        setState(() {
          isBreakTime = !isBreakTime; // Süre dolduysa mod değiştir
        });
        startTimer(); // Yeni mod için otomatik olarak başlat
      }
    });
  }

  void stopTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel(); // Timer'ı iptal et
      setState(() {
        // Timer durduğunda yapılacak işlemler buraya eklenebilir
      });
    }
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      remainingSeconds = 0;
      isBreakTime = false;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isBreakTime
        ? const Color(0xFFE0F7FA) // Light Blue for Break
        : const Color(0xFF263238); // Dark Blue for Focus
    final Color textColor = isBreakTime ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isBreakTime
            ? const Color(0xFF4DD0E1) // Lighter Blue for Break
            : const Color(0xFF37474F), // Darker Blue for Focus
        title: const Text("Pomodoro Timer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot Image with Animation
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                  parent: _mascotController!,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Image.asset(
                isBreakTime ? "assets/mascot_resting.png" : "assets/mascot_focus.png",
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isBreakTime ? "Take a Break!" : "Focus Time",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formatTime(remainingSeconds),
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Focus Duration",
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    DropdownButton<int>(
                      dropdownColor: bgColor, // Fix visibility of dropdown
                      value: focusDuration,
                      items: [15, 25, 30, 45].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            "$value min",
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          focusDuration = value!;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Break Duration",
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    DropdownButton<int>(
                      dropdownColor: bgColor, // Fix visibility of dropdown
                      value: breakDuration,
                      items: [5, 10, 15].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            "$value min",
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          breakDuration = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                  ),
                  child: const Text("Start"),
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFF4DD0E1),
                  ),
                  child: const Text("Stop"),
                ),
                ElevatedButton(
                  onPressed: () {
                    resetTimer();
                    Navigator.pop(context); // Exit on reset
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                  ),
                  child: const Text("Exit"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Shrimp Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  "Each Pomodoro earns 20 shrimps!",
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


