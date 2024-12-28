import 'package:flutter/material.dart';
import 'package:PIL/pages/admissionprocess.dart';
import 'package:PIL/pages/datesheet.dart';
import 'package:PIL/pages/messages.dart';
import 'package:PIL/pages/syllabus.dart';

class SideMenu extends StatelessWidget {
  final Function(int) onItemTapped; // Callback for item tap
  final int selectedIndex;

  const SideMenu({Key? key, required this.onItemTapped, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header with full image and overlay card
          SizedBox(
            height: 200, // Adjust to desired height
            child: Stack(
              children: [
                // Full-width background image
                Positioned.fill(
                  child: Image.asset(
                    'lib/assets/images/3.png', // Replace with your asset path
                    fit: BoxFit.cover,
                  ),
                ),
                // Card-like overlay for the text
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "MENU",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Home / MENU",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.green),
                  title: const Text(
                    'Syllabus',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SyllabusActivity()), // Navigate to SyllabusActivity
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
                  title: const Text(
                    'Date Sheet',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DatesheetActivity()), // Navigate to DatesheetActivity
                    );
                    onItemTapped(2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.green),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  selected: selectedIndex == 3,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessagesActivity()), // Navigate to MessagesActivity
                    );
                    onItemTapped(3);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.school, color: Colors.green), // Updated icon for Admission Portal
                  title: const Text(
                    'Admission Portal',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  selected: selectedIndex == 4,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                    );
                    onItemTapped(4);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.green),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),

          // Footer with a logout button
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Copyright © 2025 | Designed by ADTS',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
