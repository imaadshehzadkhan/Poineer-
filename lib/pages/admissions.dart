import 'dart:io';
import 'dart:convert'; // For jsonDecode
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:PIL/pages/admissionprocess.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your next page
import 'package:PIL/pages/admissionprocess.dart';

class RegistrationFormPage extends StatefulWidget {
  const RegistrationFormPage({Key? key}) : super(key: key);

  @override
  State<RegistrationFormPage> createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Matches your React logic: sibling => "yes"/"no", sibling_studying => true/false
  bool hasSibling = false;

  String? globalMessage;
  String? fileError;

  // ---------- Controllers for All Fields ----------
  final TextEditingController classController = TextEditingController();
  final TextEditingController datedController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController dobDayController = TextEditingController();
  final TextEditingController dobMonthController = TextEditingController();
  final TextEditingController dobYearController = TextEditingController();
  final TextEditingController dobWordsController = TextEditingController();
  final TextEditingController lastSchoolAttendedController = TextEditingController();

  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController fatherProfessionController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController motherProfessionController = TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController guardianProfessionController = TextEditingController();

  final TextEditingController fatherContactController = TextEditingController();
  final TextEditingController motherContactController = TextEditingController();

  final TextEditingController residenceController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController tehsilController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController penNoController = TextEditingController();

  // Sibling fields
  final TextEditingController siblingNameController = TextEditingController();
  final TextEditingController siblingClassController = TextEditingController();

  // Account fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ---------- File Upload Setup ----------
  final int maxFileSize = 3 * 1024 * 1024; // 3MB
  final allowedImageTypes = ['image/jpeg', 'image/png', 'image/jpg'];
  final allowedDocTypes = [
    'image/jpeg',
    'image/png',
    'image/jpg',
    'application/pdf'
  ];

  /// Each key matches the React code & backend references
  Map<String, PlatformFile?> filesMap = {
    'dobCertificate': null,
    'bloodReport': null,
    'aadharCard': null,
    'passportPhotos': null,
    'marksCertificate': null,
    'schoolLeavingCert': null,
    'studentPhoto': null,
  };

  @override
  void dispose() {
    // Dispose text controllers
    classController.dispose();
    datedController.dispose();
    studentNameController.dispose();
    dobDayController.dispose();
    dobMonthController.dispose();
    dobYearController.dispose();
    dobWordsController.dispose();
    lastSchoolAttendedController.dispose();

    fatherNameController.dispose();
    fatherProfessionController.dispose();
    motherNameController.dispose();
    motherProfessionController.dispose();
    guardianNameController.dispose();
    guardianProfessionController.dispose();
    fatherContactController.dispose();
    motherContactController.dispose();

    residenceController.dispose();
    villageController.dispose();
    tehsilController.dispose();
    districtController.dispose();
    bloodGroupController.dispose();
    penNoController.dispose();

    siblingNameController.dispose();
    siblingClassController.dispose();

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ---------- File Picker Logic ----------
  Future<void> _pickFile(String fieldKey) async {
    // "passportPhotos" & "studentPhoto" are images only
    bool limitImages = (fieldKey == 'passportPhotos' || fieldKey == 'studentPhoto');

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: limitImages ? FileType.image : FileType.custom,
      allowedExtensions: limitImages ? null : ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;

      // Check file size
      if (picked.size > maxFileSize) {
        setState(() => fileError = 'File size should not exceed 3MB.');
        return;
      }

      // Check MIME type
      final mimeType = lookupMimeType(picked.path!);
      final allowed = limitImages ? allowedImageTypes : allowedDocTypes;

      if (mimeType == null || !allowed.contains(mimeType)) {
        setState(() => fileError = 'Invalid file type. Allowed: ${allowed.join(', ')}');
        return;
      }

      // If OK
      setState(() {
        filesMap[fieldKey] = picked;
        fileError = null;
      });
    }
  }

