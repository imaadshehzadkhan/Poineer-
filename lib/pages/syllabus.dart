import 'package:PIL/pages/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PIL/pages/pdf_viewer_page.dart'; // Ensure this page is properly implemented

class SyllabusActivity extends StatefulWidget {
  const SyllabusActivity({Key? key}) : super(key: key);

  @override
  State<SyllabusActivity> createState() => _SyllabusActivityState();
}

class _SyllabusActivityState extends State<SyllabusActivity> {
  late Future<List<dynamic>> _syllabusData;
  List<dynamic> _allSyllabi = [];
  List<dynamic> _filteredSyllabi = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syllabusData = fetchSyllabus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch syllabus from API
  Future<List<dynamic>> fetchSyllabus() async {
    print('SyllabusActivity: Fetching syllabus from API...');
    try {
      final response =
      await http.get(Uri.parse('https://api-pil.site/api/auth/syllabus'));

      print('SyllabusActivity: Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('SyllabusActivity: JSON response: $jsonResponse');

        if (jsonResponse['success'] == true) {
          print('SyllabusActivity: Syllabus fetch success!');
          _allSyllabi = jsonResponse['data'];
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
    } catch (e) {
      throw Exception('SyllabusActivity: An error occurred: $e');
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
          String title =
          _parseString(syllabus['title'], fallback: '').toLowerCase();
          return title.contains(query);
        }).toList();
      }
    });
  }

  // Pull-to-refresh handler
  Future<void> _refreshSyllabus() async {
    setState(() {
      _syllabusData = fetchSyllabus();
    });
    await _syllabusData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: AppBar(
        title: const Text(
          'Syllabus',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.greenAccent,
        elevation: 4,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _syllabusData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display error message
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final syllabusList = _filteredSyllabi;
            if (syllabusList.isEmpty) {
              return const Center(
                child: Text(
                  'No syllabus available.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshSyllabus,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: syllabusList.length,
                itemBuilder: (context, index) {
                  final syllabus = syllabusList[index];
                  final className =
                  _parseString(syllabus['class'], fallback: 'Untitled');
                  final uploadedAt =
                  _parseString(syllabus['createdAt'], fallback: 'N/A');
                  final pdfUrl =
                  getFullPdfUrl(_parseString(syllabus['pdfUrl'], fallback: ''));

                  // Split date and time
                  final parts = uploadedAt.split('T');
                  final date = parts.isNotEmpty ? parts[0] : 'N/A';
                  final time = parts.length > 1 ? parts[1].split('.')[0] : 'N/A';

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
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
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        className,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            time,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text(
                'No syllabus available.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the static search bar widget
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by syllabus title...',
        prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0), // Rectangular corners
          borderSide: const BorderSide(
            color: Colors.greenAccent, // Border color
            width: 2.0, // Border width
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0), // Rectangular corners
          borderSide: const BorderSide(
            color: Colors.greenAccent, // Border color
            width: 2.0, // Border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0), // Rectangular corners
          borderSide: const BorderSide(
            color: Colors.green, // Border color when focused
            width: 2.0, // Border width
          ),
        ),
        // Add a clear button when there's input
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            _searchController.clear();
            FocusScope.of(context).unfocus();
          },
        )
            : null,
      ),
    );
  }
}
