import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:PIL/pages/aboutus.dart';
import 'package:PIL/pages/admissions.dart';
import 'package:PIL/pages/contactus.dart';
import 'package:PIL/pages/messages.dart';
import 'package:PIL/pages/mission.dart';
import 'package:PIL/pages/sidemenu.dart';
import 'package:PIL/pages/syllabus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Animation Controller for popup
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Scroll controller for horizontal cards
  late ScrollController _scrollController;
  late Timer _scrollTimer;
  double _scrollOffset = 0.0;

  // Estimated card width + horizontal margin in the ListView
  final double _cardWidth = 220.0;

  /// Data for horizontal auto-scrolling cards
  final List<Map<String, String>> cardData = [
    {
      'imagePath': 'lib/assets/images/bannerimg3.png',
      'title': 'Events',
      'subtitle': '',
    },
    {
      'imagePath': 'lib/assets/images/schooladmissionbanner.png',
      'title': 'Admission Open',
      'subtitle': '',
    },
    {
      'imagePath': 'lib/assets/images/btcbanner.png',
      'title': 'PIL',
      'subtitle': '',
    },
  ];

  @override
  void initState() {
    super.initState();

    /// Animation for the popup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Trigger the popup after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showPopup();
      }
    });

    /// Set up the scroll controller and start auto-scroll
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _scrollTimer.cancel();
    super.dispose();
  }

  /// Starts a periodic timer that auto-scrolls the horizontal ListView
  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Make sure the scroll controller is attached to the ListView
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;

        // Move one card at a time
        _scrollOffset += _cardWidth;

        // If we go past the end, jump back to the start
        if (_scrollOffset > maxScrollExtent) {
          _scrollOffset = 0.0;
        }

        // Animate to the new offset
        _scrollController.animateTo(
          _scrollOffset,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Handles BottomNavigationBar item taps with boundary checks
  void _onItemTapped(int index) {
    if (index >= 0 && index < 4) { // Ensure index is within valid range
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Optionally, handle invalid indices or log an error
      // For now, we'll reset to the first item
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  /// Build the currently selected page
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _homePageContent();
      case 1:
        return AboutUsPage();
      case 2:
        return ContactUsPage();
      case 3:
        return RegistrationFormPage();
      default:
      // Fallback to home content if the index is invalid
        return _homePageContent();
    }
  }

  /// Main content of the home page
  Widget _homePageContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adjusted AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Drawer Button
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: Colors.green, size: 30),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Open drawer
                      },
                    );
                  },
                ),
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      'lib/assets/vectors/nav-logo.svg',
                      height: 45,
                    ),
                  ),
                ),
                // Notification Icon (GREEN)
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.green, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessagesActivity()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),


          // Main Title Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: Center(
              child: Text(
                "Pioneering Excellence: Shaping Futures in the Valley Through Innovation and Quality Education.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Horizontal Cards (AUTO-SCROLL)
          SizedBox(
            height: 180,
            child: ListView.builder(
              controller: _scrollController,        // Attach our scroll controller
              scrollDirection: Axis.horizontal,     // Horizontal scrolling
              itemCount: cardData.length,           // Number of cards
              itemBuilder: (context, index) {
                final card = cardData[index];
                return _examCard(
                  card['imagePath']!,
                  card['title']!,
                  card['subtitle']!,
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // SCHOOL Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SCHOOL",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "See All",
                  style: TextStyle(fontSize: 13, color: Colors.blue, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Lesson Icons
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Admissions
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  child: InkWell(
                    onTap: () {
                      _safeNavigate(
                        context,
                        MaterialPageRoute(builder: (context) => RegistrationFormPage()),
                      );
                    },
                    child: _lessonIconWithImage("ADMISSIONS", "lib/assets/images/admicon.png"),
                  ),
                ),
                // Mission
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  child: InkWell(
                    onTap: () {
                      _safeNavigate(
                        context,
                        MaterialPageRoute(builder: (context) => MissionVisionPage()),
                      );
                    },
                    child: _lessonIconWithImage("Mission", "lib/assets/images/missioniconlogo.png"),
                  ),
                ),
                // Syllabus
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: InkWell(
                    onTap: () {
                      _safeNavigate(
                        context,
                        MaterialPageRoute(builder: (context) => SyllabusActivity()),
                      );
                    },
                    child: _lessonIconWithImage("Syllabus", "lib/assets/images/syllicon.png"),
                  ),
                ),
                // Gallery
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: InkWell(
                    onTap: () {
                      // Implement navigation for Gallery if needed
                      // For now, it's just a static icon
                    },
                    child: _lessonIconWithImage("GALLERY", "lib/assets/images/galleryicon.png"),
                  ),
                ),
              ],
            ),
          ),

          // Vertical Cards
          _verticalCard(
            "INNOVATIVE CURRICULUM",
            "Curriculum fostering creativity and excellence.",
            'lib/assets/images/cirricicon.png',
          ),
          _verticalCard(
            "MODERN LIBRARY",
            "Extensive collection of books and resources.",
            'lib/assets/images/labicon.png',
          ),
          _verticalCard(
            "QUALIFIED TEACHER",
            "Experienced, dedicated teachers for every student.",
            'lib/assets/images/hatsicon.png',
          ),
          _verticalCard(
            "BEST INFRASTRUCTURE",
            "State-of-the-art facilities for learning.",
            'lib/assets/images/buildicon.png',
          ),
          _verticalCard(
            "ONLINE SUPPORT",
            "24/7 access to learning resources online.",
            'lib/assets/images/onlineicon.png',
          ),
          const SizedBox(height: 21),
        ],
      ),
    );
  }

  /// Card widget for horizontal list
  Widget _examCard(String imagePath, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 300, // Increased card width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Icon widget for lesson shortcuts
  Widget _lessonIconWithImage(String title, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Vertical list card
  Widget _verticalCard(String title, String subtitle, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 50, width: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Popup (Register Now)
  void _showPopup() {
    _controller.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'lib/assets/images/schooladmissionbanner.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Join Our School Today!",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Unlock your child’s bright future with exceptional education.",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          _safeNavigate(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationFormPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        label: const Text(
                          "Register Now",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Copyright © 2025 | Designed by ADTS",
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 8, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF00C853), Color(0xFFB2FF59)]),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Safely navigates to a new page if the widget is still mounted
  void _safeNavigate(BuildContext context, Route route) {
    if (mounted) {
      Navigator.push(context, route);
    }
  }

  /// Build the full scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: SideMenu(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      body: SafeArea(child: _buildPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are displayed
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("lib/assets/images/homeicon.png", width: 24),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("lib/assets/images/heart.png", width: 24),
            label: "About Us",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("lib/assets/images/discovr.png", width: 24),
            label: "Contact Us",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("lib/assets/images/profile.png", width: 24),
            label: "Registration",
          ),
        ],
      ),
    );
  }
}
