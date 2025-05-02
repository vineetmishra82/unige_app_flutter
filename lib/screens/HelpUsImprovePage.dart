import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import '../Other_data/Apis.dart';

class HelpUsImprovePage extends StatefulWidget {
  static String id = "HelpUsImprovePage";
  final String name;
  final String mobile;
  final String email;

  const HelpUsImprovePage({
    required this.name,
    required this.mobile,
    required this.email,
    super.key,
  });

  @override
  _HelpUsImprovePageState createState() => _HelpUsImprovePageState();
}

class _HelpUsImprovePageState extends State<HelpUsImprovePage> {
  bool showSpinner = false;
  String? selectedTopic;
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController specifyController = TextEditingController();

  final List<String> feedbackTopics = [
    'Survey design',
    'New feature suggestion',
    'Bug report',
    'Visual design',
    'Other (please specify)',
  ];

  @override
  void dispose() {
    feedbackController.dispose();
    specifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Text(
                "Help Us Improve!",
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(25),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff003060),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Your feedback is important to us. Please take a moment to "
                      "share your thoughts so we can continue enhancing your "
                      "experience with the app. Whether it’s a suggestion, a bug "
                      "report, or general input, your insights are highly valued.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.textScalerOf(context).scale(14),
                    color: const Color(0xff003060),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Feedback Topic Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Feedback Topic",
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff003060),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Feedback Topic Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dropdownMenuTheme: const DropdownMenuThemeData(
                      menuStyle: MenuStyle(
                        backgroundColor:
                        MaterialStatePropertyAll(Colors.white),
                      ),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: selectedTopic,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    hint: Text(
                      "Select a topic",
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(14),
                        color: const Color(0xff184B2A),
                      ),
                    ),
                    items: feedbackTopics.map((topic) {
                      return DropdownMenuItem<String>(
                        value: topic,
                        child: Text(
                          topic,
                          style: GoogleFonts.poppins(
                            fontSize:
                            MediaQuery.textScalerOf(context).scale(14),
                            color: const Color(0xff184B2A),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTopic = value;
                        if (value != 'Other (please specify)') {
                          specifyController.clear();
                        }
                      });
                    },
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Conditionally show “Please specify” box
              if (selectedTopic == 'Other (please specify)')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: specifyController,
                    decoration: InputDecoration(
                      labelText: 'Please specify',
                      hintText: 'Tell us more...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                        const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                      color: const Color(0xff184B2A),
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              // Feedback Details Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Feedback Details",
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff003060),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Feedback Details Textbox
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  controller: feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Enter your feedback here...",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                      color: const Color(0xff184B2A).withOpacity(0.5),
                    ),
                    contentPadding: const EdgeInsets.all(16.0),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.textScalerOf(context).scale(14),
                    color: const Color(0xff184B2A),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Submit Feedback Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    // 1️⃣ start spinner
                    setState(() => showSpinner = true);

                    // 2️⃣ determine topic (if “Other”, grab the specifyController.text)
                    final topic = selectedTopic == 'Other (please specify)'
                        ? specifyController.text.trim()
                        : selectedTopic;

                    final now = DateTime.now();
                    final formattedDate = '${now.day.toString().padLeft(2, '0')}-'
                        '${now.month.toString().padLeft(2, '0')}-'
                        '${now.year}';

                    // 3️⃣ build request body
                    final body = {
                      'name':          widget.name,
                      'email':         widget.email,
                      'mobile':        widget.mobile,
                      'feedbackTopic': topic,
                      'feedback':      feedbackController.text.trim(),
                      'dateOfSubmission' : formattedDate
                    };

                    try {
                     String url = Apis.submitUserFeedback();
                     print(url);
                     print(body);
                      final uri = Uri.parse(url);
                      final response = await http.post(
                        uri,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(body),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feedback submitted successfully')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error ${response.statusCode}: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Submission failed: $e')),
                      );
                    } finally {
                      // 6️⃣ stop spinner
                      setState(() => showSpinner = false);
                    }
                    },
                  child: Container(
                    height: 60.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                      color: const Color(0xff003060),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          "Submit Feedback",
                          style: GoogleFonts.poppins(
                            fontSize:
                            MediaQuery.textScalerOf(context).scale(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
