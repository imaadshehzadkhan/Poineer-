// ./lib/main.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:PIL/pages/contactus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For loading indicators
import 'package:path_provider/path_provider.dart'; // For getting directory
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening files

// Entry Point
void main() {
  runApp(MyApp());
}

// MyApp Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admission Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Ensure you have the Poppins font added
      ),
      home: LoginPage(),
    );
  }
}

// Login Page Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  Map<String, String> formData = {'email': '', 'password': ''};
  bool isLoading = false;
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkToken();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Start slightly below
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check if token exists and navigate to AdmissionProcessPage
  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdmissionProcessPage()),
      );
    }
  }

  // Handle Login
  Future<void> _handleLogin() async {
    if (formData['email']!.isEmpty || formData['password']!.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = 'https://api-pil.site/api/auth/login'; // Ensure this endpoint is correct

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      );

      print('📡 Login Response Status: ${response.statusCode}');
      print('📡 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null && data['data']['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['data']['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdmissionProcessPage()),
          );
        } else {
          setState(() {
            errorMessage = 'Invalid login credentials.';
          });
        }
      } else {
        // Attempt to parse error message from backend
        String backendError = 'Login failed. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            backendError = errorData['message'];
          }
        } catch (_) {}
        setState(() {
          errorMessage =
          'Error: ${backendError} (Status Code: ${response.statusCode})';
        });
      }
    } catch (e) {
      print('⚠️ Error during login: $e');
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                AssetImage('lib/assets/images/getstartedpage.png'), // Replace with your asset image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Animated Form Container
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(top: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        _buildTextField(
                          "Email",
                              (value) =>
                              setState(() => formData['email'] = value),
                          TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        _buildTextField(
                          "Password",
                              (value) =>
                              setState(() => formData['password'] = value),
                          TextInputType.text,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreenAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Text Field Widget
  Widget _buildTextField(String label, ValueChanged<String> onChanged,
      TextInputType keyboardType,
      {bool isPassword = false}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: Colors.black54, fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// AdmissionProcessPage Widget
class AdmissionProcessPage extends StatefulWidget {
  @override
  _AdmissionProcessPageState createState() => _AdmissionProcessPageState();
}

class _AdmissionProcessPageState extends State<AdmissionProcessPage> {
  bool loading = false;
  String? error;
  String applicationStatus = 'pending'; // "approved" / "rejected"

  @override
  void initState() {
    super.initState();
    _fetchRegistrationData();
  }

  // Fetch User Data
  Future<void> _fetchRegistrationData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          error = 'No token found. Please log in or register again.';
          loading = false;
        });
        return;
      }

      final url = Uri.parse('https://api-pil.site/api/auth/user'); // Ensure this endpoint is correct
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json', // Changed from 'Content-Type' to 'Accept'
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Fetch User Data Response Status: ${response.statusCode}');
      print('📡 Fetch User Data Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['userData'] != null &&
            data['userData']['applicationStatus'] != null) {
          setState(() {
            applicationStatus = data['userData']['applicationStatus'];
            loading = false;
          });
        } else {
          setState(() {
            applicationStatus = 'pending';
            loading = false;
          });
        }
      } else {
        // Attempt to parse error message from backend
        String backendError = 'Failed to fetch registration data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            backendError = errorData['message'];
          }
        } catch (_) {}
        setState(() {
          error =
          'Error: ${backendError} (Status Code: ${response.statusCode})';
          loading = false;
        });
      }
    } catch (err) {
      print('⚠️ Error fetching registration data: $err');
      setState(() {
        error = 'There was an issue fetching your application status.';
        loading = false;
      });
    }
  }

  // Logout Function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // Function to handle admit card download
  Future<void> _handleDownload() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          error = 'You are not authenticated. Please log in.';
          loading = false;
        });
        return;
      }

      final url = Uri.parse('https://api-pil.site/api/auth/admitCard'); // Ensure this endpoint is correct
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/pdf', // Changed to accept PDF
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Admit Card Response Status: ${response.statusCode}');
      print('📥 Admit Card Response Headers: ${response.headers}');
      // print('📥 Admit Card Response Body: ${response.body}'); // Not needed for binary data

      if (response.statusCode == 200) {
        // Save the PDF to device
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/admit_card.pdf');
        await file.writeAsBytes(bytes);
        print('📄 Admit Card saved at: ${file.path}');

        // Open the PDF file
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          setState(() {
            error = 'Could not open the admit card.';
          });
        }
      } else {
        // Attempt to parse error message from backend
        String backendError = 'Failed to download the admit card.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            backendError = errorData['message'];
          }
        } catch (_) {}
        setState(() {
          error = 'Error: ${backendError} (Status Code: ${response.statusCode})';
        });
      }
    } catch (err) {
      print('⚠️ Error downloading admit card: $err');
      setState(() {
        error = 'An error occurred while downloading the admit card.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Build Status Widget with Vertical Timeline
  Widget _buildStatusWidget() {
    return Column(
      children: [
        // Status Image
        Image.asset(
          applicationStatus == 'approved'
              ? 'lib/assets/images/approved.png'
              : applicationStatus == 'rejected'
              ? 'lib/assets/images/rejected.png'
              : 'lib/assets/images/pending.png', // Ensure all paths are correct
          height: 100,
        ),
        const SizedBox(height: 20),
        // Status Text
        Text(
          applicationStatus == 'approved'
              ? 'Congratulations!'
              : applicationStatus == 'rejected'
              ? 'We\'re Sorry'
              : 'Application Pending',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: applicationStatus == 'approved'
                ? Colors.green
                : applicationStatus == 'rejected'
                ? Colors.red
                : Colors.orange,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        // Status Description
        Text(
          applicationStatus == 'approved'
              ? 'Your application has been approved. We look forward to welcoming you!'
              : applicationStatus == 'rejected'
              ? 'Unfortunately, your application was not successful. Please try again next year.'
              : 'Your application is currently under review. We will notify you once a decision has been made.',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        // Custom Vertical Timeline
        _buildTimeline(),
        const SizedBox(height: 30),
        // Download Button for Approved Status
        if (applicationStatus == 'approved') _buildDownloadSection(),
        // Contact Support Section for Rejected Applications
        if (applicationStatus == 'rejected') _buildContactSupport(),
      ],
    );
  }

  // Build Timeline Widget
  Widget _buildTimeline() {
    List<Map<String, String>> timelineStages;

    switch (applicationStatus) {
      case 'approved':
        timelineStages = [
          {
            'label': 'Registration Submitted',
            'description': 'You have successfully registered for the exam.',
            'status': 'completed'
          },
          {
            'label': 'Application Approved',
            'description': 'Your application has been approved.',
            'status': 'completed'
          },
          {
            'label': 'Admit Card Available',
            'description': 'You can now download your admit card.',
            'status': 'completed'
          },
        ];
        break;
      case 'rejected':
        timelineStages = [
          {
            'label': 'Registration Submitted',
            'description': 'You have successfully registered for the exam.',
            'status': 'completed'
          },
          {
            'label': 'Application Rejected',
            'description': 'Your application has been rejected.',
            'status': 'completed'
          },
          {
            'label': 'Contact Support',
            'description': 'Please contact our support team for more details.',
            'status': 'rejected'
          },
        ];
        break;
      default:
        timelineStages = [
          {
            'label': 'Registration Submitted',
            'description': 'You have successfully registered for the exam.',
            'status': 'completed'
          },
          {
            'label': 'Application Is Pending',
            'description': 'Your application is under review.',
            'status': 'active'
          },
          {
            'label': 'Awaiting Final Decision',
            'description': 'Please wait for the final decision.',
            'status': 'pending'
          },
        ];
    }

    return Column(
      children: timelineStages.map((stage) {
        return _buildTimelineStage(
          label: stage['label']!,
          description: stage['description']!,
          status: stage['status']!,
        );
      }).toList(),
    );
  }

  // Build Individual Timeline Stage
  Widget _buildTimelineStage({
    required String label,
    required String description,
    required String status,
  }) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'completed':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'active':
        iconData = Icons.access_time;
        iconColor = Colors.blue;
        break;
      case 'rejected':
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.circle_outlined;
        iconColor = Colors.grey;
    }

    // Determine line height based on screen size for responsiveness
    double lineHeight = MediaQuery.of(context).size.height * 0.05; // Adjust as needed

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with connecting line
        Container(
          width: 40,
          child: Column(
            children: [
              Icon(
                iconData,
                color: iconColor,
                size: 30,
              ),
              // Connecting line (only if not the last stage)
              if (status != 'pending' && status != 'rejected')
                Container(
                  width: 2,
                  height: lineHeight,
                  color: Colors.green, // Green connecting line
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build Download Section with Gradient Button
  Widget _buildDownloadSection() {
    return Column(
      children: [
        Text(
          'Your Admit Card is Ready!',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Congratulations! Your application has been approved. You can now download your admit card below.',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Gradient Elevated Button
        ElevatedButton(
          onPressed: loading ? null : _handleDownload,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 80,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.transparent, // Make background transparent
            shadowColor: Colors.transparent, // Remove shadow
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFFB2FF59)], // Green gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8), // Match button radius
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
              child: loading
                  ? const SpinKitCircle(
                color: Colors.white,
                size: 20.0,
              )
                  : const Text(
                "Download Admit Card",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 10),
          Text(
            error!,
            style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // Build Contact Support Section for Rejected Applications
  Widget _buildContactSupport() {
    return Column(
      children: [
        Text(
          'Need Assistance?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade800,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Your application has been rejected. Please contact our support team for more details.',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactUsPage(), // Replace with your Contact Us activity
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Contact Us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

      ],
    );
  }

  // Function to launch support email
  Future<void> _launchSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@pioneerinstitute.in', // Replace with your support email
      queryParameters: {
        'subject': 'Admission Application Support',
        'body':
        'Hello,\n\nI need assistance with my admission application.\n\nThank you.'
      },
    );

    try {
      final url = emailUri.toString();
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        setState(() {
          error = 'Could not launch the email client.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred while launching the email client.';
      });
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission'),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: loading
              ? SpinKitFadingCircle(
            color: Colors.blue.shade700,
            size: 50.0,
          )
              : error != null
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildStatusWidget(),
          ),
        ),
      ),
    );
  }
}
