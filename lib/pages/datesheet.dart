import 'package:PIL/pages/pdf_viewer_page.dart';
import 'package:PIL/pages/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatesheetActivity extends StatefulWidget {
  const DatesheetActivity({Key? key}) : super(key: key);

  @override
  State<DatesheetActivity> createState() => _DatesheetActivityState();
}

class _DatesheetActivityState extends State<DatesheetActivity> {
  late Future<List<dynamic>> _datesheetData;
  List<dynamic> _allDatesheets = [];
  List<dynamic> _filteredDatesheets = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _datesheetData = fetchDatesheet();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch datesheet data from API
  Future<List<dynamic>> fetchDatesheet() async {
    print('DatesheetActivity: Fetching datesheet data...');
    try {
      final response = await http.get(
        Uri.parse('https://api-pil.site/api/auth/datesheet'),
      );

      print('DatesheetActivity: Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('DatesheetActivity: JSON response: $jsonResponse');

        if (jsonResponse['success'] == true) {
          print('DatesheetActivity: Datesheet fetch success!');
          _allDatesheets = jsonResponse['data'];
          _filteredDatesheets = _allDatesheets;
          return _allDatesheets;
        } else {
          throw Exception('Failed to load datesheet data: success == false');
        }
      } else {
        throw Exception(
            'Failed to connect to the server. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('DatesheetActivity: An error occurred: $e');
    }
  }

  // Safely parse string values
  String _parseString(dynamic value, {String fallback = "Not Provided"}) {
    if (value == null || value is! String) {
      return fallback;
    }
    return value;
  }

  // Helper to convert relative URL to full URL
  String getFullPdfUrl(String relativeUrl) {
    const baseUrl = 'http://51.20.118.153:3001/';
    return baseUrl + relativeUrl;
  }

  // Handle search input changes
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDatesheets = _allDatesheets;
      } else {
        _filteredDatesheets = _allDatesheets.where((datesheet) {
          String examName =
          _parseString(datesheet['examName'], fallback: '').toLowerCase();
          String className =
          _parseString(datesheet['class'], fallback: '').toLowerCase();
          return examName.contains(query) || className.contains(query);
        }).toList();
      }
    });
  }

  // Pull-to-refresh handler
  Future<void> _refreshDatesheet() async {
    setState(() {
      _datesheetData = fetchDatesheet();
    });
    await _datesheetData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: AppBar(
        title: const Text(
          'Datesheet',
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
        future: _datesheetData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('DatesheetActivity: Error - ${snapshot.error}');
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
            final datesheetList = _filteredDatesheets;
            if (datesheetList.isEmpty) {
              print('DatesheetActivity: No datesheets available.');
              // Display no data message
              return const Center(
                child: Text(
                  'No datesheet available.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              );
            }
            // Display the list of datesheets
            return RefreshIndicator(
              onRefresh: _refreshDatesheet,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: datesheetList.length,
                itemBuilder: (context, index) {
                  final datesheet = datesheetList[index];
                  final examName =
                  _parseString(datesheet['examName'], fallback: 'Untitled');
                  final className =
                  _parseString(datesheet['class'], fallback: 'N/A');
                  final date =
                  _parseString(datesheet['date'], fallback: 'N/A');
                  final pdfUrl =
                  getFullPdfUrl(_parseString(datesheet['pdf'], fallback: ''));

                  print(
                      'DatesheetActivity: Item #$index -> Exam: $examName, PDF URL: $pdfUrl');

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
                              'DatesheetActivity: Opening PDF - $pdfUrl');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PDFViewerPage(pdfUrl: pdfUrl),
                            ),
                          );
                        }
                            : () {
                          print('DatesheetActivity: PDF URL is empty!');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('PDF URL is unavailable.'),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        examName,
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
                                            Icons.class_,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            className,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
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
            // Fallback for unexpected states
            return const Center(
              child: Text(
                'No datesheet available.',
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
        hintText: 'Search by exam or class...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