  // ---------- Submit Logic (Multipart) ----------
  Future<void> _submitForm() async {
    // Basic validation
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      globalMessage = null;
    });

    final url = Uri.parse('https://api-pil.site/api/auth/register');
    final request = http.MultipartRequest('POST', url);

    // ------------------
    // Text fields
    // ------------------
    request.fields['class'] = classController.text.trim();
    // Must be YYYY-MM-DD so Date.parse() on the backend passes Zod
    request.fields['dated'] = datedController.text.trim();

    request.fields['student_name'] = studentNameController.text.trim();
    request.fields['dob_day'] = dobDayController.text.trim();
    request.fields['dob_month'] = dobMonthController.text.trim();
    request.fields['dob_year'] = dobYearController.text.trim();
    request.fields['dob_in_words'] = dobWordsController.text.trim();
    request.fields['last_school_attended'] = lastSchoolAttendedController.text.trim();

    request.fields['father_name'] = fatherNameController.text.trim();
    request.fields['father_profession'] = fatherProfessionController.text.trim();
    request.fields['mother_name'] = motherNameController.text.trim();
    request.fields['mother_profession'] = motherProfessionController.text.trim();
    request.fields['guardian_name'] = guardianNameController.text.trim();
    request.fields['guardian_profession'] = guardianProfessionController.text.trim();
    request.fields['father_contact'] = fatherContactController.text.trim();
    request.fields['mother_contact'] = motherContactController.text.trim();

    request.fields['residence'] = residenceController.text.trim();
    request.fields['village'] = villageController.text.trim();
    request.fields['tehsil'] = tehsilController.text.trim();
    request.fields['district'] = districtController.text.trim();
    request.fields['blood_group'] = bloodGroupController.text.trim();
    request.fields['pen_no'] = penNoController.text.trim();

    // Sibling logic
    request.fields['sibling_studying'] = hasSibling ? 'true' : 'false';
    request.fields['sibling'] = hasSibling ? 'yes' : 'no';

    if (hasSibling) {
      request.fields['sibling_name'] = siblingNameController.text.trim();
      request.fields['sibling_class'] = siblingClassController.text.trim();
    }

    // Account details
    request.fields['email'] = emailController.text.trim();
    request.fields['password'] = passwordController.text.trim();

    // ------------------
    // Attach files
    // ------------------
    for (var entry in filesMap.entries) {
      final fieldKey = entry.key;
      final fileData = entry.value;

      if (fileData != null) {
        final filePath = fileData.path!;
        final file = File(filePath);
        final length = await file.length();

        final mime = lookupMimeType(filePath) ?? 'application/octet-stream';
        final splitted = mime.split('/');

        request.files.add(http.MultipartFile(
          fieldKey, // e.g., "dobCertificate"
          file.openRead(),
          length,
          filename: p.basename(filePath),
          contentType: MediaType(splitted.first, splitted.last),
        ));
      }
    }

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      // Print the server response to debug (optional)
      // print('Server response status: ${response.statusCode}');
      // print('Server response body: ${responseBody.body}');

      if (responseBody.body.isNotEmpty) {
        final decoded = jsonDecode(responseBody.body);

        // Check the 'success' field directly from the decoded response
        if (decoded['success'] == true) {
          // Success logic
          final token = decoded['token'];
          final msg = decoded['msg'] ?? 'Registration Successful!';

          // Store token in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          // Optionally set a success message
          setState(() => globalMessage = msg);

          // Navigate to the Admission Process Page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  LoginPage()),
          );
        } else {
          // Handle failure when success is false
          setState(() {
            globalMessage = decoded['msg'] ?? 'Registration failed. Please try again.';
          });
        }
      } else {
        setState(() {
          globalMessage = 'Empty response from the server. Please try again.';
        });
      }

    } catch (e) {
      setState(() {
        globalMessage = 'Error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------- UI Builders ----------
  Widget _buildTopImage() {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              // Replace with your actual image asset
              image: AssetImage('lib/assets/images/3.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 90,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: const [
                Text(
                  "REGISTRATION FORM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Session: 2025",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _sectionHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 35, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: Colors.black,
            margin: const EdgeInsets.only(top: 5),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        labelText,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? placeholder,
    String? Function(String?)? validator,
    bool readOnly = false,
    void Function()? onTap,
    int maxLength = 1000,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLength: maxLength > 0 ? maxLength : null,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator ??
                  (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: placeholder ?? label,
            counterText: '',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Radio field for siblings
  Widget _buildSiblingRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('If any sibling is studying in Pioneer Institute of Learning'),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Yes', style: TextStyle(fontFamily: 'Poppins')),
                value: true,
                groupValue: hasSibling,
                onChanged: (val) => setState(() => hasSibling = val ?? false),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No', style: TextStyle(fontFamily: 'Poppins')),
                value: false,
                groupValue: hasSibling,
                onChanged: (val) => setState(() => hasSibling = val ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilePickerRow(String label, String fieldKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickFile(fieldKey),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Choose File',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filesMap[fieldKey]?.name ?? 'No file selected',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: isLoading
                ? const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Register",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar for a full-screen effect
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopImage(),
            const SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Global messages (error or success)
                    if (globalMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: globalMessage!.contains('failed') ||
                              globalMessage!.contains('Error')
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          globalMessage!,
                          style: TextStyle(
                            color: globalMessage!.contains('failed') ||
                                globalMessage!.contains('Error')
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),

                    // Class & Dated
                    _buildTextInput(
                      label: 'Class in which Admission is sought',
                      controller: classController,
                    ),
                    _buildTextInput(
                      label: 'Dated',
                      controller: datedController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            // Force "YYYY-MM-DD" format
                            datedController.text = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                    ),

                    // Student Name
                    _buildTextInput(
                      label: 'Name of the Student',
                      controller: studentNameController,
                    ),

                    // DOB fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            label: 'D.O.B (DD)',
                            controller: dobDayController,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Enter day';
                              }
                              final day = int.tryParse(val);
                              if (day == null || day < 1 || day > 31) {
                                return 'Invalid day';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextInput(
                            label: 'D.O.B (MM)',
                            controller: dobMonthController,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Enter month';
                              }
                              final month = int.tryParse(val);
                              if (month == null || month < 1 || month > 12) {
                                return 'Invalid month';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextInput(
                            label: 'D.O.B (YYYY)',
                            controller: dobYearController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Enter year';
                              }
                              final year = int.tryParse(val);
                              // Basic range check: 1900 <= year <= current
                              if (year == null || year < 1900 || year > DateTime.now().year) {
                                return 'Invalid year';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    _buildTextInput(
                      label: 'In Words',
                      controller: dobWordsController,
                      placeholder: 'e.g. Thirteenth December Two Thousand Nine',
                    ),

                    _buildTextInput(
                      label: 'Name of School Last Attended',
                      controller: lastSchoolAttendedController,
                    ),

                    // Parent/Guardian
                    _sectionHeading('Parent/Guardian Details'),
                    _buildTextInput(
                      label: "Father's Name",
                      controller: fatherNameController,
                    ),
                    _buildTextInput(
                      label: "Father's Profession",
                      controller: fatherProfessionController,
                    ),
                    _buildTextInput(
                      label: "Mother's Name",
                      controller: motherNameController,
                    ),
                    _buildTextInput(
                      label: "Mother's Profession",
                      controller: motherProfessionController,
                    ),
                    _buildTextInput(
                      label: "Guardian's Name",
                      controller: guardianNameController,
                    ),
                    _buildTextInput(
                      label: "Guardian's Profession",
                      controller: guardianProfessionController,
                    ),

                    _sectionHeading('Emergency Contact'),
                    _buildTextInput(
                      label: "Father's Contact No.",
                      controller: fatherContactController,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter Father\'s Contact No.';
                        }
                        if (!RegExp(r'^\d{10,15}$').hasMatch(val)) {
                          return 'Must be 10-15 digits, numbers only';
                        }
                        return null;
                      },
                    ),
                    _buildTextInput(
                      label: "Mother's Contact No.",
                      controller: motherContactController,
                      keyboardType: TextInputType.phone,
                      // If optional, you can skip the 'isEmpty' check
                      validator: (val) {
                        if (val != null && val.isNotEmpty) {
                          if (!RegExp(r'^\d{10,15}$').hasMatch(val)) {
                            return 'Must be 10-15 digits, numbers only';
                          }
                        }
                        return null;
                      },
                    ),

                    _sectionHeading('Address'),
                    _buildTextInput(
                      label: 'Residence',
                      controller: residenceController,
                    ),
                    _buildTextInput(
                      label: 'Village/Town',
                      controller: villageController,
                    ),
                    _buildTextInput(
                      label: 'Tehsil',
                      controller: tehsilController,
                    ),
                    _buildTextInput(
                      label: 'District',
                      controller: districtController,
                    ),
                    _buildTextInput(
                      label: "Student's Blood Group",
                      controller: bloodGroupController,
                      placeholder: 'e.g. A+, B-, O+',
                    ),
                    _buildTextInput(
                      label: 'PEN No',
                      controller: penNoController,
                    ),

                    _sectionHeading('Sibling Details'),
                    _buildSiblingRadio(),
                    if (hasSibling) ...[
                      _buildTextInput(
                        label: 'Name of the Student (Sibling)',
                        controller: siblingNameController,
                      ),
                      _buildTextInput(
                        label: 'Class',
                        controller: siblingClassController,
                      ),
                    ],

                    _sectionHeading('Account & Authentication'),
                    _buildTextInput(
                      label: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextInput(
                      label: 'Password',
                      controller: passwordController,
                      isPassword: true,
                      // Replicate Zod's uppercase/lowercase/digit
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter Password';
                        }
                        final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
                        if (!regex.hasMatch(val)) {
                          return 'Password must include uppercase, lowercase, and a digit';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    _sectionHeading('Document Upload'),
                    const Text(
                      'Please upload the following documents (Max size: 3MB):',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 8),
                    if (fileError != null)
                      Text(
                        fileError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 12),

                    _buildFilePickerRow('D.O.B Certificate', 'dobCertificate'),
                    _buildFilePickerRow('Blood Group Report', 'bloodReport'),
                    _buildFilePickerRow('Aadhar Card (Xerox)', 'aadharCard'),
                    _buildFilePickerRow('Passport Size Photographs (06)', 'passportPhotos'),
                    _buildFilePickerRow('Marks Certificate of Previous Class', 'marksCertificate'),
                    _buildFilePickerRow('School Leaving Certificate', 'schoolLeavingCert'),
                    _buildFilePickerRow("Student's Recent Photograph", 'studentPhoto'),

                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),

                    // Final note
                    const Text(
                      "Note: Students must be accompanied by their parents at the time of Interview.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Document list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("✔ D.O.B certificate from competent authority.", style: TextStyle(fontFamily: 'Poppins')),
                        Text("✔ Blood Group Report / Weight / Height", style: TextStyle(fontFamily: 'Poppins')),
                        Text("✔ Aadhar Card (Xerox)", style: TextStyle(fontFamily: 'Poppins')),
                        Text("✔ Passport Size Photographs (06)", style: TextStyle(fontFamily: 'Poppins')),
                        Text("✔ Marks Certificate of Previous Class", style: TextStyle(fontFamily: 'Poppins')),
                        Text("✔ School Leaving Certificate", style: TextStyle(fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
