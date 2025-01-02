import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/user_provider.dart';
import 'package:learn_inc/screens/flashy_screen.dart';
import 'package:learn_inc/screens/chat_screen.dart';
import 'package:learn_inc/screens/learn_screen.dart';
import 'package:learn_inc/screens/quiz_screen.dart';

import '../../widgets/profile_modal.dart';
import '../../widgets/top_bar.dart';
import '../teacher_attributes/assignments_screen.dart';
import '../teacher_attributes/courses_screen.dart';
import '../teacher_attributes/manage_classes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.role}) : super(key: key);
  final String role;


  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _currentIndex = 0; // Default index to show the MainPage
  AnimationController? _controller; // Nullable controller
  Animation<double>? _animation; // Nullable animation
  late List<Widget> _pages = [];
  late List<Icon> _icons= [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize animation
    _animation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );

    // Role-based configuration with delayed call
    Future.delayed(Duration.zero, () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _configureRoleBasedContent(userProvider.isDayMode);
    });


    _pages = [
      MainPage(animation: _animation), // Main page with octopus
      FlashyScreen(isDayMode: true,),
      ChatScreen(isDayMode: true,),
      LearnScreen(isDayMode: true,),
      QuizzesScreen(isDayMode: true,),
    ];
  }

  void _configureRoleBasedContent(bool isDayMode){
    if(widget.role == 'teachers'){
      _pages = [
        MainPage(animation: _animation,),
        ManageClassesScreen(),
        ChatScreen(isDayMode: isDayMode),
        AssignmentsScreen(),
        QuizzesScreen(isDayMode: isDayMode),
      ];
      _icons = [
        Icon(Icons.home, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.class_, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.chat, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.assignment, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.quiz, size: 30, color: isDayMode ? Colors.black : Colors.white),
      ];
    }
    else if(widget.role == 'students'){
      _pages = [
        MainPage(animation: _animation),
        FlashyScreen(isDayMode: true),
        CoursesScreen(), // Öğrencilere özel
        ChatScreen(isDayMode: isDayMode),
        AssignmentsScreen(), // Öğrencilere özel
        QuizzesScreen(isDayMode: isDayMode),
      ];
      _icons = [
        Icon(Icons.home, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.book, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.chat, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.assignment, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.quiz, size: 30, color: isDayMode ? Colors.black : Colors.white),
      ];
    } else{
      _pages = [
        MainPage(animation: _animation),
        FlashyScreen(isDayMode: isDayMode),
        ChatScreen(isDayMode: isDayMode),
        LearnScreen(isDayMode: isDayMode),
        QuizzesScreen(isDayMode: isDayMode),
      ];
      _icons = [
        Icon(Icons.home, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.flash_on, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.chat, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.lightbulb, size: 30, color: isDayMode ? Colors.black : Colors.white),
        Icon(Icons.quiz, size: 30, color: isDayMode ? Colors.black : Colors.white),
      ];
    }
  }
  @override
  void dispose() {
    _controller?.dispose(); // Dispose of the controller safely
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDayMode = userProvider.isDayMode;
    final user = userProvider.user;

    // Fetch shared fields
    final points = user?.points ?? 0;
    final lives = user?.lives ?? 3;

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      body: Stack(
        children: [
          // Role-specific content
          _pages[_currentIndex],

          // TopBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              points: points,
              lives: lives,
              isDayMode: isDayMode,
              onProfileTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ProfileModal(
                    fullName: user?.fullName ?? "User Name",
                    profileImage: user?.profileImage ?? 'assets/avatars/avatar1.png',
                    isDayMode: isDayMode,
                    onNavigateToSettings: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    role: user?.role ?? 'member',
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Curved Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
        color: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        buttonBackgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        index: _currentIndex,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.flash_on, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.chat, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.lightbulb, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.quiz, size: 30, color: isDayMode ? Colors.black : Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final Animation<double>? animation;

  const MainPage({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDayMode = userProvider.isDayMode;

    return Stack(
      children: [
        // Background
        Container(
          color: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
        ),

        // Main Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating Octopus Animation
              if (animation != null)
                AnimatedBuilder(
                  animation: animation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, animation!.value),
                      child: Image.asset(
                        'assets/octopus.png',
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // Welcome Text
              Text(
                "Welcome to Learn Inc!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDayMode ? Colors.black : Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Learn, Chat, Quiz, and more!",
                style: TextStyle(
                  fontSize: 16,
                  color: isDayMode ? Colors.black54 : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
