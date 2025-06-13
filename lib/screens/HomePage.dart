import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:record/record.dart' hide AudioRecorder;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/HelpUsImprovePage.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Other_data/Apis.dart';
import '../Other_data/AudioPlayer.dart';
import '../Other_data/AudioRecorder.dart';
import '../Other_data/Camera.dart';
import '../Other_data/VideoPlayer.dart';
import 'EVLandingPage.dart';
import 'LandingPage.dart';

class HomePage extends StatefulWidget {
  static String id = "HomePage";
  String mobileNum;
  HomePage(this.mobileNum, {super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool showSpinnerRegisterProduct = false,
      showSpinner = false,
      showSpinnerMyFeedback = false,
      showSpinnerMyProfile = false,
      showSpinnerMyProducts = false;
  Color color = Colors.orange;
  final recorder = Record;

  String name = "",
      email = "",
      mobile = ApplicationData.mobile,
      myProductBrand = "",
      feedbackType = "Next Feedback",
      lastTitle = "LoadLastLine",
      goingForwardMessage = "";

  var myProductSelected;
  String? productSelected, month, year, type, minutes, seconds, fileType;
  int superIndex = 0;
  var products = <String>[];
  var productsObjects = [];
  List<dynamic> myProducts = [];
  List<dynamic> surveys = [];
  List<dynamic> allSurveys = [];
  Map<String, dynamic> ratings = {};
  Map<String, dynamic> checkBoxes = {};
  List<String> years = <String>[];
  List<String> months = <String>[];
  List<String> responseArray = <String>[
    "Very Poor",
    "Poor",
    "Average",
    "Good",
    "Very Good"
  ];
  bool apiResult = true;
  int questionIndex = 0;
  int startIndex = 0, endIndex = 0, len = 0;
  String userInput = "";
  bool pressed1 = true,
      pressed2 = false,
      userDataLoaded = false,
      ratingsArrayLoaded = false,
      checkBoxArrayLoaded = false,
      showRegistrationPage = false,
      showFeedback = false,
      isRecorderReady = false,
      isPlaying = false,
      isDefectSurvey = false,
      isFirstRegistration = false,
      isSurveyComplete = false;

  Map<int, Set<String>> selectedCheckboxes = {};

  var featureList = {};
  int val = 3, tabIndex = 0, qs2DefectSurveyLength = -1;

  bool showThankyouMessage = false,
      showRecording = false,
      showAudioPlayer = false,
      showCamera = false;

  int urlId = 1;

  bool showTitleLineNow = true;
  late TabController tabController;
  Map<int, List<bool>> isSelected = {};
  IconData icon = Icons.mic;
  late Size size;
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record;

  bool goToHome = false;

  bool isRecording = false;

  //Navigation icon sizes
  double leftWidth = 40, leftHeight = 40, rightWidth = 40, rightHeight = 40;

  Map<int, bool> isDropdownFocusedMap =
      {}; // ✅ Stores focus state for each dropdown

  void _updateFocusState(int index, bool isFocused) {
    setState(() {
      isDropdownFocusedMap[index] = isFocused;
    });
  }

  @override
  void initState() {
    super.initState();
    mobile = widget.mobileNum;
    getUserDetails();
    loadAllSurveys();
    loadProducts();
    loadMyProducts();
    loadRatingsList();

    //   loadDefectSurveys();

    years = getYears();
    final currentYear = DateTime.parse(DateTime.now().toString());
    //   year = currentYear.year.toString();
//    getMonths();
    tabController = TabController(length: 3, vsync: this);
    obtainAuthenticatedClient();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(size.height * .08),
              child: SafeArea(
                child: AppBar(
                  backgroundColor: Colors.white,
                  toolbarHeight: 50,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'images/logo.png',
                          height: 50,
                          width: size.width * 0.4, // Ensures proper scaling
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          logout();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: size.width * .2),
                          child: Image.asset(
                            'images/logout.png',
                            alignment: Alignment.bottomRight,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: TabBarView(
                controller: tabController,
                children: [
                  MyProductsPage(context),
                  MyFeedback(context),
                  MyProfile(context)
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: const Color(0xff003060),
              child: TabBar(
                controller: tabController,
                labelStyle: GoogleFonts.roboto(
                    fontSize: MediaQuery.textScalerOf(context).scale(14)),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset("images/myProducts.png"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset("images/myFeedback.png"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset("images/myProfile.png"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences loginCheck = await SharedPreferences.getInstance();

    loginCheck.setBool("isLoggedIn", false);
    loginCheck.setString("LoginMobileInThisSuperliciousApp", "");
    loginCheck.setString("CountryCodeISO", "");
  }

  MyProfile(context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        inAsyncCall: showSpinnerMyProfile,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity, // Full width (end-to-end)
                height: 15, // Line weight (thickness)
                color: Color(0xFF2296F3), // Line color
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Settings",
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(25),
                      fontWeight: FontWeight.bold,
                      color: Color(0xff003060),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Profile details",
                    style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                        fontWeight: FontWeight.bold,
                        color: Color(0xff003060)),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/profile.png',
                      height: 40.0,
                    ),
                    SizedBox(width: 20),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                        color: Color(0xff003060),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/mobile.png',
                      height: 40.0,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "+${widget.mobileNum}",
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                        color: Color(0xff003060),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/email.png',
                      height: 40.0,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                        color: Color(0xff003060),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 28.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "About QualTrack",
                    style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                        fontWeight: FontWeight.bold,
                        color: Color(0xff003060)),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LandingPageDetail(widget.mobileNum)));
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/info.png',
                        height: 40.0,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "About Us",
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.textScalerOf(context).scale(18),
                          color: Color(0xff003060),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    urlId = 2;
                  });
                  _launchUrl();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/question.png',
                        height: 40.0,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Frequently Asked Questions",
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.textScalerOf(context).scale(18),
                          color: Color(0xff003060),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    urlId = 3;
                  });
                  _launchUrl();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/dataPrivacy.png',
                        height: 40.0,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Data Privacy",
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.textScalerOf(context).scale(18),
                          color: Color(0xff003060),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () {
                  final result =
                     Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        HelpUsImprovePage(
                          name: name,
                          email: email,
                          mobile: widget.mobileNum
                  )));
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/feedback.png',
                        height: 40.0,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Help Us Improve",
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.textScalerOf(context).scale(18),
                          color: Color(0xff003060),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (Platform.isIOS)...[
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () {
                  AlertDialog alert = AlertDialog(
                    backgroundColor: Colors.blue, // Consistent blue background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Are You Sure?",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.yellow, size: 24),
                      ],
                    ),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                        minWidth: 200, // Minimum for small screens
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Are you certain you want to delete your account? This action will permanently remove all your survey data and account details. To confirm, press 'Yes, I’m Sure.' If you selected this by mistake, press 'No' to return to your account.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                showSpinnerMyProfile = true; // Show spinner
                              });
                              Navigator.pop(context);
                              try {
                                print("Starting delete");
                                var url = Uri.parse(Apis.deleteUser(widget.mobileNum));
                                print(url);
                                var response = await http.delete(url);
                                print(response.body);

                                if (response.body=="true") {
                                  logout(); // Clear user session
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                        (route) => false, // Clear navigation stack
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Account deletion failed. Please try again."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }

                              } catch (e) {
                                Navigator.pop(context); // Close dialog


                              }finally{
                                print("reaced finally");
                                setState(() {
                                  showSpinnerMyProfile = false; // Hide spinner
                                });
                              }
                            }
                            ,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xff003060), // Dark blue button
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: showSpinnerMyProfile
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                "Yes, I’m Sure",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: showSpinnerMyProfile
                                ? null // Disable button during loading
                                : () {
                              Navigator.pop(context); // Close dialog
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xff003060), // Dark blue button
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "No",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )

                    ],
                  );

                  // Show dialog with safe context
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: !showSpinnerMyProfile, // Prevent dismissal during loading
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  }


                },
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/deleteProfile.png',
                        height: 40.0,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Delete My Account",
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.textScalerOf(context).scale(18),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ]


            ]),
      ),
    );
  }

  Future<void> getUserDetails() async {
    if (!mounted) {
      print("getUserDetails: Aborted, widget not mounted at ${DateTime.now()}");
      return;
    }
    print("in profile ApplicationData.mobile is ${widget.mobileNum}");
    print(
        "Getting user details as condition is ${widget.mobileNum.isNotEmpty && (name.isEmpty || email.isEmpty)}");
    if (widget.mobileNum.isNotEmpty && (name.isEmpty || email.isEmpty)) {
      final startTime = DateTime.now();
      setState(() {
        showSpinnerMyProfile = true;
        print("getUserDetails: showSpinnerMyProfile set to true at ${DateTime.now()}");
      });

      try {
        var url = Uri.parse(Apis.getUser(widget.mobileNum));
        print("getUserDetails: Fetching user details from $url at ${DateTime.now()}");
        var response = await http.get(url);
        Map<String, dynamic> values = json.decode(response.body);

        if (mounted) {
          setState(() {
            name = values["name"];
            email = values["email"];
            print("getUserDetails: name and email updated at ${DateTime.now()}");
            print("getUserDetails: Data received: $values");
          });
        } else {
          print("getUserDetails: Skipped name and email update, widget not mounted at ${DateTime.now()}");
        }

        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        const minDuration = 500; // Minimum spinner duration in ms
        if (elapsed < minDuration) {
          await Future.delayed(Duration(milliseconds: minDuration - elapsed));
        }

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                showSpinnerMyProfile = false;
                print("getUserDetails: showSpinnerMyProfile set to false at ${DateTime.now()}");
              });
            } else {
              print("getUserDetails: Skipped spinner hide, widget not mounted at ${DateTime.now()}");
            }
          });
        } else {
          print("getUserDetails: Skipped post-frame callback, widget not mounted at ${DateTime.now()}");
        }
      } catch (e) {
        print("Error in getUserDetails: $e at ${DateTime.now()}");
        if (mounted) {
          setState(() {
            showSpinnerMyProfile = false;
            print("getUserDetails: showSpinnerMyProfile set to false (error) at ${DateTime.now()}");
          });
        } else {
          print("getUserDetails: Skipped error handling, widget not mounted at ${DateTime.now()}");
        }
      }
    }
  }

  Future<void> loadProducts() async {
    if (!mounted) {
      print("loadProducts: Aborted, widget not mounted at ${DateTime.now()}");
      return;
    }
    final startTime = DateTime.now();
    setState(() {
      showSpinnerMyProducts = true;
      showSpinnerMyFeedback = true;
      print("loadProducts: showSpinnerMyProducts set to true at ${DateTime.now()}");
    });
    try {
      var response = await http.get(Uri.parse(Apis.getAllProducts()));
      productsObjects = json.decode(response.body);
      print("loadProducts: Processing ${productsObjects.length} products");
      List<String> tempProducts = [];
      for (var item in productsObjects) {
        String productName = item["productName"].toString();
        if (!tempProducts.contains(productName)) {
          tempProducts.add(productName);
        }
      }
      if (mounted) {
        setState(() {
          products = tempProducts;
          print("loadProducts: products updated at ${DateTime.now()}");
        });
      } else {
        print("loadProducts: Skipped products update, widget not mounted at ${DateTime.now()}");
      }
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      const minDuration = 1000; // Increased to 1000ms for visibility
      if (elapsed < minDuration) {
        await Future.delayed(Duration(milliseconds: minDuration - elapsed));
      }
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isLoadingMyProducts) { // Check if loadMyProducts is still running
            setState(() {
              showSpinnerMyProducts = false;
              showSpinnerMyFeedback = false;
              print("loadProducts: showSpinnerMyProducts set to false at ${DateTime.now()}");
            });
          } else {
            print("loadProducts: Skipped spinner hide, widget not mounted or loadMyProducts running at ${DateTime.now()}");
          }
        });
      } else {
        print("loadProducts: Skipped post-frame callback, widget not mounted at ${DateTime.now()}");
      }
    } catch (e) {
      print("Error in loadProducts: $e at ${DateTime.now()}");
      if (mounted) {
        setState(() {
          showSpinnerMyProducts = false;
          showSpinnerMyFeedback = false;
          print("loadProducts: showSpinnerMyProducts set to false (error) at ${DateTime.now()}");
        });
      } else {
        print("loadProducts: Skipped error handling, widget not mounted at ${DateTime.now()}");
      }
    }
  }

  MyFeedback(BuildContext context) {
    // 🧠 Check once per build frame to update global isSurveyComplete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        for (var product in myProducts) {
          if (product["active"] == true &&
              product["currentMainSurvey"]?["surveyId"] == "Done") {
            setState(() {
              isSurveyComplete = true;
            });

            break; // no need to keep checking once we find one
          } else {
            setState(() {
              isSurveyComplete = false;
            });
          }
        }

      } on Exception catch (e) {
        // TODO
      }


    });

    if (showThankyouMessage) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: (Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              processThankYouText(surveys[0]["thankYouText"]),
              style: TextStyle(
                  fontSize: MediaQuery.textScalerOf(context).scale(18),
                  color: Colors.pink),
            ),
            Material(
              color: Colors.blue,
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              elevation: 2.0,
              child: MaterialButton(
                onPressed: () async {
                    setState(() {
                      showThankyouMessage = false;
                      showFeedback = false;
                      showRegistrationPage = false;
                      showSpinnerMyProducts = true;
                      showSpinner = true;
                      showSpinnerMyFeedback = true;
                      goToHome = true;
                    });
                    //   loadMyProducts();
                },
                minWidth: 50.0,
                height: 32.0,
                child: Text(
                  'Continue',
                  style: TextStyle(
                      fontSize: MediaQuery.textScalerOf(context).scale(14)),
                ),
              ),
            ),
          ],
        )),
      );
    } else if (showRecording) {
      return getRecordingApparatus();
    } else if (showAudioPlayer) {
      return getAudioPlayerApparatus();
    } else if (showFeedback) {
        return startFeedback();
    } else if (goToHome) {
      tabController.animateTo(0);

      goToHome = false;
      return (MyFeedback(context));
    } else if (ApplicationData.showVideoPlayer) {
      return getVideoPlayerApparatus();
    } else {
      return ModalProgressHUD(
        inAsyncCall: showSpinnerMyFeedback,
        color: Colors.green,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent infinite height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSurveyComplete ? "" : "My Feedback",
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(25),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff003060),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    isSurveyComplete
                        ? ""
                        : "In this section, you can check the status of your feedback or report a recent issue.\nTo report an incident, simply click on Report a problem.",
                    style: GoogleFonts.poppins(
                      color: const Color(0xff003060),
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Product Rows
                for (var product in myProducts)
                  if (product["active"] == true)
                    product["currentMainSurvey"]["surveyId"] == "Done"
                        ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Text(
                        processResponse(ApplicationData
                            .thankYouMessages[product["shortName"]]) ??
                            "",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize:
                          MediaQuery.textScalerOf(context).scale(20),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            color: const Color(0xff003060),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen =
                                    constraints.maxWidth < 400;
                                final baseFontSize =
                                isSmallScreen ? 10.0 : 12.0;
                                final buttonWidth =
                                    constraints.maxWidth * 0.25;
                                final nameWidth = constraints.maxWidth * 0.45;

                                return Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: nameWidth,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            product["shortName"],
                                            style: GoogleFonts.poppins(
                                              fontSize: MediaQuery
                                                  .textScalerOf(context)
                                                  .scale(baseFontSize),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (product["active"] == true)
                                      Flexible(
                                        flex: 1,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: buttonWidth,
                                          ),
                                          child: SetDefectReportAndGetWidget(
                                              product, baseFontSize),
                                        ),
                                      ),
                                    if (product["active"] == true)
                                      const SizedBox(width: 4),
                                    if (product["active"] == true)
                                      Flexible(
                                        flex: 1,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: buttonWidth,
                                          ),
                                          child:
                                          checkForActiveFeedbackAndGetWidget(
                                              product, baseFontSize),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
              ],
            ),
          ),
        ),
      );
    }
  }

  RegisterProduct(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinnerRegisterProduct,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        child: ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                            ),
                            child: const Icon(Icons.home,
                                size: 35, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                showRegistrationPage = false;
                                productSelected = null;
                                featureList = {};
                              });
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 55,
                            ),
                            Text(
                              "Product",
                              style: GoogleFonts.poppins(
                                  color: Color(0xff003060),
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(16),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 54.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: productSelected != null
                                    ? Colors.blue
                                    : Colors
                                        .black, // ✅ Changes to blue when selected
                                width: 2.0,
                              ), // Black thin border
                              borderRadius: BorderRadius.circular(
                                  6), // Slightly rounded corners
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 1), // Padding inside the box
                            child: DropdownButtonHideUnderline(
                              // Removes the default underline
                              child: DropdownButton<String>(
                                isExpanded: true, // ✅ Prevents UI overflow
                                style: GoogleFonts.poppins(
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(15),
                                  color: const Color(0xff003060),
                                ),

                                icon: const Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                iconEnabledColor: Color(0xff3AB7A6),

                                hint: Text(
                                  "Please Select",
                                  style: GoogleFonts.poppins(
                                    fontSize: MediaQuery.textScalerOf(context)
                                        .scale(15),
                                    color: Color(0xff003060),
                                  ),
                                ),

                                // ✅ Ensure non-null and unique list
                                items: (products.isEmpty
                                        ? ["Loading..."]
                                        : products
                                            .toSet()
                                            .toList()) // ✅ Ensure uniqueness
                                    .map((String prod) {
                                  return DropdownMenuItem(
                                    value: prod,
                                    child: Text(
                                      prod,
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            MediaQuery.textScalerOf(context)
                                                .scale(15),
                                        color: Color(0xff003060),
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (String? newValue) {
                                  setState(() {
                                    productSelected = newValue;
                                    loadFeaturesListForSelectedProduct();
                                  });
                                },

                                // ✅ Only set `productSelected` if it's in the list
                                value: products.contains(productSelected)
                                    ? productSelected
                                    : null,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              generateFeaturesList(),
            ]),
          ),
        ));
  }

  generateFeaturesList() {
    if (featureList.isNotEmpty) {
      return Column(
        children: [
          for (int i = 0; i < featureList.length; i++) ...[
            const SizedBox(
              height: 5,
            ),
            getChildOfFeaturesList(i),
          ],
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Material(
                color: Color(0xff003060),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (allRegisterFieldsOk()) {
                      AlertDialog alert = AlertDialog(
                        backgroundColor: Colors.blue,
                        title: Text("Confirm"),
                        content: Text(
                          "Please check all fields before registering your product. You will not"
                          " be able to change it later.\n\n Do you wish to register the product ?",
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // Space buttons evenly
                            children: [
                              GestureDetector(
                                onTap: () async {

                                  Navigator.pop(context);
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    showSpinnerRegisterProduct = true;
                                  });
                                  var url = Uri.parse(Apis.registerProduct(
                                      productSelected.toString(),
                                      widget.mobileNum));
                                  print(url);
                                  print(jsonEncode(featureList));
                                  var response = await http.post(url,
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(featureList));

                                  if (response.body == "true") {
                                    await loadMyProducts();
                                    var prodName = "$productSelected-" +
                                        featureList["Brand"];
                                    bool isElectricTwoWheeler = productSelected
                                        .toString()
                                        .toLowerCase()
                                        .contains("electric vehicle".toLowerCase());
                                    if (isFirstRegistration) {
                                      setState(() {
                                        myProductSelected =
                                            getProduct(prodName);

                                        if (!isElectricTwoWheeler) {
                                          startSurveyProcess(myProductSelected[
                                              "currentMainSurvey"]);
                                          isDefectSurvey = false;
                                          isFirstRegistration = false;
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        showThankyouMessage = false;
                                        showFeedback = false;
                                        showRegistrationPage = false;
                                      });
                                    }

                                    AlertDialog successAlert = AlertDialog(
                                      backgroundColor:
                                          Colors.blue, // ✅ Set background color
                                      title: Text(
                                        "Success",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .white, // ✅ Title text color
                                        ),
                                      ),
                                      content: Text(
                                        "Thank you for registering your ${productSelected.toString().toLowerCase()}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors
                                              .white, // ✅ Content text color
                                        ),
                                      ),
                                      actions: [
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              month = null;
                                              year = null;
                                            });

                                            tabController.animateTo(1);
                                            Navigator.pop(context);

                                            if (isElectricTwoWheeler) {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const EVLandingPage()),
                                              );

                                              if (result == true &&
                                                  isFirstRegistration) {
                                                setState(() {
                                                  startSurveyProcess(
                                                      myProductSelected[
                                                          "currentMainSurvey"]);
                                                  isDefectSurvey = false;
                                                  isFirstRegistration = false;
                                                });
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Color(
                                                  0xff003060), // ✅ Button color
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // ✅ Rounded corners
                                            ),
                                            child: Text(
                                              "Continue",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .white, // ✅ Button text color
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return successAlert;
                                        });

                                    setState(() {
                                      showSpinnerRegisterProduct = false;
                                    });
                                  } else {
                                    setState(() {
                                      showSpinner = false;
                                      showSpinnerMyFeedback = false;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Color(0xff003060), // Button color
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  child: Text(
                                    "Register",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Color(0xff003060), // Button color
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          });
                    } else {
                      print("coming to this else 1172");
                      AlertDialog alert = AlertDialog(
                        backgroundColor: Colors.blue, // ✅ Background color
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Oops! Missing Info",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // ✅ Title text color
                              ),
                            ),
                            SizedBox(width: 8), // ✅ Spacing
                            Icon(Icons.warning, color: Colors.yellow, size: 30),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize
                              .min, // ✅ Prevents unnecessary spacing
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // ✅ Aligns content to the left
                          children: [
                            Text(
                              "We need all fields filled out to continue.",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white, // ✅ Content text color
                              ),
                            ),
                            SizedBox(
                                height:
                                    20), // ✅ Space between text and checklist
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(Icons.check_box,
                                            color: Colors.green,
                                            size: 18), // Green box
                                        Icon(Icons.check,
                                            color: Colors.white,
                                            size: 14), // White tick on top
                                      ],
                                    ), // ✅ Check Icon
                                    SizedBox(width: 8), // ✅ Spacing
                                    Text(
                                      "Check your info",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white, // ✅ Text color
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height:
                                        5), // ✅ Spacing between checklist items
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(Icons.check_box,
                                            color: Colors.green,
                                            size: 18), // Green box
                                        Icon(Icons.check,
                                            color: Colors.white,
                                            size: 14), // White tick on top
                                      ],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Fill in the missing parts",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(Icons.check_box,
                                            color: Colors.green,
                                            size: 18), // Green box
                                        Icon(Icons.check,
                                            color: Colors.white,
                                            size: 14), // White tick on top
                                      ],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Try again!",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Color(0xff003060), // ✅ Button color
                                  borderRadius: BorderRadius.circular(
                                      20), // ✅ Rounded corners
                                ),
                                child: Text(
                                  "Go Back",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // ✅ Button text color
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          });
                    }
                  },
                  minWidth: 200.0,
                  height: 52.0,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                        color: Colors.white),
                  ),
                ),
              ))
        ],
      );
    }
    if (products.length <= 0) {
      return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(
          "No values to input",
          style: TextStyle(
              color: Colors.red,
              fontSize: MediaQuery.textScalerOf(context).scale(18)),
        ),
      ]);
    }
    return Column(
      children: [],
    );
  }

  loadFeaturesListForSelectedProduct() {
    featureList = {};
    var data = [];

    for (var prods in productsObjects) {
      if (prods["productName"] == productSelected) {
        prods["features"].forEach((key, value) {
          data.add(key);
        });
      }
    }

    // print("data is " + data.toString());

    for (var element in data) {
      featureList[element] = "";
    }

    // featureList.forEach((key, value) {});
  }

  bool _isLoadingMyProducts = false; // Add to _HomePageState

  Future<void> loadMyProducts() async {
    if (!mounted) {
      print("loadMyProducts: Aborted, widget not mounted at ${DateTime.now()}");
      return;
    }
    _isLoadingMyProducts = true;
    final startTime = DateTime.now();
    setState(() {
      showSpinnerMyProducts = true;
      showSpinnerMyFeedback = true;
      print("loadMyProducts: showSpinnerMyProducts set to true at ${DateTime.now()}");
    });
    try {
      List<dynamic> tempProducts = [];
      var url = Uri.parse(Apis.getUserProducts(widget.mobileNum));
      print(url);
      var response = await http.get(url);
      var data = json.decode(response.body);
      print("loadMyProducts: Processing ${data.length} products");

      for (var element in data) {
        tempProducts.add(element);
        url = Uri.parse(Apis.getThankyouMessage(element["shortName"]));
        print(url);
        response = await http.get(url);
        ApplicationData.thankYouMessages[element["shortName"]] = response.body;
      }

      if (mounted) {
        setState(() {
          myProducts = tempProducts;
          if (myProducts.isNotEmpty) {
            myProductSelected = myProducts[0];
            final brandStart = DateTime.now();
            setBrand(myProductSelected);
            print("loadMyProducts: setBrand took ${DateTime.now().difference(brandStart).inMilliseconds}ms");
          }
          print("loadMyProducts: myProducts updated at ${DateTime.now()}");
        });
      } else {
        print("loadMyProducts: Skipped myProducts update, widget not mounted at ${DateTime.now()}");
      }

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      const minDuration = 1000; // Increased to 1000ms
      if (elapsed < minDuration) {
        await Future.delayed(Duration(milliseconds: minDuration - elapsed));
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              showSpinnerMyProducts = false;
              showSpinnerMyFeedback = false;
              showSpinner = false;
              print("loadMyProducts: showSpinnerMyProducts set to false at ${DateTime.now()}");
            });
          } else {
            print("loadMyProducts: Skipped spinner hide, widget not mounted at ${DateTime.now()}");
          }
        });
      } else {
        print("loadMyProducts: Skipped post-frame callback, widget not mounted at ${DateTime.now()}");
      }
    } catch (e) {
      print("Error in loadMyProducts: $e at ${DateTime.now()}");
      if (mounted) {
        setState(() {
          showSpinnerMyProducts = false;
          showSpinnerMyFeedback = false;

          print("loadMyProducts: showSpinnerMyProducts set to false (error) at ${DateTime.now()}");
        });
      } else {
        print("loadMyProducts: Skipped error handling, widget not mounted at ${DateTime.now()}");
      }
    } finally {
      _isLoadingMyProducts = false;
    }
  }

  checkForFeedback() {
    if (apiResult && widget.mobileNum != "") {
      loadMyProducts();
      apiResult = false;
    }
    surveys = [];

    if (feedbackType == "Next Feedback") {
      for (var prod in myProducts) {
        for (var survey in prod["surveys"]) {
          if (survey["next"] == true &&
              survey["complete"] == false &&
              survey["defectSurvey"] == false &&
              prod["productName"].toString() == myProductSelected) {
            survey = purgeSurveyFromOldAnswers(survey);
            surveys.add(survey);
            endIndex = 0;
            startIndex = 0;
            questionIndex = 0;
          }
        }
      }

      // print("surveys length is " + surveys.length.toString());

      if (surveys.isEmpty) {
        return Container(
          color: Color(0xff003060),
          child: Text(
            "No pending feedback",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: MediaQuery.textScalerOf(context).scale(14)),
          ),
        );
      }

      return Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "You have a pending feedback.",
                  style: TextStyle(
                    fontSize: MediaQuery.textScalerOf(context).scale(14),
                    color: Colors.blue,
                  ),
                ),
                Material(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  elevation: 2.0,
                  child: MaterialButton(
                    onPressed: () async {},
                    minWidth: 50.0,
                    height: 32.0,
                    child: Text(
                      'Start Feedback',
                      style: TextStyle(
                          fontSize: MediaQuery.textScalerOf(context).scale(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    } else if ((feedbackType == "Report Defect")) {
      for (var prod in myProducts) {
        for (var survey in prod["surveys"]) {
          if (survey["next"] == true &&
              survey["complete"] == false &&
              survey["defectSurvey"] == true &&
              prod["productName"].toString() == myProductSelected) {
            survey = purgeSurveyFromOldAnswers(survey);
            surveys = [];
            surveys.add(survey);
            endIndex = 0;
            startIndex = 0;
            questionIndex = 0;
          }
        }
      }

      if (surveys.isEmpty) {
        return Container(
          child: Text(
            "No pending feedback",
            style: TextStyle(
                color: Colors.red,
                fontSize: MediaQuery.textScalerOf(context).scale(18)),
          ),
        );
      }

      return Container(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  elevation: 2.0,
                  child: MaterialButton(
                    onPressed: () async {},
                    minWidth: 50.0,
                    height: 32.0,
                    child: Text(
                      'Start Defect Reporting',
                      style: TextStyle(
                          fontSize: MediaQuery.textScalerOf(context).scale(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }
  }

  getChildOfFeaturesList(int i) {
    if (featureList.keys.elementAt(i).toString().contains("Purchase Date")) {
      String selectedMonthYear = "MM-YY";
      return Column(
        children: [
          Row(
            children: [
              SizedBox(width: 55),
              Text(
                featureList.keys.elementAt(i),
                style: GoogleFonts.poppins(
                  color: Color(0xff003060),
                  fontSize: MediaQuery.textScalerOf(context).scale(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 54.0),
            child: GestureDetector(
              onTap: () {
                _pickMonthYear(context, i,
                    selectedMonthYear); // Open Month-Year Picker when tapped
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff003060), width: 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      featureList[featureList.keys.elementAt(i)] == ""
                          ? "Select Date"
                          : featureList[featureList.keys
                              .elementAt(i)], // Display selected month-year
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                        color: Color(0xff003060),
                      ),
                    ),
                    Icon(Icons.calendar_today,
                        color: Color(0xff003060), size: 20), // Calendar Icon
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (featureList.keys.elementAt(i).toString().contains("Price")) {
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 55,
              ),
              Text(
                featureList.keys.elementAt(i),
                style: GoogleFonts.poppins(
                    color: Color(0xff003060),
                    fontSize: MediaQuery.textScalerOf(context).scale(16),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 54.0),
            child: GestureDetector(
              onTap: () {
                print('Clicked outside');
                FocusScope.of(context).unfocus();
              },
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  featureList[featureList.keys.elementAt(i)] = value;
                },
                style: GoogleFonts.poppins(
                    fontSize: MediaQuery.textScalerOf(context).scale(15),
                    color: Color(0xff003060)),
                decoration: InputDecoration(
                  enabled: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff003060), width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (featureList.keys
        .elementAt(i)
        .toString()
        .contains("Purchase Type")) {
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 55,
              ),
              Text(
                "Purchase Type",
                style: GoogleFonts.poppins(
                    color: Color(0xff003060),
                    fontSize: MediaQuery.textScalerOf(context).scale(16),
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 54.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: productSelected != null
                      ? Colors.blue
                      : Colors.black, // ✅ Changes to blue when selected
                  width: 2.0,
                ), // Black thin border
                borderRadius:
                    BorderRadius.circular(6), // Slightly rounded corners
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 10, vertical: 1), // Padding inside the box
              child: DropdownButtonHideUnderline(
                // Removes the default underline
                child: DropdownButton(
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.textScalerOf(context).scale(16),
                    color: const Color(0xff003060),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 24,
                  iconEnabledColor: Color(0xff003060),
                  hint: Text(
                    "Please Select",
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(15),
                      color: Color(0xff003060),
                    ),
                  ),
                  items: ['New Product', 'Used Product'].map((String prod) {
                    return DropdownMenuItem(
                      value: prod,
                      child: Text(
                        prod,
                        style: GoogleFonts.poppins(
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(15),
                            color: Color(0xff003060)),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      type = newValue!;
                    });
                    featureList[featureList.keys.elementAt(i)] = type;
                  },
                  value: type,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 55,
                ),
                Text(
                  featureList.keys.elementAt(i),
                  style: GoogleFonts.poppins(
                      color: Color(0xff003060),
                      fontSize: MediaQuery.textScalerOf(context).scale(16),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 54.0),
              child: GestureDetector(
                onTap: () {
                  print('Clicked outside');
                  FocusScope.of(context).unfocus();
                },
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    featureList[featureList.keys.elementAt(i)] = value;
                  },
                  style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                      color: Color(0xff003060)),
                  decoration: InputDecoration(
                    enabled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff003060), width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pickMonthYear(BuildContext context, int i, String selectedMonthYear) {
    showMonthPicker(
      context: context,
      firstDate: DateTime(2000), // Earliest year selectable
      lastDate: DateTime(2100), // Latest year selectable
      initialDate: DateTime.now(), // Default selected date
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedMonthYear = formatMonthYear(date.month, date.year);
          featureList[featureList.keys.elementAt(i)] =
              selectedMonthYear; // Store selected value
        });
      }
    });
  }

  String formatMonthYear(int month, int year) {
    String monthName;

    switch (month) {
      case 1:
        monthName = "Jan";
        break;
      case 2:
        monthName = "Feb";
        break;
      case 3:
        monthName = "Mar";
        break;
      case 4:
        monthName = "Apr";
        break;
      case 5:
        monthName = "May";
        break;
      case 6:
        monthName = "Jun";
        break;
      case 7:
        monthName = "Jul";
        break;
      case 8:
        monthName = "Aug";
        break;
      case 9:
        monthName = "Sep";
        break;
      case 10:
        monthName = "Oct";
        break;
      case 11:
        monthName = "Nov";
        break;
      case 12:
        monthName = "Dec";
        break;
      default:
        monthName = "Invalid";
    }

    return "$monthName $year";
  }

  List<String> getYears() {
    final currentYear = DateTime.parse(DateTime.now().toString());

    List<String> years = <String>[];

    for (int i = currentYear.year; i >= currentYear.year - 10; i--) {
      years.add(i.toString());
    }

    return years;
  }

 

  //This method groups questions based on title, main screen title, question title etc
  getQuestionAndResponse() {
    List<dynamic> currentSurvey = [];

    String mainScreenTitle = surveys[0]["feedbackQuestion"][questionIndex]
            ["mainScreentitle"]
        .toString();
    String titleLine =
        surveys[0]["feedbackQuestion"][questionIndex]["titleLine"].toString();

    String questionTitle = surveys[0]["feedbackQuestion"][questionIndex]
            ["questionTitle"]
        .toString();

    String answerType =
        surveys[0]["feedbackQuestion"][questionIndex]["answerType"];
    endIndex = 0;
    for (int i = 0; i < surveys[0]["feedbackQuestion"].length; i++) {
      String mst =
          surveys[0]["feedbackQuestion"][i]["mainScreentitle"].toString();
      String ttl = surveys[0]["feedbackQuestion"][i]["titleLine"].toString();

      String qst =
          surveys[0]["feedbackQuestion"][i]["questionTitle"].toString();

      String ansType =
          surveys[0]["feedbackQuestion"][i]["answerType"].toString();

      if (mst == mainScreenTitle && ttl == titleLine && qst == questionTitle) {
        currentSurvey.add(surveys[0]["feedbackQuestion"][i]);
        endIndex++;
        startIndex = i;
      }
    }

    //Setting indexes
    questionIndex = startIndex;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  processQuestion(surveys[0]["feedbackQuestion"][questionIndex]
                      ["mainScreentitle"]),
                  style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(26),
                      fontWeight: FontWeight.bold,
                      color: Color(0xff003060)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                processQuestion(surveys[0]["feedbackQuestion"][questionIndex]
                    ["questionTitle"]),
                overflow: TextOverflow.clip,
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(16),
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        for (int i = 0; i < currentSurvey.length; i++) ...[
          SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // ✅ Ensures left alignment
              children: [
                Align(
                  alignment: Alignment.centerLeft, // ✅ Forces left alignment
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width -
                          20, // ✅ Prevents overflow
                    ),
                    child: Text(
                      processQuestion(currentSurvey[i]["question"]),
                      overflow: TextOverflow
                          .clip, // ✅ Ensures wrapping instead of overflow
                      softWrap: true, // ✅ Enables text wrapping
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(16),
                        color: Color(0xff003060),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          getAnswerType(currentSurvey[i]["answerType"], i),
          const SizedBox(
            height: 20,
          ),
        ],
        getBottomButtonSet(currentSurvey),
      //  getBottomButtonSetDev(),
      ],
    );
  }

  getAnswerType(String answerType, int pos) {
    var responses = ['Yes', 'No'];
    var index = startIndex - pos;

    if (answerType.contains("Yes")) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToggleSwitch(
            minWidth: 90.0,
            minHeight: 40.0,
            fontSize: MediaQuery.textScalerOf(context).scale(15),
            initialLabelIndex:
                surveys[0]["feedbackQuestion"][index]["answer"] == ""
                    ? -1
                    : responses.indexOf(
                        surveys[0]["feedbackQuestion"][index]["answer"]),
            activeFgColor: Colors.white,
            activeBgColor: [Colors.deepPurpleAccent],
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.grey[900],
            totalSwitches: 2,
            radiusStyle: true,
            labels: responses,
            onToggle: (index1) {
              setState(() {
                var intResponse = responses[index1!];
                surveys[0]["feedbackQuestion"][index]["answer"] = intResponse.toString();
                print("Yes no response is ${surveys[0]["feedbackQuestion"][index]["answer"]}");

              });

              if (surveys[0]["feedbackQuestion"][questionIndex]["question"] ==
                  "I complained to the manufacturer/retailer") {

                updateCurrentSurveyWithComplaintStatus(
                    surveys[0]["feedbackQuestion"][index]["answer"]);
              }
            },
          ),
          const SizedBox(
            height: 120,
          )
        ],
      );
    } else if (answerType == "Descriptive Upto 10 Words") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TextFormField(
              initialValue: surveys[0]["feedbackQuestion"][index]["answer"],
              maxLines: 2,
              onChanged: (String value) {
                setState(() {
                  if (getWordCount(value) <= 10) {
                    surveys[0]["feedbackQuestion"][index]["answer"] = value;
                  } else {
                    value = surveys[0]["feedbackQuestion"][index]["answer"];
                  }
                });
              },
              style: TextStyle(
                color: Colors.black54,
                fontSize: MediaQuery.textScalerOf(context).scale(14),
              ),
              decoration: const InputDecoration(
                enabled: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${getWordCount(surveys[0]["feedbackQuestion"][index]["answer"])}/10",
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          )
        ],
      );
    } else if (answerType == "Multimedia/Descriptive") {
      setState(() {
        superIndex = index;
      });
      if (surveys[0]["feedbackQuestion"][index]["answer"].toString().isEmpty) {
        surveys[0]["feedbackQuestion"][index]
            ["answer"] = {"text": "", "image": "", "audio": "", "video": ""};
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TextFormField(
              initialValue: surveys[0]["feedbackQuestion"][index]["answer"]
                      ["text"]
                  .toString(),
              maxLines: 3,
              onChanged: (String value) {
                setState(() {
                  if (getWordCount(value) <= 100) {
                    surveys[0]["feedbackQuestion"][index]["answer"]["text"] =
                        value;
                  }
                });
              },
              style: GoogleFonts.poppins(
                color: Color(0xff003060),
                fontSize: MediaQuery.textScalerOf(context).scale(14),
              ),
              decoration: InputDecoration(
                enabled: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                ),
                hintText:
                    "Enter details of the issue...", // ✅ Converted label to hint text
                hintStyle: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(14),
                  color:
                      const Color(0xff003060), // ✅ Same color as styled input
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${getWordCount(surveys[0]["feedbackQuestion"][index]["answer"]["text"])}/100",
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkResponse(
                onTap: (() {
                  setState(() {
                    showFeedback = false;
                    showRecording = true;
                  });
                }),
                child: Image.asset(
                  'images/mic.png',
                  height: 40.0,
                ),
              ),
              InkResponse(
                onTap: (() {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const CameraPage()));
                  setState(() {
                    ApplicationData.showVideoPlayer = true;
                    showFeedback = false;
                  });
                }),
                child: Image.asset(
                  'images/camera.png',
                  height: 40.0,
                ),
              ),
              InkResponse(
                onTap: (() {
                  AlertDialog alert = AlertDialog(
                    backgroundColor: Colors.blue, // ✅ Background color
                    title: Text(
                      "Select Upload Type",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ Title text color
                      ),
                    ),
                    content: StatefulBuilder(
                      builder: (BuildContext context, _setState) {
                        return Column(
                          mainAxisSize:
                              MainAxisSize.min, // ✅ Prevent unnecessary space
                          children: [
                            RadioListTile(
                              title: Text(
                                "Image File",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white, // ✅ Text color
                                ),
                              ),
                              value: "image",
                              groupValue: fileType,
                              activeColor: Colors
                                  .white, // ✅ White radio button when selected
                              onChanged: (value) {
                                _setState(() {
                                  fileType = value.toString();
                                });
                                print("Radio tile is $fileType");
                              },
                            ),
                            RadioListTile(
                              title: Text(
                                "Video File",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white, // ✅ Text color
                                ),
                              ),
                              value: "video",
                              groupValue: fileType,
                              activeColor: Colors
                                  .white, // ✅ White radio button when selected
                              onChanged: (value) {
                                _setState(() {
                                  fileType = value.toString();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // ✅ Evenly spaced buttons
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _pickFiles(fileType);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Continue",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                }),
                child: Image.asset(
                  "images/upload.png",
                  height: 30,
                ),
              )
            ],
          ),
          checkForAudioFileStatus(index),
          checkForImageFileStatus(index),
          checkForVideoFileStatus(index),
        ],
      );
    } else if (answerType == "Audio/Descriptive") {
      if (surveys[0]["feedbackQuestion"][index]["answer"].toString().isEmpty) {
        surveys[0]["feedbackQuestion"][index]
            ["answer"] = {"text": "", "image": "", "audio": "", "video": ""};
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TextFormField(
              initialValue: surveys[0]["feedbackQuestion"][index]["answer"]
                      ["text"]
                  .toString(),
              maxLines: 3,
              onChanged: (String value) {
                setState(() {
                  if (getWordCount(value) <= 100) {
                    surveys[0]["feedbackQuestion"][index]["answer"]["text"] =
                        value;
                  }
                });
              },
              style: TextStyle(
                color: Color(0xff003060),
                fontSize: MediaQuery.textScalerOf(context).scale(14),
              ),
              decoration: InputDecoration(
                enabled: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                ),
                hintText:
                    "Enter details of the issue...", // ✅ Converted label to hint text
                hintStyle: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(14),
                  color:
                      const Color(0xff003060), // ✅ Same color as styled input
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${getWordCount(surveys[0]["feedbackQuestion"][index]["answer"]["text"])}/100",
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkResponse(
                onTap: (() {
                  setState(() {
                    showFeedback = false;
                    showRecording = true;
                    superIndex = index;
                  });
                }),
                child: Image.asset(
                  'images/mic.png',
                  height: 40.0,
                ),
              ),
            ],
          ),
          checkForAudioFileStatus(index),
        ],
      );
    } else if (answerType.contains("Rating")) {
      getRatingsArray(answerType, index);
      var responses = responseArray;

      surveys[0]["feedbackQuestion"][index]["answer"] =
          surveys[0]["feedbackQuestion"][index]["answer"] == ""
              ? "1"
              : surveys[0]["feedbackQuestion"][index]["answer"];

      return Column(
        children: [
          getRowOfEndPoints(),
          Slider(
            thumbColor: Colors.blue,
            activeColor: Colors.green,
            inactiveColor: Colors.red,
            label: val.toString(),
            divisions: (responses.length <= 1 ? 5 : responses.length - 1),
            value: surveys[0]["feedbackQuestion"][index]["answer"] == ""
                ? 1
                : double.parse(surveys[0]["feedbackQuestion"][index]["answer"]),
            onChanged: (double value) {
              setState(() {
                val = value.toInt();
                surveys[0]["feedbackQuestion"][index]["answer"] =
                    value.toString();
              });
            },
            min: 1,
            max: ((responses.length).toDouble() <= 1
                ? 5
                : (responses.length).toDouble()),
          ),
        ],
      );
    } else if (answerType.contains("Checkbox")) {
      getRatingsArray(answerType, index);
      var responses = responseArray;
      print("checkbox responses $responses");

      if (!selectedCheckboxes.containsKey(index)) {
        selectedCheckboxes[index] = <String>{};
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: responses.map((option) {
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: CheckboxListTile(
              title: Text(option,
                  style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                      color: const Color(0xff003060))),
              value: selectedCheckboxes[index]!.contains(option),
              onChanged: (bool? value) {
                if (value == true) {
                  selectedCheckboxes[index]!.add(option);
                } else {
                  selectedCheckboxes[index]!.remove(option);
                }

                // Store answer: sorted, hyphen-separated
                final sortedAnswers = selectedCheckboxes[index]!.toList()
                  ..sort();
                final answerString = sortedAnswers.join('-');

                surveys[0]["feedbackQuestion"][index]["answer"] = answerString;

                print("Selected checkboxes for index $index: $answerString");
                setState(() {});
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      );
    } else if (answerType.contains("NumberBox")) {

      TextEditingController textController = TextEditingController();
      return Padding(
        padding: EdgeInsets.only(left: 50, right: 50, top: 10),
        child: Center(
          child: TextFormField(
            initialValue: surveys[0]["feedbackQuestion"][index]["answer"],
            onChanged: (value) {
              setState(() {
                textController.text = value.toString();
                surveys[0]["feedbackQuestion"][index]["answer"] =
                    value.toString();
                print("after change - "
                        "surveys[0]['feedbackQuestion'][index]['answer'] - ${surveys[0]["feedbackQuestion"][index]["answer"]}");
              });
            },
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.textScalerOf(context).scale(14),
              color: const Color(0xff003060), // ✅ Updated text color
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter Number", // ✅ Converted label to hint text
              hintStyle: GoogleFonts.poppins(
                fontSize: MediaQuery.textScalerOf(context).scale(14),
                color: const Color(0xff003060), // ✅ Same color as styled input
              ),

              // ✅ Styled Rectangle Box (No Rounded Corners)
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0), // ✅ Ensures blue border on focus
                borderRadius: BorderRadius.all(
                    Radius.circular(5.0)), // ✅ Keeps rectangular shape
              ),

              border: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(5.0)), // ✅ Rectangular box
              ),

              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xff003060), width: 1.0), // ✅ Styled border
                borderRadius: BorderRadius.all(
                    Radius.circular(5.0)), // ✅ No rounded corners
              ),
            ),
          ),
        ),
      );
    } else if (answerType.contains("Dropdown")) {
      String? dropdownResponse =
          surveys[0]["feedbackQuestion"][index]["answer"] == ""
              ? null
              : surveys[0]["feedbackQuestion"][index]["answer"];

      var dropDowns = <String>[];
      var values = <String>[];
      values = answerType.split("-");

      for (var item in values) {
        if (item != "Dropdown" && !dropDowns.contains(item)) {
          dropDowns.add(item);
        }
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Focus(
          onFocusChange: (isFocused) =>
              _updateFocusState(index, isFocused), // ✅ Track focus
          child: Container(
            width: 300, // Set a consistent width
            decoration: BoxDecoration(
              border: Border.all(
                color: isDropdownFocusedMap[index] == true
                    ? Colors.blue
                    : Colors.black, // ✅ Changes to blue when selected
                width: 2.0,
              ), // ✅ Black thin border
              borderRadius:
                  BorderRadius.circular(6), // ✅ Slightly rounded corners
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 10, vertical: 1), // ✅ Inner padding
            child: DropdownButtonHideUnderline(
              // ✅ Removes default underline
              child: DropdownButton<String>(
                isExpanded: true, // ✅ Ensures dropdown fills container width
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(15),
                  color: const Color(0xff003060),
                ),
                icon: const Icon(Icons.keyboard_arrow_down), // ✅ Dropdown icon
                iconSize: 24,
                iconEnabledColor: const Color(0xff3AB7A6),

                // ✅ Hint Text (Same as before)
                hint: Text(
                  "Select Response",
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.textScalerOf(context).scale(15),
                    color: const Color(0xff003060),
                  ),
                ),

                // ✅ Dropdown Items (Unchanged)
                items: dropDowns.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(15),
                        color: const Color(0xff003060),
                      ),
                    ),
                  );
                }).toList(),

                // ✅ Functionality: Store Selected Value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownResponse = newValue!;
                    surveys[0]["feedbackQuestion"][index]["answer"] =
                        dropdownResponse;
                  });
                },
                value: dropdownResponse,
              ),
            ),
          ),
        ),
      );
    }

    return Container();
  }

  Widget getBottomButtonSetWithFooter() {
    if (surveys[0]["feedbackQuestion"] == null) {
      return Container();
    }

    var arraySize = surveys[0]["feedbackQuestion"].length;
    if (questionIndex <= 0 && questionIndex < arraySize - 1) {
      return BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
                child: Image.asset(
                  "images/right.png",
                  width: rightWidth,
                  height: rightHeight,
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                    setState(() {
                      questionIndex++;
                      ratingsArrayLoaded = false;
                    });

                }),
          ),
        ],
      );
    } else if (questionIndex > 0 && questionIndex < arraySize - 1) {
      BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                setState(() {
                  questionIndex = questionIndex - endIndex;
                  ratingsArrayLoaded = false;
                });
              },
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: leftWidth, maxHeight: leftHeight),
                child: Image.asset(
                  "images/left.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                   FocusScope.of(context).unfocus();
                try {
                  if(surveys[0]["feedbackQuestion"][questionIndex]["answer"] == "No" &&
                      surveys[0]["feedbackQuestion"][questionIndex]["titleLine"].contains("Please let us know about any unreported problems/issues with your"))
                    {
                      setState(() {
                        showThankyouMessage = true;
                        questionIndex = 0;
                        superIndex = 0;
                        setNextSurvey(true);
                       
                      });
                    }
                  else{
                    setState(() {
                      questionIndex++;
                      ratingsArrayLoaded = false;
                    });
                  }
                } finally {
                  setState(() {
                    showSpinner = false;
                    showSpinnerMyFeedback = false;
                  });
                }

              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: rightWidth, maxHeight: rightHeight),
                child: Image.asset(
                  "images/right.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            label: '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0, // Optional: reduces extra spacing
        backgroundColor: Colors.transparent, // Optional: for debugging layout
      );
    } else if (questionIndex == arraySize - 1) {
      return BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
                child: Image.asset(
                  "images/left.png",
                  width: leftWidth,
                  height: leftHeight,
                ),
                onTap: () {
                  setState(() {
                    questionIndex -= endIndex;
                    lastTitle = "LoadLastLine";
                    questionIndex = 0;
                  });
                }),
          ),
          BottomNavigationBarItem(
              icon: Container(
            height: 50.0,
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                if (surveys[0]["surveyId"] == "ReplacementSurvey") {
                } else if ((surveys[0]["surveyId"] != "ReplacementSurvey")) {
                  setState(() {
                    showThankyouMessage = true;
                    questionIndex = 0;
                    superIndex = 0;
                    setNextSurvey(true);
                  });
                }
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0))),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(0.0),
                  )),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Submit",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.textScalerOf(context).scale(15),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ))
        ],
      );
    }
    return Container(
      child: Text(
        processQuestion(
            "Thank you very much for completing your first experience check-in!Your feedback will help to improve the quality and functionality of future \"products\".  We will contact you for an update of your experience in …. months."),
        style: TextStyle(
            color: Colors.red,
            fontSize: MediaQuery.textScalerOf(context).scale(14)),
      ),
    );
  }

  getBottomButtonSet(currentSurvey) {
    int ind = 0;
    for (var item in currentSurvey) {

      ind++;
    }

    var arraySize = surveys[0]["feedbackQuestion"].length;


    if (checkIfItsFirstQuestion(currentSurvey) &&
        questionIndex < arraySize - 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
              child: Image.asset(
                "images/right.png",
                width: rightWidth,
                height: rightHeight,
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                if (!GetValidResponses(currentSurvey)) {
                  print("Abhi goingForwardmessage is $goingForwardMessage");
                  if (goingForwardMessage.contains(
                      "A response is needed to continue, you can record audio/video, upload pic")) {
                    print("line 2833 coming to goingForwardMessage.contains(A response is needed to continue, you can record audio/video, upload pic");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue, // ✅ Background color
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Oops! Missing Info",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ Title text color
                            ),
                          ),
                          SizedBox(width: 8), // ✅ Spacing
                          Icon(Icons.warning, color: Colors.yellow, size: 30),
                        ],
                      ),
                      content: Column(
                        mainAxisSize:
                            MainAxisSize.min, // ✅ Prevents unnecessary spacing
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // ✅ Aligns content to the left
                        children: [
                          Text(
                            "We need all fields filled out to continue.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white, // ✅ Content text color
                            ),
                          ),
                          SizedBox(
                              height: 20), // ✅ Space between text and checklist
                          Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ), // ✅ Check Icon
                                  SizedBox(width: 8), // ✅ Spacing
                                  Text(
                                    "Check your info",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white, // ✅ Text color
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      5), // ✅ Spacing between checklist items
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Fill in the missing parts",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Try again!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Go Back",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  }else if (goingForwardMessage.contains(
                      "You have not used all given options to response, you can record audio and state detailed problem. Are you sure you want to continue?")) {
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Enhance Your Feedback!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                          minWidth: 200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goingForwardMessage?.isNotEmpty == true
                                  ? goingForwardMessage!
                                  : "Please provide your feedback to help us improve.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your input helps us improve—thank you! 🚀",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Improve Feedback",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      questionIndex++;
                                      ratingsArrayLoaded = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Continue as is",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  }else if (goingForwardMessage.contains(
                      "You have not used all given options to response, you can record audio/video, upload pic")) {

                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Enhance Your Feedback!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                          minWidth: 200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add more impact with:",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "📷 Photo | 🎥 Video | 🎙️ Audio",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Choose an option",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Upload or add details",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Submit again!",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your input helps us improve—thank you! 🚀",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Improve Feedback",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      questionIndex++;
                                      ratingsArrayLoaded = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Continue as is",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    // Show dialog with safe context

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });

                  }else if(goingForwardMessage.contains("What made this experience special ?"))
                  {
                    print("in positive exp");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Consistent corners
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8), // Add spacing
                          Flexible(
                            child: Text(
                              "Confirm positive experience!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2, // Allow wrapping
                            ),
                          ),
                          const SizedBox(width: 8), // Add spacing
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                          minWidth: 200, // Minimum for small screens
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What made this experience special? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible, // Allow wrapping
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Share experience",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {

                                  setState(() {
                                    questionIndex++;
                                    ratingsArrayLoaded = false;
                                  });

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "None",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );




                    // Show dialog with safe context
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    }
                  }else if(goingForwardMessage.contains("What was missing?"))
                  {
                    print("in missing exp");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Consistent corners
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8), // Add spacing
                          Flexible(
                            child: Text(
                              "Anything missing ?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2, // Allow wrapping
                            ),
                          ),
                          const SizedBox(width: 8), // Add spacing
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                          minWidth: 200, // Minimum for small screens
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What was missing? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible, // Allow wrapping
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Share experience",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {

                                setState(() {
                                  questionIndex++;
                                  ratingsArrayLoaded = false;
                                });

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "None",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );

                  }
                  else {
                    print("oops in line 3292");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue, // ✅ Background color
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Oops! Missing Info",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ Title text color
                            ),
                          ),
                          SizedBox(width: 8), // ✅ Spacing
                          Icon(Icons.warning, color: Colors.yellow, size: 30),
                        ],
                      ),
                      content: Column(
                        mainAxisSize:
                            MainAxisSize.min, // ✅ Prevents unnecessary spacing
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // ✅ Aligns content to the left
                        children: [
                          Text(
                            "We need all fields filled out to continue.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white, // ✅ Content text color
                            ),
                          ),
                          SizedBox(
                              height: 20), // ✅ Space between text and checklist
                          Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ), // ✅ Check Icon
                                  SizedBox(width: 8), // ✅ Spacing
                                  Text(
                                    "Check your info",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white, // ✅ Text color
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      5), // ✅ Spacing between checklist items
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Fill in the missing parts",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Try again!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Go Back",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  }
                } else {
                  setState(() {
                    questionIndex++;
                    ratingsArrayLoaded = false;
                  });
                }
              }),
        ],
      );
    } else if (questionIndex > 0 && questionIndex < arraySize - 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
              child: Image.asset(
                "images/left.png",
                width: leftWidth,
                height: leftHeight,
              ),
              onTap: () {
                setState(() {
                  questionIndex = questionIndex - endIndex;
                  ratingsArrayLoaded = false;
                });
              }),
          SizedBox(width: size.width * .77),
          InkWell(
              child: Image.asset(
                "images/right.png",
                width: rightWidth,
                height: rightHeight,
              ),
              onTap: () {
                if (!GetValidResponses(currentSurvey)) {
                  FocusScope.of(context).unfocus();

                  if (goingForwardMessage.contains(
                          "A response is needed to continue, select any one for Yes or No") ||
                      goingForwardMessage.isEmpty) {
                    print("oops in line 3478");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue, // ✅ Background color
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Oops! Missing Info",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ Title text color
                            ),
                          ),
                          SizedBox(width: 8), // ✅ Spacing
                          Icon(Icons.warning, color: Colors.yellow, size: 30),
                        ],
                      ),
                      content: Column(
                        mainAxisSize:
                            MainAxisSize.min, // ✅ Prevents unnecessary spacing
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // ✅ Aligns content to the left
                        children: [
                          Text(
                            "We need all fields filled out to continue.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white, // ✅ Content text color
                            ),
                          ),
                          SizedBox(
                              height: 20), // ✅ Space between text and checklist
                          Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ), // ✅ Check Icon
                                  SizedBox(width: 8), // ✅ Spacing
                                  Text(
                                    "Check your info",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white, // ✅ Text color
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      5), // ✅ Spacing between checklist items
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Fill in the missing parts",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Try again!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Go Back",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  } else if (goingForwardMessage.contains("You have not used all given options to response, you can record audio and state detailed problem. Are you sure you want to continue?")) {
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Enhance Your Feedback!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                          minWidth: 200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goingForwardMessage?.isNotEmpty == true
                                  ? goingForwardMessage!
                                  : "Please provide your feedback to help us improve.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your input helps us improve—thank you! 🚀",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Improve Feedback",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      questionIndex++;
                                      ratingsArrayLoaded = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Continue as is",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  }else if (goingForwardMessage.contains(
                      "You have not used all given options to response, you can record audio/video, upload pic")) {
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Enhance Your Feedback!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                          minWidth: 200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add more impact with:",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "📷 Photo | 🎥 Video | 🎙️ Audio",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Choose an option",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Upload or add details",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Submit again!",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your input helps us improve—thank you! 🚀",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Improve Feedback",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      questionIndex++;
                                      ratingsArrayLoaded = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Continue as is",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  } else if (goingForwardMessage.contains(
                      "you can record audio and state detailed problem")) {
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Enhance Your Feedback!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                          minWidth: 200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add more impact with:",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Give Description and 🎙️ Audio",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Choose an option",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Upload or add details",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: const [
                                        Icon(Icons.check_box, color: Colors.green, size: 18),
                                        Icon(Icons.check, color: Colors.white, size: 14),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "Submit again!",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your input helps us improve—thank you! 🚀",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Improve Feedback",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      questionIndex++;
                                      ratingsArrayLoaded = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff003060),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Continue as is",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  } else if (goingForwardMessage.contains(
                      "A response is needed to continue, you can record audio or state detailed problem.")) {
                    print("oops in line 4136");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue, // ✅ Background color
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Oops! Missing Info",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ Title text color
                            ),
                          ),
                          SizedBox(width: 8), // ✅ Spacing
                          Icon(Icons.warning, color: Colors.yellow, size: 30),
                        ],
                      ),
                      content: Column(
                        mainAxisSize:
                        MainAxisSize.min, // ✅ Prevents unnecessary spacing
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // ✅ Aligns content to the left
                        children: [
                          Text(
                            "We need all fields filled out to continue.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white, // ✅ Content text color
                            ),
                          ),
                          SizedBox(
                              height: 20), // ✅ Space between text and checklist
                          Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ), // ✅ Check Icon
                                  SizedBox(width: 8), // ✅ Spacing
                                  Text(
                                    "Check your info",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white, // ✅ Text color
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                  5), // ✅ Spacing between checklist items
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Fill in the missing parts",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Colors.green,
                                          size: 18), // Green box
                                      Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14), // White tick on top
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Try again!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Go Back",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  }else if(goingForwardMessage.contains("What made this experience special ?"))
                  {
                    print("in positive exp");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Consistent corners
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8), // Add spacing
                          Flexible(
                            child: Text(
                              "Confirm positive experience!",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2, // Allow wrapping
                            ),
                          ),
                          const SizedBox(width: 8), // Add spacing
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                          minWidth: 200, // Minimum for small screens
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What made this experience special? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible, // Allow wrapping
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Share experience",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {

                                  setState(() {
                                    questionIndex++;
                                    ratingsArrayLoaded = false;
                                  });

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "None",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    // Show dialog with safe context

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );



                  }
                  else if(goingForwardMessage.contains("What was missing?"))
                  {
                    print("in missing exp");
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Consistent corners
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                          const SizedBox(width: 8), // Add spacing
                          Flexible(
                            child: Text(
                              "Anything missing ?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2, // Allow wrapping
                            ),
                          ),
                          const SizedBox(width: 8), // Add spacing
                          const Icon(Icons.star, color: Colors.yellow, size: 24),
                        ],
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                          minWidth: 200, // Minimum for small screens
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What was missing? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible, // Allow wrapping
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Share experience",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {

                                setState(() {
                                  questionIndex++;
                                  ratingsArrayLoaded = false;
                                });

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003060),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "None",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );

                  }
                  else {
                    AlertDialog alert = AlertDialog(
                      backgroundColor: Colors.blue, // ✅ Dialog background color
                      title: Text(
                        "Alert",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✅ Title text color
                        ),
                      ),
                      content: Text(
                        goingForwardMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white, // ✅ Content text color
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, // ✅ Evenly spaced buttons
                          children: [
                            if (currentSurvey[0]["answerType"]
                                    .contains("Rating") ||
                                (currentSurvey[0]["answerType"]
                                        .contains("Multimedia/Descriptive") &&
                                    goingForwardMessage.contains("options")) ||
                                (currentSurvey[0]["answerType"]
                                        .contains("Audio/Descriptive") &&
                                    goingForwardMessage.contains("options")))
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    questionIndex++;
                                    ratingsArrayLoaded = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Color(0xff003060), // ✅ Button color
                                    borderRadius: BorderRadius.circular(
                                        20), // ✅ Rounded corners
                                  ),
                                  child: Text(
                                    "Continue",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Colors.white, // ✅ Button text color
                                    ),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Color(0xff003060), // ✅ Button color
                                  borderRadius: BorderRadius.circular(
                                      20), // ✅ Rounded corners
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // ✅ Button text color
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  }
                } else {

                  if(surveys[0]["feedbackQuestion"][questionIndex]["answer"] == "No" &&
                      surveys[0]["feedbackQuestion"][questionIndex]["titleLine"].contains("Please let us know about any unreported problems/issues with your"))
                  {
                    setState(() {
                      showThankyouMessage = true;
                      questionIndex = 0;
                      superIndex = 0;
                      setNextSurvey(true);
                      showSpinner = false;
                      showSpinnerMyFeedback = false;

                    });
                  }
                  else{
                    setState(() {
                      questionIndex++;
                      ratingsArrayLoaded = false;
                    });
                  }
                }
              })
        ],
      );
    } else if (questionIndex == arraySize - 1) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                  child: Image.asset(
                    "images/left.png",
                    width: leftWidth,
                    height: leftHeight,
                  ),
                  onTap: () {
                    setState(() {
                      questionIndex -= endIndex;
                      lastTitle = "LoadLastLine";
                      questionIndex = 0;
                    });
                  }),
              SizedBox(
                width: size.width * .20,
              ),
              Container(
                height: 50.0,
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    if (surveys[0]["surveyId"] == "ReplacementSurvey") {
                      if (!GetValidResponses(currentSurvey)) {
                        FocusScope.of(context).unfocus();

                        if (goingForwardMessage.contains(
                            "A response is needed to continue, select any one for Yes or No") ||
                            goingForwardMessage.isEmpty) {
                          print("oops in line 3478");
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue, // ✅ Background color
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Oops! Missing Info",
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // ✅ Title text color
                                  ),
                                ),
                                SizedBox(width: 8), // ✅ Spacing
                                Icon(Icons.warning, color: Colors.yellow, size: 30),
                              ],
                            ),
                            content: Column(
                              mainAxisSize:
                              MainAxisSize.min, // ✅ Prevents unnecessary spacing
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // ✅ Aligns content to the left
                              children: [
                                Text(
                                  "We need all fields filled out to continue.",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white, // ✅ Content text color
                                  ),
                                ),
                                SizedBox(
                                    height: 20), // ✅ Space between text and checklist
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box,
                                                color: Colors.green,
                                                size: 18), // Green box
                                            Icon(Icons.check,
                                                color: Colors.white,
                                                size: 14), // White tick on top
                                          ],
                                        ), // ✅ Check Icon
                                        SizedBox(width: 8), // ✅ Spacing
                                        Text(
                                          "Check your info",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white, // ✅ Text color
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                        5), // ✅ Spacing between checklist items
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box,
                                                color: Colors.green,
                                                size: 18), // Green box
                                            Icon(Icons.check,
                                                color: Colors.white,
                                                size: 14), // White tick on top
                                          ],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Fill in the missing parts",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box,
                                                color: Colors.green,
                                                size: 18), // Green box
                                            Icon(Icons.check,
                                                color: Colors.white,
                                                size: 14), // White tick on top
                                          ],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Try again!",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Color(0xff003060), // ✅ Button color
                                      borderRadius: BorderRadius.circular(
                                          20), // ✅ Rounded corners
                                    ),
                                    child: Text(
                                      "Go Back",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // ✅ Button text color
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        } else if (goingForwardMessage.contains("You have not used all given options to response, you can record audio and state detailed problem. Are you sure you want to continue?")) {
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Enhance Your Feedback!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                              ],
                            ),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                                minWidth: 200,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goingForwardMessage?.isNotEmpty == true
                                        ? goingForwardMessage!
                                        : "Please provide your feedback to help us improve.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Your input helps us improve—thank you! 🚀",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff003060),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Improve Feedback",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            questionIndex++;
                                            ratingsArrayLoaded = false;
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff003060),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Continue as is",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        }else if (goingForwardMessage.contains(
                            "You have not used all given options to response, you can record audio/video, upload pic")) {
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Enhance Your Feedback!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                              ],
                            ),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                                minWidth: 200,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add more impact with:",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "📷 Photo | 🎥 Video | 🎙️ Audio",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(Icons.check_box, color: Colors.green, size: 18),
                                              Icon(Icons.check, color: Colors.white, size: 14),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Choose an option",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(Icons.check_box, color: Colors.green, size: 18),
                                              Icon(Icons.check, color: Colors.white, size: 14),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Upload or add details",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(Icons.check_box, color: Colors.green, size: 18),
                                              Icon(Icons.check, color: Colors.white, size: 14),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Submit again!",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Your input helps us improve—thank you! 🚀",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff003060),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Improve Feedback",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            questionIndex++;
                                            ratingsArrayLoaded = false;
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff003060),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Continue as is",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        } else if (goingForwardMessage.contains(
                            "you can record audio and state detailed problem")) {
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Enhance Your Feedback!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                              ],
                            ),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                                minWidth: 200,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add more impact with:",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Give Description and 🎙️ Audio",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(Icons.check_box, color: Colors.green, size: 18),
                                              Icon(Icons.check, color: Colors.white, size: 14),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Choose an option",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(Icons.check_box, color: Colors.green, size: 18),
                                              Icon(Icons.check, color: Colors.white, size: 14),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Upload or add details",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: const [
                                              Icon(Icons.check_box, color: Colors.green, size: 18),
                                              Icon(Icons.check, color: Colors.white, size: 14),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Submit again!",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Your input helps us improve—thank you! 🚀",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff003060),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Improve Feedback",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            questionIndex++;
                                            ratingsArrayLoaded = false;
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff003060),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Continue as is",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        } else if (goingForwardMessage.contains(
                            "A response is needed to continue, you can record audio or state detailed problem.")) {
                          print("oops in line 4136");
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue, // ✅ Background color
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Oops! Missing Info",
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // ✅ Title text color
                                  ),
                                ),
                                SizedBox(width: 8), // ✅ Spacing
                                Icon(Icons.warning, color: Colors.yellow, size: 30),
                              ],
                            ),
                            content: Column(
                              mainAxisSize:
                              MainAxisSize.min, // ✅ Prevents unnecessary spacing
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // ✅ Aligns content to the left
                              children: [
                                Text(
                                  "We need all fields filled out to continue.",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white, // ✅ Content text color
                                  ),
                                ),
                                SizedBox(
                                    height: 20), // ✅ Space between text and checklist
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box,
                                                color: Colors.green,
                                                size: 18), // Green box
                                            Icon(Icons.check,
                                                color: Colors.white,
                                                size: 14), // White tick on top
                                          ],
                                        ), // ✅ Check Icon
                                        SizedBox(width: 8), // ✅ Spacing
                                        Text(
                                          "Check your info",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white, // ✅ Text color
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                        5), // ✅ Spacing between checklist items
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box,
                                                color: Colors.green,
                                                size: 18), // Green box
                                            Icon(Icons.check,
                                                color: Colors.white,
                                                size: 14), // White tick on top
                                          ],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Fill in the missing parts",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box,
                                                color: Colors.green,
                                                size: 18), // Green box
                                            Icon(Icons.check,
                                                color: Colors.white,
                                                size: 14), // White tick on top
                                          ],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Try again!",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Color(0xff003060), // ✅ Button color
                                      borderRadius: BorderRadius.circular(
                                          20), // ✅ Rounded corners
                                    ),
                                    child: Text(
                                      "Go Back",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // ✅ Button text color
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        }else if(goingForwardMessage.contains("What made this experience special ?"))
                        {
                          print("in positive exp");
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Consistent corners
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                                const SizedBox(width: 8), // Add spacing
                                Flexible(
                                  child: Text(
                                    "Confirm positive experience!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2, // Allow wrapping
                                  ),
                                ),
                                const SizedBox(width: 8), // Add spacing
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                              ],
                            ),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                                minWidth: 200, // Minimum for small screens
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What made this experience special? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible, // Allow wrapping
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff003060),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Share experience",
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {

                                      setState(() {
                                        questionIndex++;
                                        ratingsArrayLoaded = false;
                                      });

                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff003060),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "None",
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          // Show dialog with safe context

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );



                        }
                        else if(goingForwardMessage.contains("What was missing?"))
                        {
                          print("in missing exp");
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Consistent corners
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                                const SizedBox(width: 8), // Add spacing
                                Flexible(
                                  child: Text(
                                    "Anything missing ?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2, // Allow wrapping
                                  ),
                                ),
                                const SizedBox(width: 8), // Add spacing
                                const Icon(Icons.star, color: Colors.yellow, size: 24),
                              ],
                            ),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% screen width
                                minWidth: 200, // Minimum for small screens
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What was missing? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible, // Allow wrapping
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff003060),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Share experience",
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {

                                      setState(() {
                                        questionIndex++;
                                        ratingsArrayLoaded = false;
                                      });

                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff003060),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "None",
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );

                        }
                        else {
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue, // ✅ Dialog background color
                            title: Text(
                              "Alert",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // ✅ Title text color
                              ),
                            ),
                            content: Text(
                              goingForwardMessage,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white, // ✅ Content text color
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly, // ✅ Evenly spaced buttons
                                children: [
                                  if (currentSurvey[0]["answerType"]
                                      .contains("Rating") ||
                                      (currentSurvey[0]["answerType"]
                                          .contains("Multimedia/Descriptive") &&
                                          goingForwardMessage.contains("options")) ||
                                      (currentSurvey[0]["answerType"]
                                          .contains("Audio/Descriptive") &&
                                          goingForwardMessage.contains("options")))
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          questionIndex++;
                                          ratingsArrayLoaded = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Color(0xff003060), // ✅ Button color
                                          borderRadius: BorderRadius.circular(
                                              20), // ✅ Rounded corners
                                        ),
                                        child: Text(
                                          "Continue",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                            Colors.white, // ✅ Button text color
                                          ),
                                        ),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Color(0xff003060), // ✅ Button color
                                        borderRadius: BorderRadius.circular(
                                            20), // ✅ Rounded corners
                                      ),
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // ✅ Button text color
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        }
                      } else {
                        ProcessReplacementSurveyResponse(surveys[0]
                            ["feedbackQuestion"][superIndex]["answer"]);
                      }
                    } else if ((surveys[0]["surveyId"] !=
                        "ReplacementSurvey")) {
                      if (!GetValidResponses(currentSurvey)) {
                        AlertDialog alert = AlertDialog(
                          backgroundColor:
                              Colors.blue, // ✅ Dialog background color
                          title: Text(
                            "Alert",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ Title text color
                            ),
                          ),
                          content: Text(
                            goingForwardMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white, // ✅ Content text color
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly, // ✅ Even spacing for buttons
                              children: [
                                if (currentSurvey[0]["answerType"]
                                        .contains("Rating") ||
                                    (currentSurvey[0]["answerType"].contains(
                                            "Multimedia/Descriptive") &&
                                        goingForwardMessage
                                            .contains("options")) ||
                                    (currentSurvey[0]["answerType"]
                                            .contains("Audio/Descriptive") &&
                                        goingForwardMessage
                                            .contains("options")))
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showThankyouMessage = true;
                                        questionIndex = 0;
                                        superIndex = 0;
                                        setNextSurvey(true);

                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xff003060), // ✅ Button color
                                        borderRadius: BorderRadius.circular(
                                            20), // ✅ Rounded corners
                                      ),
                                      child: Text(
                                        "Continue",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .white, // ✅ Button text color
                                        ),
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color:
                                          Color(0xff003060), // ✅ Button color
                                      borderRadius: BorderRadius.circular(
                                          20), // ✅ Rounded corners
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Colors.white, // ✅ Button text color
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            });
                      } else {
                        setState(() {
                          showThankyouMessage = true;
                          questionIndex = 0;
                          superIndex = 0;
                          setNextSurvey(true);
                          showSpinner = false;
                          showSpinnerMyFeedback = false;
                        });
                      }
                    }
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0))),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(0.0),
                      )),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 150.0, minHeight: 50.0),
                      alignment: Alignment.center,
                      child: Text(
                        "Submit",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.textScalerOf(context).scale(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Container(
        child: Text(
          processQuestion(
              "Thank you very much for completing your first experience check-in!Your feedback will help to improve the quality and functionality of future \"products\".  We will contact you for an update of your experience in …. months."),
          style: TextStyle(
              color: Colors.red,
              fontSize: MediaQuery.textScalerOf(context).scale(15)),
        ),
      );
    }
  }

  Widget getBottomButtonSetDev() {
    if (!kDebugMode) return SizedBox.shrink(); // Don't render if not in dev

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.bolt, color: Colors.white),
              label: Text("Skip Validation & Next"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                setState(()  {
                  showThankyouMessage = true;
                  questionIndex = 0;
                  superIndex = 0;
                  setNextSurvey(true);
                  showSpinner = false;
                  showSpinnerMyFeedback = false;

                });
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "🚨 Dev mode: skipping validation 🚨",
          style: TextStyle(color: Colors.redAccent, fontSize: 12),
        )
      ],
    );
  }

  void setBrand(myProductSelected) {
    for (var prod in myProducts) {
      if (prod["productName"] == myProductSelected["productName"]) {
        myProductBrand = (prod["features"]["Brand"]);
        break;
      }
    }
  }

  String processQuestion(String question) {
    if (question.isNotEmpty) {
      question = question.replaceAll("product", productSelected.toString());
      question = question.replaceAll("\"", "");
      question = question.replaceAll("\\n", "\n");

    }

    return question;
  }

  getRatingsArray(answerType, int index) {

    responseArray = [];

    bool hasRatings = ratings[answerType] != null;
    bool hasCheckboxes = checkBoxes[answerType] != null;

    if (hasRatings) {
      for (var value in ratings[answerType]) {
        responseArray.add(value.toString());
      }
    }

    if (hasCheckboxes) {
      for (var value in checkBoxes[answerType]) {
        responseArray.add(value.toString());
      }
    }

    if (!hasRatings && !hasCheckboxes) {
      responseArray.add("Lower Value");
      responseArray.add("Upper Value");
    }
  }

  void loadRatingsList() async {
    if (!ratingsArrayLoaded) {
      var url = Uri.parse(Apis.ratingsArray());
      var response = await http.get(url);

      if (response.statusCode == 200)
        {
          List<dynamic> responseList = jsonDecode(response.body);

          for (int i = 0; i < responseList.length; i++) {
            ratings[responseList[i]["answerType"].toString()] =
            responseList[i]["ratingValues"];
            checkBoxes[responseList[i]["answerType"].toString()] =
            responseList[i]["checkBoxValues"];
          }

          ratingsArrayLoaded = true;
        }
      else{
        print("Rating array could not be loaded");
      }



    }
  }

  startFeedback() {

    String titleLine =
        surveys[0]["feedbackQuestion"][questionIndex]["titleLine"].toString();
    if (lastTitle.isNotEmpty &&
        titleLine.isNotEmpty &&
        (lastTitle == "LoadLastLine" || lastTitle != titleLine)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              processQuestion(titleLine),
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.textScalerOf(context).scale(18),
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // ✅ Rounded Borders
              side: BorderSide(
                  color: Colors.black, width: 1.5), // ✅ Optional border
            ),
            color: Color(0xff003060),
            height: 50,
            onPressed: () {
              setState(() {
                showTitleLineNow = false;
                lastTitle = titleLine;
              });
            },
            child: Text(
              "Continue",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: MediaQuery.textScalerOf(context).scale(14),
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      );
    } else {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                      ),
                      child: Image.asset(
                        "images/homeButton.png",
                        height: 35,
                        width: 35,
                      ),
                      onPressed: () async {
                        setState(() {
                          AlertDialog alert = AlertDialog(
                            backgroundColor: Colors.blue, // ✅ Background color
                            title: Text(
                              "Warning",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // ✅ Title text color
                              ),
                            ),
                            content: Text(
                              "You are leaving the survey while it's not complete. If you proceed, it may reset and not "
                              "get recorded.\n\nDo you wish to abort feedback?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white, // ✅ Content text color
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly, // ✅ Evenly spaced buttons
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showThankyouMessage = false;
                                        showFeedback = false;
                                        showRegistrationPage = false;
                                        goToHome = true;
                                        questionIndex = 0;
                                        if (isDefectSurvey) {

                                            myProductSelected[
                                            "currentDefectSurvey"] =
                                            surveys[0];
                                        } else {
                                            myProductSelected[
                                            "currentMainSurvey"] = surveys[0];

                                        }
                                      });

                                      // ✅ Save survey data to myProductSelected


                                      Navigator.pop(context);



                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xff003060), // ✅ Button color
                                        borderRadius: BorderRadius.circular(
                                            20), // ✅ Rounded corners
                                      ),
                                      child: Text(
                                        "Continue",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .white, // ✅ Button text color
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xff003060), // ✅ Button color
                                        borderRadius: BorderRadius.circular(
                                            20), // ✅ Rounded corners
                                      ),
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .white, // ✅ Button text color
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        });
                      }),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  getQuestionAndResponse(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  MyProducts(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinnerMyProducts,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "My Products",
                    style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(25),
                        fontWeight: FontWeight.bold,
                        color: Color(0xff003060)),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "In this section, you can view your saved products or add new ones."
                  "Tap the info icon for more details or the bin icon to remove a product.",
                  style: GoogleFonts.poppins(
                    color: Color(0xff003060),
                    fontSize: MediaQuery.textScalerOf(context).scale(14),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    "Registered Products",
                    style: GoogleFonts.poppins(
                        fontSize: MediaQuery.textScalerOf(context).scale(20),
                        fontWeight: FontWeight.bold,
                        color: Color(0xff003060)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var product in myProducts)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ✅ ACTUAL TABLE
                          Expanded(
                            flex: 6, // Adjust table width
                            child: Table(
                              border: TableBorder.all(
                                color: Colors.grey, // Table border color
                                width: 1, // Border thickness
                              ), // ⬅️ Table Borders
                              columnWidths: const {
                                0: FlexColumnWidth(
                                    3), // Product Name + Info column
                                1: FlexColumnWidth(3), // Purchase Date column
                              }, // ⬅️ Define table column widths
                              children: [
                                // 📌 HEADER ROW (Only Shown for First Product)
                                if (product == myProducts.first)
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Color(
                                            0xff003060)), // Header Background
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Product", // ⬅️ Header 1: Product
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ), // ⬅️ Column 1: Header "Product"

                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Purchase Date", // ⬅️ Header 2: Purchase Date
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ), // ⬅️ Column 2: Header "Purchase Date"
                                    ],
                                  ), // ⬅️ Table Header Row Ends

                                // 📌 PRODUCT ROW
                                TableRow(
                                  children: [
                                    // 📌 PRODUCT NAME + INFO COLUMN
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product["shortName"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Color(0xff184B2A),
                                              ),
                                              softWrap: true,
                                            ),
                                          ), // ⬅️ Column 1: Product Name

                                          InkWell(
                                            child: const Icon(
                                              Icons.info,
                                              color: Colors.blue,
                                            ), // ⬅️ Column 1: Info Icon
                                            onTap: () {
                                              AlertDialog alert = AlertDialog(
                                                backgroundColor: Colors
                                                    .blue, // ✅ Background color
                                                title: Text(
                                                  "Product Details",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors
                                                        .white, // ✅ Title text color
                                                  ),
                                                ),
                                                content: SingleChildScrollView(
                                                  physics:
                                                      BouncingScrollPhysics(), // ✅ Smooth scrolling
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children:
                                                        getFeaturesAsRowWidget(
                                                            product), // ✅ Keeps existing functionality
                                                  ),
                                                ),
                                                actions: [
                                                  Center(
                                                    // ✅ Centering the button
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(
                                                              0xff003060), // ✅ Button color
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  20), // ✅ Rounded corners
                                                        ),
                                                        child: Text(
                                                          "Back",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .white, // ✅ Button text color
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return alert;
                                                },
                                              );
                                            },
                                          ), // ⬅️ Column 1: Info Dialog Trigger
                                        ],
                                      ),
                                    ), // ⬅️ Column 1: Product Name + Info Icon

                                    // 📌 PURCHASE DATE COLUMN
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product["features"]
                                                      ["Purchase Date"]
                                                  .toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Color(0xff184B2A),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.blue,
                                            ), // ⬅️ Delete Icon
                                            onTap: () {
                                              AlertDialog alert = AlertDialog(
                                                backgroundColor: Colors
                                                    .blue, // ✅ Background color
                                                title: Text(
                                                  "Alert",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors
                                                        .white, // ✅ Title text color
                                                  ),
                                                ),
                                                content: Text(
                                                  "Do you wish to remove ${product["productName"].toString()} "
                                                  "from your list of products?",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    color: Colors
                                                        .white, // ✅ Content text color
                                                  ),
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly, // ✅ Evenly spaced buttons
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            myProducts.remove(
                                                                product);
                                                          });
                                                          RemoveProductFromUser(
                                                              product);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      20),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xff003060), // ✅ Button color
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20), // ✅ Rounded corners
                                                          ),
                                                          child: Text(
                                                            "Continue",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white, // ✅ Button text color
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      20),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xff003060), // ✅ Button color
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20), // ✅ Rounded corners
                                                          ),
                                                          child: Text(
                                                            "Cancel",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white, // ✅ Button text color
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return alert;
                                                },
                                              );
                                            },
                                          ), // ⬅️ Delete Button for Each Product
                                        ],
                                      ),
                                    ), // ⬅️ Column 2: Purchase Date
                                  ],
                                ), // ⬅️ End of Product Row
                              ],
                            ), // ⬅️ End of Table
                          ), // ⬅️ End of Table inside Row
                        ],
                      ), // ⬅️ End of Row
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  onTap: () async {
                    for (int i = 0; i < featureList.keys.length; i++) {
                      featureList[featureList.keys.elementAt(i)] = "";
                    }
                    await loadProducts();
                    year = null;
                    month = null;
                    type = null;
                    showRegistrationPage = true;
                    isFirstRegistration = true;
                  },
                  child: Container(
                    height: 60.0,
                    width: 250.0, // Adjust width as needed
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(color: Color(0xff003060)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 📌 Icon
                        Image.asset(
                          'images/plusIcon.png', // ✅ Path to your image
                          height: 40, // Adjust icon size
                          width: 40,
                        ),
                        SizedBox(width: 10), // Space between icon and text

                        // 📌 Text
                        Text(
                          "Add a new product",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(12),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MyProductsPage(BuildContext context) {
    if (showRegistrationPage) {
      return RegisterProduct(context);
    } else {
      return MyProducts(context);
    }
  }

  Future<void> RemoveProductFromUser(product) async {
    var url = Uri.parse(
        Apis.deleteProductFromUser(product["productName"], widget.mobileNum));
    print(url);
    var response = await http.delete(url, body: jsonEncode(product));
    print('Deleted user product successfully - ${response.body}');
  }

  Widget SetDefectReportAndGetWidget(Map product, double baseFontSize) {
    return MaterialButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.black, width: 1.5),
      ),
      onPressed: () {
        setState(() {
          myProductSelected = product;
          setBrand(myProductSelected);
          startSurveyProcess(myProductSelected["currentDefectSurvey"]);
          isDefectSurvey = true;
          ApplicationData.audioMessage = "Voice record your issue in detail. Note that the limit 02 minutes";
        });
      },
      child: Text(
        "Report a problem",
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: MediaQuery.textScalerOf(context).scale(baseFontSize * 0.9), // Slightly smaller
          height: 1.2, // Improve readability
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      minWidth: 0, // Allow button to shrink
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 6.0,
      ),
    );
  }

  Widget checkForActiveFeedbackAndGetWidget(Map product, double baseFontSize) {
    if (product["currentMainSurvey"]["next"]) {
      return MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.black, width: 1.5),
        ),
        color: Colors.white,
        onPressed: () {
          setState(() {
            myProductSelected = product;
            setBrand(myProductSelected);
          });

          if (product["currentMainSurvey"]["name"] != "QS1") {
            AlertDialog successAlert = AlertDialog(
              backgroundColor: Colors.blue,
              title: Text(
                "Confirm Replacement",
                style: GoogleFonts.poppins(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: Text(
                "Did you replace your ${getProductName(myProductSelected).toString().toLowerCase()} with new one since last survey? If So, please proceed with new registration. Else press 'cancel' to continue with this survey.",
                style: GoogleFonts.poppins(
                  fontSize: baseFontSize * 1.2,
                  color: Colors.white,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () async {
                    tabController.animateTo(0);
                    setState(() {
                      showRegistrationPage = true;
                      showFeedback = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff003060),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Register New one",
                      style: GoogleFonts.poppins(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      startSurveyProcess(myProductSelected["currentMainSurvey"]);
                      isDefectSurvey = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff003060),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return successAlert;
              },
            );
          } else {
            setState(() {
              startSurveyProcess(myProductSelected["currentMainSurvey"]);
              isDefectSurvey = false;
            });
          }
        },
        child: Text(
          "Regular Feedback",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: MediaQuery.textScalerOf(context).scale(baseFontSize * 0.9),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        minWidth: 0,
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 6.0,
        ),
      );
    }
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.black, width: 1.5),
      ),
      color: Colors.white,
      onPressed: () {},
      child: Text(
        "No Pending Feedback",
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: MediaQuery.textScalerOf(context).scale(baseFontSize * 0.9),
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      minWidth: 0,
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 6.0,
      ),
    );
  }

  void setIsSelected(int index) {

    List<bool> selectedList = [];
    for (int i = 0; i < index; i++) {
      selectedList.add(false);
    }

    isSelected[questionIndex] = selectedList;
  }

  loadRatingsIsSelected() {
    for (int i = 0; i < surveys[0]["feedbackQuestion"].length; i++) {
      if (surveys[0]["feedbackQuestion"][i]["answerType"].contains("Rating")) {
        String rating = surveys[0]["feedbackQuestion"][i]["answerType"]
            .toString()
            .substring(6, 9);

        var values = <String>[];

        values = rating.split("-");

        List<bool> listBool = [];

        for (int j = int.parse(values[0]); j <= int.parse(values[1]); j++) {
          listBool.add(false);
        }

        //Adding to map
        isSelected[i] = listBool;
      }
    }
  }

  getWidth(String response, TextStyle textStyle) {
    String result = "";

    if (response.contains(" ")) {
      var values = <String>[];

      values = response.split(" ");

      for (String value in values) {
        if (value.length > result.length) {
          result = value;
        }
      }
    } else {
      result = response;
    }

    final Size size = (TextPainter(
            text: TextSpan(text: result, style: textStyle),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;

    return size.width + 5; //Extra  5 for padding
  }

  void getMonths() {
    var monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'June',
      'July',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec'
    ];

    final currentYear = DateTime.parse(DateTime.now().toString());

    if (year == currentYear.year.toString()) {
      months = [];
      for (int i = 0; i < currentYear.month; i++) {
        months.add(monthNames[i]);
      }
    } else {
      months = monthNames;
    }
  }

  getAudioFileNameAndDeleteOption() {
    // if (audioFilePath == "") {
    //   return Text("");
    // } else  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Audio",
          style: TextStyle(
              fontSize: MediaQuery.textScalerOf(context).scale(15),
              color: Colors.brown),
        ),
        InkResponse(
          onTap: (() {
            AudioPlayer(
              source: ApplicationData.multimediaUrls[surveys[0]
                  ["feedbackQuestion"][superIndex]["answer"]["audio"]]!,
              onDelete: () {},
            );
          }),
          child: const Icon(
            // (_recordState == RecordState.record)
            //     ? Icons.pause
            //     : Icons.play_arrow,
            Icons.play_arrow,
            color: Colors.red,
            size: 40,
          ),
        ),
        InkResponse(
          onTap: (() {
            setState(() {});
          }),
          child: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
        )
      ],
    );
  }

  Future<void> setNextSurvey(bool value) async {
    var currentSurvey = surveys[0];

    var surveyId = "";

    //Setting Next survey
    switch (currentSurvey["surveyId"]) {
      case 'QS1':
        surveyId = "QS2";
        break;

      case 'QS2':
        surveyId = "QS2";
        break;

      case 'Defect Report':
        surveyId = "QS2   Defect";
        break;

      case 'QS2   Defect':
        surveyId = "QS2";
        break;
    }

    var isReplacementSurvey = value;

    setState(() {
      showSpinner = true;
      showSpinnerMyFeedback = true;
    });
    try {
      var url = ProcessUrl(Apis.setNextSurveyForFeedback(
          widget.mobileNum,
          myProductSelected["productName"],
          currentSurvey["surveyId"],
          isReplacementSurvey));
      print(url);

      for (var i = 0; i < currentSurvey["feedbackQuestion"].length; i++) {
        var question = currentSurvey["feedbackQuestion"][i];
        if (question["answerType"] == "Audio/Descriptive" ||
            question["answerType"] == "Multimedia/Descriptive") {
          setState(() {
            currentSurvey["feedbackQuestion"][i]["answer"] =
                getStringFormatForMultimedia(
                    currentSurvey["feedbackQuestion"][i]["answer"]);
          });
          //print(currentSurvey["feedbackQuestion"][i]["answer"]);
        }
      }

      var response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(currentSurvey));
      print("Response to setNextSurvey = ${response.body}");
        await loadMyProducts();
    } on Exception catch (e) {
      // TODO
    }finally{

      print("reached finally of setnext survey");
      setState(() {
        showSpinner = false;
        showSpinnerMyFeedback = false;
        showSpinnerMyProducts = false;
      });

    }

  }

  Future<void> loadAllSurveys() async {
    try {
      setState(() {
        showSpinner = true;
        showSpinnerMyFeedback = true;
      });

      // Make the HTTP request
      var response = await http.get(Uri.parse(Apis.getAllSurveys()));

      // Check the status code
      if (response.statusCode == 200) {
        // Response is OK, try to parse JSON
        var data = json.decode(response.body);
        for (var element in data) {
          if (element["surveyId"] == "QS2   Defect") {
            qs2DefectSurveyLength = element["feedbackQuestion"].length;
          }
          allSurveys.add(element);
        }
      } else {
        // Log error with status code and response body
        print('Error: HTTP ${response.statusCode} - ${response.body}');
        // Optionally show a user-friendly error message

      }

      setState(() {
        showSpinner = false;
        showSpinnerMyFeedback = false;
      });
    } catch (e) {
      // Handle any other errors
      print('Error in loadAllSurveys: $e');

      setState(() {
        showSpinner = false;
        showSpinnerMyFeedback = false;
      });
    }
  }

  String ProcessUrl(String url) {
    url = url.replaceAll(" ", '%20');
    return url;
  }

  void ProcessReplacementSurveyResponse(String response) {
    if (response == "Yes") {
      AlertDialog alert = AlertDialog(
        backgroundColor: Colors.blue, // ✅ Dialog background color
        title: Text(
          "Alert",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ Title text color
          ),
        ),
        content: Text(
          "You have chosen that your ${getProductName(myProductSelected).toString().toLowerCase()} "
          "has been replaced. You will be redirected to register the new product.",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white, // ✅ Content text color
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // ✅ Even spacing for buttons
            children: [
              GestureDetector(
                onTap: () {
                  showRegistrationPage = true;
                  setState(() {
                    for (int i = 0; i < featureList.keys.length; i++) {
                      featureList[featureList.keys.elementAt(i)] = "";
                    }
                    year = null;
                    month = null;
                    type = null;
                    showRegistrationPage = true;
                  });
                  productSelected = getProductName(myProductSelected);
                  tabController.animateTo(0);
                  loadFeaturesListForSelectedProduct();
                  Navigator.pop(context);
                  setNextSurvey(false);
                  MyFeedback(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xff003060), // ✅ Button color
                    borderRadius:
                        BorderRadius.circular(20), // ✅ Rounded corners
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ✅ Button text color
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xff003060), // ✅ Button color
                    borderRadius:
                        BorderRadius.circular(20), // ✅ Rounded corners
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ✅ Button text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    } else {
      setState(() {
        startSurveyProcess(myProductSelected["currentMainSurvey"]);
        questionIndex = 0;
        startFeedback();
      });
    }
  }

  String? getProductName(var myProductSelected) {
    var values = <String>[];
    values = myProductSelected["productName"].toString().split("-");

    return values[0].toString();
  }

  void startSurveyProcess(survey) {
    productSelected = getProductName(myProductSelected);
    surveys = [];
    surveys.add(survey);
    showFeedback = true;
    showThankyouMessage = false;
    loadRatingsIsSelected();
  }

  void updateCurrentSurveyWithComplaintStatus(String response) {
    for (var survey in allSurveys) {
      if (survey["surveyId"] == "Complaint Survey" && response == "Yes") {
        uploadSurveyToCurrentSurvey(survey);
        break;
      } else if (survey["surveyId"] == "No complaint Survey" &&
          response == "No") {
        uploadSurveyToCurrentSurvey(survey);
        break;
      }
    }
  }

  void uploadSurveyToCurrentSurvey(survey) {
    //Emptying Survey for previous complaint/noncomplaint

    if (surveys[0]["feedbackQuestion"].length > qs2DefectSurveyLength) {
      int i = qs2DefectSurveyLength;
      int count = surveys[0]["feedbackQuestion"].length - qs2DefectSurveyLength;

      while (count > 0) {
        surveys[0]["feedbackQuestion"].removeAt(i);
        count--;
      }
    }
    for (var element in survey["feedbackQuestion"]) {
      surveys[0]["feedbackQuestion"].add(element);
    }
    setState(() {
      getBottomButtonSet(null);
      loadRatingsIsSelected();
    });
  }

  List<Widget> getFeaturesAsRowWidget(product) {
    List<Widget> rowWidgets = [];

    rowWidgets.add(Text('Product : ' + product["productName"]));

    product["features"].forEach((k, v) => rowWidgets.add(Text('${k}: ${v}')));

    return rowWidgets;
  }

  bool allRegisterFieldsOk() {
    for (int i = 0; i < featureList.keys.length; i++) {
      if (featureList[featureList.keys.elementAt(i)] == "" ||
          featureList[featureList.keys.elementAt(i)] == null) {
        return false;
      }
    }

    return true;
  }

  int getWordCount(String text) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      int charVal = text[i].codeUnits[0];

      if ((charVal >= 65 && charVal <= 90) ||
          (charVal >= 97 && charVal <= 122) ||
          (charVal >= 48 && charVal <= 59)) {
        continue;
      } else {
        count++;
      }
    }

    return count;
  }

  purgeSurveyFromOldAnswers(survey) {
    for (int index = 0; index < survey["feedbackQuestion"].length; index++) {
      survey["feedbackQuestion"][index]["answer"] = "";
    }
    questionIndex = 0;
    return survey;
  }

  getRecordingApparatus() {
    return SizedBox(
      height: 50,
      width: 50,
      child: (Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  // ✅ Allows text to wrap instead of overflow
                  child: Text(
                    ApplicationData.audioMessage,
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.textScalerOf(context).scale(18),
                      fontWeight: FontWeight.bold,
                      color: Color(0xff003060),
                    ),
                    textAlign: TextAlign
                        .center, // ✅ Ensures centered alignment inside the row
                    softWrap: true, // ✅ Enables text wrapping
                    overflow:
                        TextOverflow.visible, // ✅ Ensures text is not clipped
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ApplicationData.screenHeight * .25,
            width: ApplicationData.screenWidth,
            child: AudioRecorder(
              onStop: (path) async {
                if (kDebugMode) print('Recorded file path: $path');

                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Prevent dismissing while uploading
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600, // Blue background
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Uploading your Audio file — word by word! 📁🌟",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                try {
                  var link = await uploadMediaToDrive(path);

                  setState(() {
                    surveys[0]["feedbackQuestion"][superIndex]["answer"]
                        ["audio"] = "https://drive.google.com/uc?id=$link";
                    ApplicationData.multimediaUrls[surveys[0]
                            ["feedbackQuestion"][superIndex]["answer"]
                        ["audio"]] = path;
                  });
                  if (kDebugMode) print('Uploaded file link: $link');

                  // Close the spinner dialog
                  Navigator.pop(context);

                  AlertDialog alert = AlertDialog(
                    backgroundColor: Colors.blue, // ✅ Background color
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          // ✅ Ensures text wraps properly inside Row
                          child: Text(
                            "Your audio has been uploaded! 🎉",
                            textAlign: TextAlign.center, // ✅ Keeps it centered
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ Title text color
                            ),
                            softWrap: true, // ✅ Ensures wrapping
                            overflow:
                                TextOverflow.visible, // ✅ Prevents clipping
                          ),
                        ),
                      ],
                    ),

                    content: Column(
                      mainAxisSize:
                          MainAxisSize.min, // ✅ Prevents unnecessary spacing
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // ✅ Aligns content to the left
                      children: [
                        Flexible(
                          // ✅ Ensures text wraps within its available space
                          child: Text(
                            "Your audio file has been successfully uploaded. 🙌\nThank you for sharing!",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white, // ✅ Content text color
                            ),
                            softWrap:
                                true, // ✅ Allows text to break into multiple lines
                            overflow: TextOverflow
                                .visible, // ✅ Ensures text is not clipped
                          ),
                        ),
                        SizedBox(
                            height: 20), // ✅ Space between text and checklist
                      ],
                    ),

                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                showFeedback = true;
                                showRecording = false;
                                showSpinner = false;
                                showSpinnerMyFeedback = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xff003060), // ✅ Button color
                                borderRadius: BorderRadius.circular(
                                    20), // ✅ Rounded corners
                              ),
                              child: Text(
                                "Ok",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // ✅ Button text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                } catch (e) {
                  Navigator.pop(context);

                  // Show error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Upload Failed",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "An error occurred while uploading the audio. Please try again.",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        actions: [
                          GestureDetector(
                            onTap: () =>
                                {Navigator.pop(context), showFeedback = true},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xff003060),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Ok",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            height: 50.0,
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  setState(() {
                    showFeedback = true;
                    showRecording = false;
                  });
                  //   loadMyProducts();
                });
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0))),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(0.0),
                  )),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Back",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.textScalerOf(context).scale(15),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  getAudioPlayerApparatus() {
    return SizedBox(
      height: 50,
      width: 50,
      child: (Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: ApplicationData.screenHeight * .25,
            width: ApplicationData.screenWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: AudioPlayer(
                source: ApplicationData.multimediaUrls[surveys[0]
                    ["feedbackQuestion"][superIndex]["answer"]["audio"]]!,
                onDelete: () {
                  setState(() {
                    surveys[0]["feedbackQuestion"][superIndex]["answer"]
                        ["audio"] = "";
                    showAudioPlayer = false;
                    showFeedback = true;
                  });
                },
              ),
            ),
          ),
          Material(
            color: Colors.blue,
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            elevation: 2.0,
            child: MaterialButton(
              onPressed: () async {
                setState(() {
                  setState(() {
                    showFeedback = true;
                    showAudioPlayer = false;
                  });
                  //   loadMyProducts();
                });
              },
              minWidth: 50.0,
              height: 32.0,
              child: Text(
                'Back',
                style: TextStyle(
                    fontSize: MediaQuery.textScalerOf(context).scale(14)),
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget checkForAudioFileStatus(int index) {
    if (surveys[0]["feedbackQuestion"][index]["answer"]["audio"]
        .toString()
        .isEmpty) {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Text(
          "Audio File uploaded.",
          style: TextStyle(
              color: Colors.deepOrange,
              fontSize: MediaQuery.textScalerOf(context).scale(16)),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {
            setState(() {
              showFeedback = false;
              showAudioPlayer = true;
            });
          },
          child: const Icon(
            Icons.play_arrow,
            size: 30,
            color: Colors.red,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {
            setState(() {
              surveys[0]["feedbackQuestion"][index]["answer"]["audio"] = "";
            });
          },
          child: const Icon(
            Icons.delete_forever,
            size: 30,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  Widget checkForImageFileStatus(int index) {
    if (surveys[0]["feedbackQuestion"][index]["answer"]["image"]
        .toString()
        .isEmpty) {
      return Row();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Text(
          "Image File uploaded.",
          style: TextStyle(
              color: Colors.deepPurple,
              fontSize: MediaQuery.textScalerOf(context).scale(16)),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {
            setState(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        content: Image.file(File(ApplicationData.multimediaUrls[
                                surveys[0]["feedbackQuestion"][index]["answer"]
                                    ["image"]]
                            .toString())),
                        actions: [
                          Material(
                            color: Colors.blue,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30.0)),
                            elevation: 2.0,
                            child: MaterialButton(
                              onPressed: () async {
                                setState(() {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                  //   loadMyProducts();
                                });
                              },
                              minWidth: 50.0,
                              height: 32.0,
                              child: Text(
                                'Back',
                                style: TextStyle(
                                    fontSize: MediaQuery.textScalerOf(context)
                                        .scale(14)),
                              ),
                            ),
                          ),
                        ]);
                  });
            });
          },
          child: const Icon(
            Icons.image,
            size: 30,
            color: Colors.red,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {
            setState(() {
              surveys[0]["feedbackQuestion"][index]["answer"]["image"] = "";
            });
          },
          child: const Icon(
            Icons.delete_forever,
            size: 30,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  Widget checkForVideoFileStatus(int index) {
    if (surveys[0]["feedbackQuestion"][index]["answer"]["video"]
        .toString()
        .isEmpty) {
      return Row();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Text(
          "Video File uploaded.",
          style: TextStyle(
              color: Colors.deepPurple,
              fontSize: MediaQuery.textScalerOf(context).scale(16)),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {
            setState(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return VideoApp(ApplicationData.multimediaUrls[surveys[0]
                        ["feedbackQuestion"][index]["answer"]["video"]]!);
                  });
            });
          },
          child: const Icon(
            Icons.video_camera_back,
            size: 30,
            color: Colors.red,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {
            setState(() {
              surveys[0]["feedbackQuestion"][index]["answer"]["video"] = "";
            });
          },
          child: const Icon(
            Icons.delete_forever,
            size: 30,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  getVideoPlayerApparatus() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Camera(
        color: Colors.blueAccent,
        onImageCaptured: (value) async {
          final String path = value.path;
          setState(() {
            ApplicationData.showVideoPlayer = false;
            showSpinner = true;
            showSpinnerMyFeedback = true;
          });

          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing while uploading
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600, // Blue background
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Hold tight! Your image is flying through the digital skies 🚀📸",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          try {
            var link = await uploadMediaToDrive(path);

            Navigator.pop(context);

            if (path.contains('jpg')) {
              print("Path is $path");
              setState(() {
                surveys[0]["feedbackQuestion"][superIndex]["answer"]["image"] =
                    "https://drive.google.com/uc?id=$link";
                ApplicationData.multimediaUrls[
                    "https://drive.google.com/uc?id=$link"] = path;
              });
             } else {}
            AlertDialog alert = AlertDialog(
              backgroundColor: Colors.blue, // ✅ Background color
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    // ✅ Ensures text wraps properly inside Row
                    child: Text(
                      "Your Image has been uploaded! 🎉",
                      textAlign: TextAlign.center, // ✅ Keeps it centered
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ Title text color
                      ),
                      softWrap: true, // ✅ Ensures wrapping
                      overflow: TextOverflow.visible, // ✅ Prevents clipping
                    ),
                  ),
                ],
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // ✅ Prevents unnecessary spacing
                crossAxisAlignment:
                    CrossAxisAlignment.start, // ✅ Aligns content to the left
                children: [
                  Flexible(
                    // ✅ Ensures text wraps within its available space
                    child: Text(
                      "Your Image file has been successfully uploaded. 🙌\nThank you for sharing!",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white, // ✅ Content text color
                      ),
                      softWrap:
                          true, // ✅ Allows text to break into multiple lines
                      overflow:
                          TextOverflow.visible, // ✅ Ensures text is not clipped
                    ),
                  ),
                  SizedBox(height: 20), // ✅ Space between text and checklist
                ],
              ),

              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          ApplicationData.showVideoPlayer = false;
                          showFeedback = true;
                          showSpinner = false;
                          showSpinnerMyFeedback = false;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color(0xff003060), // ✅ Button color
                          borderRadius:
                              BorderRadius.circular(20), // ✅ Rounded corners
                        ),
                        child: Text(
                          "Ok",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // ✅ Button text color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );

            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                });
          } catch (e) {
            Navigator.pop(context);

            // Show error dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Upload Failed",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "An error occurred while uploading the Image. Please try again.",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () =>
                          {Navigator.pop(context), showFeedback = true},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xff003060),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Ok",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        onVideoRecorded: (value) async {
          final path = value.path;
          setState(() {
            ApplicationData.showVideoPlayer = false;
            showSpinner = true;
            showSpinnerMyFeedback = true;
          });
          print('::::::::::::::::::::::::;; $path');

          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing while uploading
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent, // Make dialog background transparent
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700, // Blue background
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Wrap content, not full screen
                    children: [
                      Text(
                        "Please wait as video files are known to take time to upload 😎✨",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          try {
            var link = await uploadMediaToDrive(path);
            Navigator.pop(context);

            setState(() {
              surveys[0]["feedbackQuestion"][superIndex]["answer"]["video"] =
                  "https://drive.google.com/uc?id=$link";
              ApplicationData
                      .multimediaUrls["https://drive.google.com/uc?id=$link"] =
                  path;
            });


            AlertDialog alert = AlertDialog(
              backgroundColor: Colors.blue, // ✅ Background color
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    // ✅ Ensures text wraps properly inside Row
                    child: Text(
                      "Your Video has been uploaded! 🎉",
                      textAlign: TextAlign.center, // ✅ Keeps it centered
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ Title text color
                      ),
                      softWrap: true, // ✅ Ensures wrapping
                      overflow: TextOverflow.visible, // ✅ Prevents clipping
                    ),
                  ),
                ],
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // ✅ Prevents unnecessary spacing
                crossAxisAlignment:
                    CrossAxisAlignment.start, // ✅ Aligns content to the left
                children: [
                  Flexible(
                    // ✅ Ensures text wraps within its available space
                    child: Text(
                      "Your Video file has been successfully uploaded. 🙌\nThank you for sharing!",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white, // ✅ Content text color
                      ),
                      softWrap:
                          true, // ✅ Allows text to break into multiple lines
                      overflow:
                          TextOverflow.visible, // ✅ Ensures text is not clipped
                    ),
                  ),
                  SizedBox(height: 20), // ✅ Space between text and checklist
                ],
              ),

              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          ApplicationData.showVideoPlayer = false;
                          showFeedback = true;
                          showSpinner = false;
                          showSpinnerMyFeedback = false;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color(0xff003060), // ✅ Button color
                          borderRadius:
                              BorderRadius.circular(20), // ✅ Rounded corners
                        ),
                        child: Text(
                          "Ok",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // ✅ Button text color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );

            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                });
          } catch (e) {
            Navigator.pop(context);

            // Show error dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Upload Failed",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "An error occurred while uploading the Video. Please try again.",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () =>
                          {Navigator.pop(context), showFeedback = true},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xff003060),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Ok",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        onClose: () {
          print("``closed camera~~");
          setState(() {
            ApplicationData.showVideoPlayer = false;
            showFeedback = true;
          });
        },
      ),
    );
  }

  Future<void> _pickFiles(String? fileType) async {
    FileType _pickingType = FileType.any;
    List<String>? extns = [];

    if (fileType == "image") {
      _pickingType = FileType.image;
    } else {
      _pickingType = FileType.video;
    }

    List<PlatformFile>? _paths;

    try {
      String? _directoryPath;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: extns,
      ))
          ?.files;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Unsupported operation$e');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while uploading
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade600, // Blue background
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Uploading your file — almost ready for glory! 📁🌟",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    try {
      var link = await uploadMediaToDrive(_paths![0].path.toString());
      Navigator.pop(context);

      setState(() {
        if (_paths != null) {
          if (fileType == "image") {
            setState(() {
              surveys[0]["feedbackQuestion"][superIndex]["answer"]["image"] =
              "https://drive.google.com/uc?id=$link";
              ApplicationData
                  .multimediaUrls["https://drive.google.com/uc?id=$link"] =
                  _paths![0].path.toString();
            });
          } else {
            setState(() {
              surveys[0]["feedbackQuestion"][superIndex]["answer"]["video"] =
              "https://drive.google.com/uc?id=$link";
              ApplicationData
                  .multimediaUrls["https://drive.google.com/uc?id=$link"] =
                  _paths![0].path.toString();
            });
          }

        }
      });

      AlertDialog alert = AlertDialog(
        backgroundColor: Colors.blue, // ✅ Background color
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              // ✅ Ensures text wraps properly inside Row
              child: Text(
                "Your file has been uploaded! 🎉",
                textAlign: TextAlign.center, // ✅ Keeps it centered
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // ✅ Title text color
                ),
                softWrap: true, // ✅ Ensures wrapping
                overflow: TextOverflow.visible, // ✅ Prevents clipping
              ),
            ),
          ],
        ),

        content: Column(
          mainAxisSize:
          MainAxisSize.min, // ✅ Prevents unnecessary spacing
          crossAxisAlignment:
          CrossAxisAlignment.start, // ✅ Aligns content to the left
          children: [
            Flexible(
              // ✅ Ensures text wraps within its available space
              child: Text(
                "Your file has been successfully uploaded. 🙌\nThank you for sharing!",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white, // ✅ Content text color
                ),
                softWrap:
                true, // ✅ Allows text to break into multiple lines
                overflow:
                TextOverflow.visible, // ✅ Ensures text is not clipped
              ),
            ),
            SizedBox(height: 20), // ✅ Space between text and checklist
          ],
        ),

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    showFeedback = true;
                  });
                },
                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xff003060), // ✅ Button color
                    borderRadius:
                    BorderRadius.circular(20), // ✅ Rounded corners
                  ),
                  child: Text(
                    "Ok",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ✅ Button text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    } catch (e) {
      Navigator.pop(context);
      print("Uplaod error - ${e.toString()}");
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Upload Failed",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "An error occurred while uploading the File. Please try again.",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            actions: [
              GestureDetector(
                onTap: () =>
                {Navigator.pop(context), showFeedback = true},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xff003060),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Ok",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }




  }



  void setAnswerAsValue(String ansType, String value) {
    List<String> values = List.filled(
        4, surveys[0]["feedbackQuestion"][superIndex]["answer"].split("-"),
        growable: false);

    //  values = surveys[0]["feedbackQuestion"][index]["answer"].split("-");

    // if (values.length < 4) {
    //   for (int i = values.length; i < 4; i++) {
    //     values.add("");
    //   }
    // }

    if (ansType == "text") {
      values.removeAt(0);
      values.insert(0, value);
    } else if (ansType == "audio") {
      values[1] = value;
    } else if (ansType == "image") {
      values[2] = value;
    } else if (ansType == "video") {
      values[3] = value;
    }

    //Joining it back to answer separated by '-'
    for (int i = 0; i < 4; i++) {
      surveys[0]["feedbackQuestion"][superIndex]["answer"] += values[i];
      if (i < 3) {
        surveys[0]["feedbackQuestion"][superIndex]["answer"] += "-";
      }
    }
  }

  getProduct(String prodName) {
    for (var product in myProducts) {
      if (product["productName"] == prodName) {
        return product;
      }
    }
  }

  void disableAllOthers(String quesTitle, int index) {
    for (int i = 0; i < surveys[0]["feedbackQuestion"].length; i++) {
      if (surveys[0]["feedbackQuestion"][i]["questionTitle"] == quesTitle &&
          surveys[0]["feedbackQuestion"][i]["answerType"] == "Checkbox") {
        if (i != index) {
          setState(() {
            surveys[0]["feedbackQuestion"][i]["answer"] = false;
          });
        }
      }
    }
  }

  String processThankYouText(String thankText) {
    if (thankText.isNotEmpty) {
      var values = <String>[];
      values = productSelected.toString().split("-");
      thankText = thankText.replaceAll("product", values[0].toLowerCase());
      thankText = thankText.replaceAll("\"", "");
      thankText = thankText.replaceAll("\\n", "\n");
      thankText = thankText.replaceAll(
          "days", "${myProductSelected['surveyGapDays']} days");
    }
    return thankText;
  }

  bool GetValidResponses(currentSurvey) {

    print("in get vaalid response");
    goingForwardMessage = "";

    for (var i = 0; i < currentSurvey.length; i++) {
      print(currentSurvey[i]["answerType"]);
      if (currentSurvey[i]["answerType"].contains("Rating")) {
        if (currentSurvey[i]["answer"] == "1") {
          setState(() {
            goingForwardMessage = "For one or more rating, your response is "
                "same as default value. Are you sure you wish to continue ?";
          });

          return false;
        }
      }
      if (currentSurvey[i]["answerType"].contains("Yes")) {
        if (currentSurvey[i]["answer"] == "") {
          setState(() {
            goingForwardMessage =
                "A response is needed to continue, select any one for Yes or No";
          });

          return false;
        }
      }
      if (currentSurvey[i]["answerType"].contains("Multimedia/Descriptive")) {
        if (currentSurvey[i]["answer"]["text"] == "" &&
            currentSurvey[i]["answer"]["image"] == "" &&
            currentSurvey[i]["answer"]["audio"] == "" &&
            currentSurvey[i]["answer"]["video"] == "") {
          setState(() {
            goingForwardMessage =
                "A response is needed to continue, you can record audio/video, upload pic "
                " and give detailed problem.";
          });

          return false;
        }
        if (currentSurvey[i]["answer"]["text"] == "" ||
            currentSurvey[i]["answer"]["image"] == "" ||
            currentSurvey[i]["answer"]["audio"] == "" ||
            currentSurvey[i]["answer"]["video"] == "") {
          setState(() {
            goingForwardMessage =
                "You have not used all given options to response, you can record audio/video, upload pic "
                " and give detailed problem. Are you sure you want to continue? ";
          });

          return false;
        }
      }
      if (currentSurvey[i]["answerType"].contains("Audio/Descriptive")) {
        print("in audio descriptive");
        print(currentSurvey[i]["answer"]);
        print(currentSurvey[i]["answer"]["text"] == "");
        print(currentSurvey[i]["answer"]["audio"] == "");
        if (currentSurvey[i]["answer"]["text"] == "" &&
            currentSurvey[i]["answer"]["audio"] == "") {

          if(currentSurvey[i]["mainScreentitle"] == "Positive Experiences")
            {
              setState(() {
                goingForwardMessage =
                "What made this experience special ? Please describe in detail through typing or recording. Otherwise please select none and move to the next section.";
              });
              return false;

            }

          if(currentSurvey[i]["mainScreentitle"] == "Missing Features and Functionalities")
          {
            setState(() {
              goingForwardMessage =
              "What was missing? Please describe in detail through typing or recording!";
            });
            return false;

          }




          setState(() {
            goingForwardMessage =
                "A response is needed to continue, you can record audio or state detailed problem.";
          });

          return false;
        }
        if (currentSurvey[i]["answer"]["text"] == "" ||
            currentSurvey[i]["answer"]["audio"] == "") {
          setState(() {
            goingForwardMessage =
                "You have not used all given options to response, you can record audio and state detailed problem. Are you sure you want to continue?";
          });
          print(goingForwardMessage);
          return false;
        }
      }

      if (currentSurvey[i]["answer"] == "") {
        return false;
      }
    }
    return true;
  }

  Future<AuthClient> obtainAuthenticatedClient() async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "fb11ed5a9d0b9dd255657950da6c7e631551d745",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDlY9wkERKvIfVJ\ne2Rz3mC0FmIkzsYb/HGcYXKBOM57s3aezgCjmYyDtQEpPn25Dy0cmGYsDUZu0YDB\n52aSBbEH3zISSVKAk2iWPdHgb+JGwfFfLIxYT5Gg03M6JrB+3N8v7Rb6Yu47h6gJ\n1Ttw8/KCWxkBW4eNDXPgAEwIDcFJaXkPlraQ9Wy6vGll/KIWnnwt79epAPzWJys8\nqevH5IqkGUy3bi0Cu5pgq8abdceSaUfgMJ7OkyDQhu0n9sbdpBc6BMP44U+w3sn0\nRwCXSCF13M/sG/oWNcZUxaPWguviJ1O0ILUdnWwNwcwW+bi1pItufpJIIzDFAOBT\ns6Wnz5YfAgMBAAECggEAIvCVR8/AlyPGrHz6ra9x7rGjcf8mK9Ma1vqnf0lQzNoR\nYlpMZ0mXHo9Dxa16vDpfNlt8Nzovv+dyA5b53O9i/1Oe2Swz6y5eICxQZdgvkMmF\nDhMcrsLdPVrtJ9lcHtFeaXq6ekRMDI3lftdCKOVEy1g8NHm66YrisHw7GIBH2voc\n3RQtYUZ3zE3mjpQ30neUFvbNN1x0tgJJKL7S99sfXg0ttNDJ/pNhd6ylTvRTTxey\nsG/vIUv5TqrTu2qK0n2keu9YjiOOfgXdTf2M6OBOZbFCyejCY0wJTz2ksu9IX0zt\neAwxg07TxoMQWQNS89wEphgbi2QD6DKCCLu4UB6e+QKBgQD+zWLia9jKzA1duYBx\nBmMNl0MCX3kZjr8gGjpXLZKn6VqCaZZeDE06TmzLJiZisonkv8fxGPWCT0IBkQib\nY0vi7h/km7bsV6IuO9W5dqW7Yhu7r/seXwOenUJsk5oKgtC1Y9y96NlUvDdkU3u1\nHnmLa20H4KV+KIUdC3iu7AqV2wKBgQDmd+Tl1CC74fivdUJraiAzEaoM35/FMZC0\nP1arTG7IPfDzO/A8d59h4dMk6UvQZQF5tUXAj7WSz7TKvYCdkrIXgfNDmVf8gSyo\nNHVXReiXazR2R/QxkOwX/TnsUcsBFtk10W615nqu/BYH0GRGi7JcK3dT3GtT+YFj\n6wzV03wODQKBgQCA2HMMc+SoiA6qOkeM3+Hu2XJ1HLosBlb3cMvXkZ/7cLDoCWSU\nIjxbI5U4FQ6MEiRQm/oLHMfpIRMLn79udAPHuQo/m84gLSBBqNgmdKzR2IaVniOp\n8/nslzEjnm/iqMvJLbpN/hUIGDUacmy35bUonyX/OcX1yZ+mVEquiYXAyQKBgQDV\nG1gVDKmYEcOauprIKEHN9y9+5+kctlBP26GQlAR8NIpw36OsxhAiumY7Y14vPLa4\ni94LyNblAhryvXgIPHVhN1Bx2YF6gxeAEcHPCV2hZggEt1Qd4RvussC0vI0yXKZN\nFXOBz7TxyTe10gRnFxW+FJMqgE7eP4BdnCMqNXwooQKBgQD3mpWfOwiJvP9tjvRf\nvk467QBypAS1szi0gJJCw7ZhFhGvfwcQLD/OG1253F+obzW0bajjR/cYb7FRY+tv\nBXSc4RaExXRPyzAGFMjSXDJ4SpVQHg1YrCP9lpt7PXcIx8ZHRdJIgH0lnoEPqD7G\nrBUoo5DmU4hSjmtT/VjEVib0dQ==\n-----END PRIVATE KEY-----\n",
      "client_email": "unige-369@subtle-signal-357112.iam.gserviceaccount.com",
      "client_id": "110071210451244334789",
      "type": "service_account"
    });
    var scopes = [drive.DriveApi.driveFileScope];

    AuthClient client =
        await clientViaServiceAccount(accountCredentials, scopes);

    print("client is $client");
    return client; // Remember to close the client when you are finished with it.
  }

  Future<String> uploadMediaToDrive(path) async {
    File file = File(path);
    final client = await obtainAuthenticatedClient();

    try {
      final driveApi = drive.DriveApi(client);

      // Create a file on Google Drive
      final driveFile = drive.File()
        ..name = 'example_image.jpg'
        ..parents = ['116UnsCfRtRQp4ABdmqspsnI6WH4VQrUb'];

      final uploadedFile = await driveApi.files.create(driveFile,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()));

      print('Image uploaded successfully. File ID: ${uploadedFile.id}');
      print("start waiting 5secs");
      await Future.delayed(Duration(seconds: 3));
      print("wait ends");
      // Add view permission for anyone with the link
      final permission = drive.Permission()
        ..role = 'reader'
        ..type = 'anyone';

      return uploadedFile.id.toString();
    } catch (error, stackTrace) {
      print('Error uploading image: $error');
      print('Stack trace: $stackTrace');
      return '';
    } finally {
      client.close();
    }
  }

  Future<String?> getShareableLink(String fileId) async {
    final client = await obtainAuthenticatedClient();

    try {
      final driveApi = drive.DriveApi(client);
      final file = await driveApi.files.get(fileId) as drive.File;


      // Check if the file is accessible to anyone with the link
      if (file.permissions != null) {
        final linkPermission = file.permissions!.firstWhere(
          (permission) =>
              permission.role == 'reader' && permission.type == 'anyone',
          orElse: () => drive.Permission(),
        );

        if (linkPermission.id != null) {
          // Construct the shareable link
          final shareableLink =
              'https://drive.google.com/uc?id=${file.id}&export=download';
          return shareableLink;
        }
      }

      print('File is not accessible with a shareable link.');
      return null;
    } catch (error, stackTrace) {
      print('Error getting shareable link: $error');
      print('Stack trace: $stackTrace');
      return null;
    } finally {
      client.close();
    }
  }

  getStringFormatForMultimedia(survey) {
    print("survey is $survey");
    print("is survey empty ? ${survey.isEmpty}");

    if (survey.isNotEmpty) {
      String text = survey["text"] ?? "N/A";
      String image = survey["image"] ?? "N/A";
      String audio = survey["audio"] ?? "N/A";
      String video = survey["video"] ?? "N/A";


      return "text - $text, image - $image, audio - $audio, video - $video";
    } else {
      return "";
    }
  }

  Widget getRowOfEndPoints() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding =
        40.0; // Total horizontal padding (20 left + 20 right)

    // Calculate the widths of the two texts
    final TextPainter leftTextPainter = TextPainter(
      text: TextSpan(
        text: responseArray[0],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.textScalerOf(context).scale(15),
          color: Color(0xff003060),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double leftTextWidth = leftTextPainter.size.width;

    final TextPainter rightTextPainter = TextPainter(
      text: TextSpan(
        text: responseArray[responseArray.length - 1],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.textScalerOf(context).scale(15),
          color: Color(0xff003060),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double rightTextWidth = rightTextPainter.size.width;




    // Check if the combined width exceeds the available width
    final bool isOverflowing =
        (leftTextWidth + rightTextWidth + padding) >= screenWidth * .8;



    if (isOverflowing) {
      // Return two rows if text overflows
      return Padding(
        padding:
            const EdgeInsets.only(left: 20.0, top: 10, right: 20, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                responseArray[0],
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(15),
                  fontWeight: FontWeight.bold,
                  color: Color(0xff003060),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                responseArray[responseArray.length - 1],
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.textScalerOf(context).scale(15),
                  fontWeight: FontWeight.bold,
                  color: Color(0xff003060),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Return a single row if no overflow
      return Padding(
        padding:
            const EdgeInsets.only(left: 20.0, top: 10, right: 20, bottom: 0),
        child: Row(
          children: [
            Text(
              responseArray[0],
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.textScalerOf(context).scale(15),
                color: Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            const Spacer(),
            Text(
              responseArray[responseArray.length - 1],
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.textScalerOf(context).scale(15),
                color: Colors.deepPurple,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        ),
      );
    }
  }

  bool checkIfItsFirstQuestion(currentSurvey) {
    if (surveys[0]["feedbackQuestion"][0]["mainScreentitle"] ==
            currentSurvey[0]["mainScreentitle"] &&
        surveys[0]["feedbackQuestion"][0]["titleLine"] ==
            currentSurvey[0]["titleLine"] &&
        surveys[0]["feedbackQuestion"][0]["questionTitle"] ==
            currentSurvey[0]["questionTitle"]) {
      return true;
    }

    return false;
  }

  Future<void> _launchUrl() async {
    final url;

    switch (urlId) {
      case 1:
        url = Uri.parse("https://qualtrack-privacypolicy.web.app");
        break;

      case 2:
        url = Uri.parse("https://qualtrack-privacypolicy.web.app/faq.html");
        break;

      case 3:
        url = Uri.parse(
            "https://qualtrack-privacypolicy.web.app/");
        break;

      case 4:
        url = Uri.parse(
            "https://qualtrack-privacypolicy.web.app/aboutUs.html");
        break;

      default:
        url = Uri.parse("https://qualtrack-privacypolicy.web.app/");
    }
    print("urlId is $urlId");
    print("url is $url");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      print("Could not launch URL");
    }
  }

  String processResponse(String? thankYouMessage) {
    if (thankYouMessage?.isNotEmpty ?? false) {
      return thankYouMessage!.replaceAll('"', '');
    } else {
      return '';
    }
  }
}
