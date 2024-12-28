import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PIL/pages/pdf_viewer_page.dart';
import 'package:PIL/pages/pdfviewer.dart';

class SyllabusActivity extends StatefulWidget {
  const SyllabusActivity({Key? key}) : super(key: key);

  @override
  State<SyllabusActivity> createState() => _SyllabusActivityState();
}

class _SyllabusActivityState extends State<SyllabusActivity>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> _syllabusData;
  List<dynamic> _allSyllabi = []; // To store all fetched syllabi
  List<dynamic> _filteredSyllabi = []; // To store filtered syllabi based on search
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _syllabusData = fetchSyllabus();
    _searchController.addListener(_onSearchChanged);

    // Initialize AnimationController and Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above the view
      end: Offset.zero, // End at original position
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0, // Fully transparent
      end: 1.0, // Fully opaque
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start the animation after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Fetch syllabus from API
  Future<List<dynamic>> fetchSyllabus() async {
    print('SyllabusActivity: Fetching syllabus from API...');
    final response =
        await http.get(Uri.parse('https://api-pil.site/api/auth/syllabus'));

    print('SyllabusActivity: Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('SyllabusActivity: JSON response: $jsonResponse');

      if (jsonResponse['success'] == true) {
        print('SyllabusActivity: Syllabus fetch success!');
        List<dynamic> data = jsonResponse['data'];

        // Sort the syllabi by 'createdAt' in descending order (latest first)
        data.sort((a, b) {
          DateTime dateA = DateTime.parse(a['createdAt']);
          DateTime dateB = DateTime.parse(b['createdAt']);
          return dateB.compareTo(dateA);
        });

        _allSyllabi = data;
        _filteredSyllabi = _allSyllabi;
        return _allSyllabi;
      } else {
        throw Exception(
            'SyllabusActivity: Failed to load syllabus data (success == false)');
      }
    } else {
      throw Exception(
          'SyllabusActivity: Failed to connect to the server. Status: ${response.statusCode}');
    }
  }

  // Safely parse string values
  String _parseString(dynamic value, {String fallback = "Not Provided"}) {
    if (value == null || value is! String) {
      return fallback;
    }
    return value;
  }

  // Get full URL
  String getFullPdfUrl(String relativeUrl) {
    const baseUrl = 'https://api-pil.site/';
    return baseUrl + relativeUrl;
  }

  // Handle search input changes
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSyllabi = _allSyllabi;
      } else {
        _filteredSyllabi = _allSyllabi.where((syllabus) {
          String className =
              _parseString(syllabus['class'], fallback: '').toLowerCase();
          return className.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Syllabus',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.greenAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSearchBar(),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _syllabusData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            );
          } else if (snapshot.hasData) {
            final syllabusList = _filteredSyllabi;
            if (syllabusList.isEmpty) {
              return const Center(
                child: Text(
                  'No syllabus available.',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: syllabusList.length,
              itemBuilder: (context, index) {
                final syllabus = syllabusList[index];
                final title =
                    _parseString(syllabus['class'], fallback: 'Untitled');
                final uploadedAt =
                    _parseString(syllabus['createdAt'], fallback: 'N/A');
                final pdfUrl =
                    getFullPdfUrl(_parseString(syllabus['pdfUrl'], fallback: ''));

                // Split date and time
                final parts = uploadedAt.split('T');
                final date = parts.isNotEmpty ? parts[0] : 'N/A';
                final time = parts.length > 1
                    ? parts[1].split('.')[0]
                    : 'N/A'; // Remove milliseconds and timezone

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: pdfUrl.isNotEmpty
                        ? () {
                            print(
                                'SyllabusActivity: Tapped item #$index - Navigating to PDFViewerPage with url: $pdfUrl');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PDFViewerPage(pdfUrl: pdfUrl),
                              ),
                            );
                          }
                        : () {
                            print(
                                'SyllabusActivity: PDF URL is empty! Cannot open PDF.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PDF URL is unavailable.'),
                              ),
                            );
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.blue.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset:
                                const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.redAccent,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No syllabus available.',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the search bar widget with animation
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by class...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
