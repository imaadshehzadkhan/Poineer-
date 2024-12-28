import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Blue Card
            Stack(
              children: [
                // Background Image
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    'lib/assets/images/3.png', // Replace with your asset image
                    fit: BoxFit.cover,
                  ),
                ),
                // Blue Card Overlay
                Positioned(
                  left: 16,
                  right: 16,
                  top: 80,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "ABOUT US",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Home / About Us",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Video Section with Play Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/images/imggetstarted.png', // Replace with video thumbnail
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Text Section Below Video
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "We Have Experienced Professionals & We Do Our Best To Achieve Your Goal. Your Happiness Is Our First Priority.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Section with Two Images
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'lib/assets/images/pagal.png', // Replace with the first image
                        fit: BoxFit.cover,
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/getstarted.png', // Replace with the second image
                            fit: BoxFit.cover,
                            height: 150,
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scrollable Text Section with Read More Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Our Mission",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "We strive to provide quality education to our students by fostering a nurturing and innovative learning environment. Our focus is on creating opportunities for growth, instilling confidence, and preparing our students for future challenges.",
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: Colors.black54,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Handle "Read More" click
                    },
                    child: const Text(
                      "Read More",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AboutUsPage(),
  ));
}
