import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesActivity extends StatefulWidget {
  const MessagesActivity({Key? key}) : super(key: key);

  @override
  State<MessagesActivity> createState() => _MessagesActivityState();
}

class _MessagesActivityState extends State<MessagesActivity> {
  late Future<List<dynamic>> _messagesData;

  @override
  void initState() {
    super.initState();
    _messagesData = fetchMessages();
  }

  // Fetch messages from API
  Future<List<dynamic>> fetchMessages() async {
    print('MessagesActivity: Fetching messages data...');
    final response = await http.get(
      Uri.parse('https://api-pil.site/api/auth/messages'),
    );

    print('MessagesActivity: Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('MessagesActivity: JSON response: $jsonResponse');

      if (jsonResponse['success'] == true) {
        print('MessagesActivity: Messages fetch success!');
        return jsonResponse['data'];
      } else {
        throw Exception(
            'MessagesActivity: Failed to load messages data (success == false)');
      }
    } else {
      throw Exception(
          'MessagesActivity: Failed to connect to the server. Status: ${response.statusCode}');
    }
  }

  // Safely parse any dynamic value to a String, providing a fallback
  String _parseString(dynamic value, {String fallback = "Not Provided"}) {
    if (value == null || value is! String) {
      return fallback;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _messagesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('MessagesActivity: Error - ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            );
          } else if (snapshot.hasData) {
            final messagesList = snapshot.data!;
            if (messagesList.isEmpty) {
              print('MessagesActivity: No messages available.');
              return const Center(
                child: Text(
                  'No messages available.',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: messagesList.length,
              itemBuilder: (context, index) {
                final messageItem = messagesList[index];

                final title =
                _parseString(messageItem['title'], fallback: 'No Title');
                final content = _parseString(messageItem['content'],
                    fallback: 'No Content');
                final sentBy = _parseString(messageItem['sentBy'],
                    fallback: 'Unknown Sender');
                final targetAudience = _parseString(
                    messageItem['targetAudience'],
                    fallback: 'Unknown Audience');
                final sentAt = _parseString(messageItem['sentAt'],
                    fallback: 'Unknown Date');
                final attachment = _parseString(messageItem['attachment'],
                    fallback: '');

                return GestureDetector(
                  onTap: () {
                    _showFullMessageDialog(
                      context,
                      title: title,
                      content: content,
                      sentBy: sentBy,
                      targetAudience: targetAudience,
                      sentAt: sentAt,
                      attachment: attachment,
                    );
                  },
                  child: _buildEnhancedMessageCard(
                    title: title,
                    content: content,
                    sentBy: sentBy,
                    targetAudience: targetAudience,
                    sentAt: sentAt,
                    attachment: attachment,
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No messages available.',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the enhanced message item card with an improved design
  Widget _buildEnhancedMessageCard({
    required String title,
    required String content,
    required String sentBy,
    required String targetAudience,
    required String sentAt,
    required String attachment,
  }) {
    // Split sentAt into date and time if possible
    String date = sentAt;
    String time = '';
    try {
      DateTime parsedDate = DateTime.parse(sentAt);
      date = "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
      time =
      "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      // If parsing fails, keep sentAt as is
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadowColor: Colors.greenAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon Section
                  Container(
                    width: 50, // Reduced width
                    height: 50, // Reduced height
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.message,
                      color: Colors.black54,
                      size: 28, // Reduced icon size
                    ),
                  ),
                  const SizedBox(width: 16), // Reduced spacing
                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14, // Slightly smaller font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Content Preview
                        Text(
                          content,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10, // Smaller font size
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Date and Time Section
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 8, // Smaller font size
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time,
                                color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 8, // Smaller font size
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow Icon
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14, // Reduced icon size
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a dialog with the full message content with an improved design
  void _showFullMessageDialog(
      BuildContext context, {
        required String title,
        required String content,
        required String sentBy,
        required String targetAudience,
        required String sentAt,
        required String attachment,
      }) {
    // Split sentAt into date and time if possible
    String date = sentAt;
    String time = '';
    try {
      DateTime parsedDate = DateTime.parse(sentAt);
      date = "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
      time =
      "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      // If parsing fails, keep sentAt as is
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.white70],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Row(
                    children: [
                      const Icon(Icons.message,
                          color: Colors.black54, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                      color: Colors.greenAccent, thickness: 1, height: 20),

                  // Content Section
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12, // Reduced font size
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Info Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender and Audience Information
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.person,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'From: $sentBy\nAudience: $targetAudience',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12, // Reduced font size
                                color: Colors.red,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date and Time Information
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Date: $date',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12, // Reduced font size
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Time: $time',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12, // Reduced font size
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Attachment Section
                  if (attachment.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        print(
                            'MessagesActivity: Viewing attachment: $attachment');
                        // Implement attachment viewing functionality here
                      },
                      icon: const Icon(Icons.attachment),
                      label: const Text('View Attachment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  // Close Button
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
