import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:unige_app/Other_data/VideoPlayer.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:unige_app/screens/trySupport.dart';

import '../Other_data/Apis.dart';
import '../Other_data/AudioRecorder.dart';
import '../Other_data/Camera.dart';

class HomePage extends StatefulWidget {
  static String id = "HomePage";
  String mobileNum;
  HomePage(this.mobileNum);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool showSpinnerRegisterProduct = false,
      showSpinner = false,
      showSpinnerMyProfile = false,
      showSpinnerMyProducts = false;
  Color color = Colors.orange;
  final recorder = Record();

  String name = "",
      email = "",
      mobile = ApplicationData.mobile,
      myProductBrand = "",
      feedbackType = "Next Feedback",
      lastTitle = "LoadLastLine";

  var myProductSelected;
  String? productSelected, month, year, type, minutes, seconds, fileType;
  int superIndex = 0;
  var products = <String>[];
  var productsObjects = [];
  List<dynamic> myProducts = [];
  List<dynamic> surveys = [];
  List<dynamic> allSurveys = [];
  Map<String, dynamic> ratings = {};
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
      showRegistrationPage = false,
      showFeedback = false,
      isRecorderReady = false,
      isPlaying = false,
      isDefectSurvey = false,
      isFirstRegistration = false;

  var featureList = {};
  int val = 3, tabIndex = 0, qs2DefectSurveyLength = -1;

  bool showThankyouMessage = false,
      showRecording = false,
      showAudioPlayer = false,
      showCamera = false;

  bool showTitleLineNow = true;
  late TabController tabController;
  Map<int, List<bool>> isSelected = {};
  IconData icon = Icons.mic;
  late Size size;
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();

  bool goToHome = false;

  bool isRecording = false;

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
              preferredSize: Size.fromHeight(size.height * .2),
              child: AppBar(
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Container(
                        height: kToolbarHeight,
                        margin:
                            EdgeInsets.only(top: 20.0, left: size.width * .1),
                        child: Image.asset(
                          'images/logo.png',
                          alignment: Alignment.center,
                          height: kToolbarHeight,
                        ),
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
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                bottom: TabBar(
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.red,
                  tabs: [
                    Tab(
                      child: Container(
                        child: const Text(
                          "My Products",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: const Text(
                          "My Feedback",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: const Text(
                          "My Profile",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
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

    ApplicationData.mobile = "";
    ApplicationData.countryCodeISO = "";
  }

  MyProfile(context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        inAsyncCall: showSpinnerMyProfile,
        child: Padding(
          padding: EdgeInsets.only(left: size.width * .3),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile details",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50.0,
                ),
                Text(
                  "Name - $name",
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 28.0,
                ),
                Text(
                  "Mobile - $mobile",
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 28.0,
                ),
                Text(
                  "Email - $email",
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 28.0,
                )
              ]),
        ),
      ),
    );
  }

  getUserDetails() async {
    String mobile = ApplicationData.mobile;

    if (mobile.isNotEmpty) {
      setState(() {
        showSpinnerMyProfile = true;
      });

      var url = Uri.parse(Apis.getUser(mobile));
      var response = await http.get(url);

      setState(() {
        showSpinnerMyProfile = false;
      });

      Map<String, dynamic> values = json.decode(response.body);
      name = values["name"];
      email = values["email"];
    }
  }

  Future<void> loadProducts() async {
    setState(() {
      showSpinnerMyProducts = true;
    });
    var response = await http.get(Uri.parse(Apis.getAllProducts()));

    productsObjects = json.decode(response.body);

    for (int i = 0; i < productsObjects.length; i++) {
      if (!products.contains((productsObjects[i]["productName"].toString()))) {
        products.add(productsObjects[i]["productName"].toString());
      }
    }

    // productSelected = products[0];
    setState(() {
      //  productSelected = products[0];

      showSpinnerMyProducts = false;
    });
  }

  MyFeedback(BuildContext context) {
    if (showThankyouMessage) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: (Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              processThankYouText(surveys[0]["thankYouText"]),
              style: const TextStyle(fontSize: 18, color: Colors.pink),
            ),
            Material(
              color: Colors.blue,
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              elevation: 2.0,
              child: MaterialButton(
                onPressed: () async {
                  setState(() {
                    setState(() {
                      showThankyouMessage = false;
                      showFeedback = false;
                      showRegistrationPage = false;
                      showSpinnerMyProducts = true;
                      goToHome = true;
                    });
                    //   loadMyProducts();
                  });
                },
                minWidth: 50.0,
                height: 32.0,
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 14),
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
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DataTable(columns: [
                const DataColumn(
                  label: Text(
                    "",
                    style: TextStyle(fontSize: 12.0, color: Colors.red),
                  ),
                ),
                const DataColumn(label: Text("")),
                const DataColumn(label: Text(""))
              ], rows: [
                for (var product in myProducts)
                  if (product["active"] == true)
                    DataRow(cells: [
                      DataCell(Text(
                        product["productName"],
                        style: const TextStyle(
                            color: Colors.deepPurpleAccent, fontSize: 13.0),
                      )),
                      if (product["active"] == true)
                        checkForActiveFeedbackAndGetDataCell(product),
                      if (product["active"] == true)
                        SetDefectReportAndGetDataCell(product),
                    ])
              ])
            ],
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
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * .6),
                      child: Material(
                        child: ElevatedButton(
                            child: const Icon(Icons.home,
                                color: Colors.deepPurpleAccent),
                            onPressed: () {
                              setState(() {
                                showRegistrationPage = false;
                                productSelected = null;
                                featureList = {};
                              });
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DropdownButton(
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            iconEnabledColor: Colors.red,
                            disabledHint: null,
                            hint: const Text(
                              "Select Category",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 18),
                            ),
                            items: products.map((String prod) {
                              return DropdownMenuItem(
                                value: prod,
                                child: Text(
                                  prod,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                productSelected = newValue!;

                                loadFeaturesListForSelectedProduct();
                              });
                            },
                            value: productSelected,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                color: Colors.blue,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () async {
                    if (allRegisterFieldsOk()) {
                      AlertDialog alert = AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                            "Please check all fields before registering your product. You will not"
                            " be able to change it later.\n\n Do you wish to register the product ?"),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  showSpinnerRegisterProduct = true;
                                });
                                var url = Uri.parse(Apis.registerProduct(
                                    productSelected.toString(), mobile));
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
                                  if (isFirstRegistration) {
                                    //After first registry, QS1 should start for that product
                                    var prodName = "$productSelected-" +
                                        featureList["Brand"];
                                    setState(() {
                                      myProductSelected = getProduct(prodName);
                                      print(
                                          "myProductSelected is$myProductSelected");
                                      //setBrand(myProductSelected);
                                      startSurveyProcess(myProductSelected[
                                          "currentMainSurvey"]);
                                      isDefectSurvey = false;
                                      isFirstRegistration = false;
                                    });
                                  } else {
                                    setState(() {
                                      showThankyouMessage = false;
                                      showFeedback = false;
                                      showRegistrationPage = false;
                                    });
                                  }

                                  AlertDialog alert = AlertDialog(
                                    title: const Text("Success"),
                                    content: Text(
                                        "Thank you for registering your ${productSelected.toString().toLowerCase()}"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            tabController.animateTo(1);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Continue"))
                                    ],
                                  );

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      });
                                  setState(() {
                                    showSpinnerRegisterProduct = false;
                                  });
                                } else {
                                  // getPopUpToContinue(
                                  //     "Error",
                                  //     "Could not register product, try again !",
                                  //     "Continue");
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              },
                              child: const Text("Register")),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"))
                        ],
                      );

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          });
                    } else {
                      AlertDialog alert = AlertDialog(
                        title: const Text("Error"),
                        content:
                            const Text("All fields are mandatory to register!"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Back"))
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
                  height: 42.0,
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ))
        ],
      );
    }
    if (products.length <= 0) {
      return Column(mainAxisAlignment: MainAxisAlignment.end, children: const [
        Text(
          "No values to input",
          style: TextStyle(color: Colors.red, fontSize: 18),
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

  Future<void> loadMyProducts() async {
    setState(() {
      showSpinnerMyProducts = true;
    });
    myProducts = [];
    var url = Uri.parse(Apis.getUserProducts(mobile));
    print(url);
    var response = await http.get(url);

    var data = json.decode(response.body);

    for (var element in data) {
      setState(() {
        myProducts.add(element);
      });
    }

    if (myProducts.isNotEmpty) {
      myProductSelected = myProducts[0];
      setBrand(myProductSelected);
    }

    setState(() {
      showSpinnerMyProducts = false;
    });
  }

  checkForFeedback() {
    if (apiResult && ApplicationData.mobile != "") {
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
          child: const Text(
            "No pending feedback~~",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        );
      }

      return Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "You have a pending feedback.",
                  style: TextStyle(
                    fontSize: 14,
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
                    child: const Text(
                      'Start Feedback',
                      style: TextStyle(fontSize: 14),
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
          child: const Text(
            "No pending feedback",
            style: TextStyle(color: Colors.red, fontSize: 18),
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
                    child: const Text(
                      'Start Defect Reporting',
                      style: TextStyle(fontSize: 14),
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
      featureList[featureList.keys.elementAt(i)] = "$month-$year";
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Month & Year of Purchase",
            style: TextStyle(color: Colors.blue, fontSize: 18),
          ),
          DropdownButton(
            style: const TextStyle(
              color: Colors.blue,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 18,
            iconEnabledColor: Colors.red,
            hint: const Text(
              "MM",
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            items: months.map((String prod) {
              return DropdownMenuItem(
                value: prod,
                child: Text(
                  prod,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                month = newValue!;
              });
              featureList[featureList.keys.elementAt(i)] = "$month-$year";
            },
            value: month,
          ),
          DropdownButton(
            style: const TextStyle(
              color: Colors.blue,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 18,
            iconEnabledColor: Colors.red,
            hint: const Text(
              "YY",
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            items: years.map<DropdownMenuItem<String>>((String prod) {
              return DropdownMenuItem(
                value: prod,
                child: Text(
                  prod,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                year = newValue!;
                getMonths();
              });
              featureList[featureList.keys.elementAt(i)] = "$month-$year";
            },
            value: year,
          ),
        ],
      );
    } else if (featureList.keys.elementAt(i).toString().contains("Price")) {
      return Padding(
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
            style: const TextStyle(color: Colors.brown),
            decoration: InputDecoration(
              enabled: true,
              labelText: featureList.keys.elementAt(i),
              labelStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 25.0,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
          ),
        ),
      );
    } else if (featureList.keys
        .elementAt(i)
        .toString()
        .contains("Purchase Type")) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton(
            style: const TextStyle(
              color: Colors.blue,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            hint: const Text(
              "Purchase Type",
              style: TextStyle(color: Colors.blueAccent, fontSize: 18),
            ),
            iconSize: 18,
            iconEnabledColor: Colors.red,
            items: ['New Product', 'Used Product'].map((String prod) {
              return DropdownMenuItem(
                value: prod,
                child: Text(
                  prod,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
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
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 54.0),
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
          style: const TextStyle(color: Colors.brown),
          decoration: InputDecoration(
            enabled: true,
            labelText: featureList.keys.elementAt(i),
            labelStyle: const TextStyle(
              color: Colors.blue,
              fontSize: 25.0,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
          ),
        ),
      ),
    );
  }

  List<String> getYears() {
    final currentYear = DateTime.parse(DateTime.now().toString());

    List<String> years = <String>[];

    for (int i = currentYear.year; i >= currentYear.year - 10; i--) {
      years.add(i.toString());
    }

    return years;
  }

  getMyProductsList() {
    setState(() {
      showSpinner = true;
    });

    List<String> myProductsList = <String>[];

    for (var prod in myProducts) {
      if (prod["productName"] != null &&
          !myProductsList.contains(prod["productName"].toString())) {
        myProductsList.add(prod["productName"].toString());
      }
    }

    setState(() {
      showSpinner = false;
    });

    if (myProductsList.length <= 0) {
      myProductsList.add(myProductSelected);
      myProductSelected = "My Products";
    } else {
      myProductSelected = myProductsList[0];
    }

    return myProductsList;
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
    endIndex = 0;
    for (int i = 0; i < surveys[0]["feedbackQuestion"].length; i++) {
      String mst =
          surveys[0]["feedbackQuestion"][i]["mainScreentitle"].toString();
      String ttl = surveys[0]["feedbackQuestion"][i]["titleLine"].toString();

      String qst =
          surveys[0]["feedbackQuestion"][i]["questionTitle"].toString();

      if (mst == mainScreenTitle && ttl == titleLine && qst == questionTitle) {
        currentSurvey.add(surveys[0]["feedbackQuestion"][i]);
        endIndex++;
        startIndex = i;
      }
    }

    //Setting indexes
    questionIndex = startIndex;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Text(
              surveys[0]["feedbackQuestion"][questionIndex]["mainScreentitle"],
              style: const TextStyle(
                overflow: TextOverflow.clip,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
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
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Text(
              processQuestion(surveys[0]["feedbackQuestion"][questionIndex]
                  ["questionTitle"]),
              overflow: TextOverflow.clip,
              style: const TextStyle(
                overflow: TextOverflow.clip,
                fontSize: 14,
                color: Colors.redAccent,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    processQuestion(currentSurvey[i]["question"]),
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
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
        getBottomButtonSet(),
      ],
    );
  }

  getAnswerType(String answerType, int pos) {
    var responses = ['Yes', 'No'];
    var index = startIndex - pos;

    if (answerType == "Checkbox") {
      print("In checkbos");
      return Checkbox(
        value: surveys[0]["feedbackQuestion"][index]["answer"] == ""
            ? false
            : surveys[0]["feedbackQuestion"][index]["answer"],
        onChanged: (value) {
          setState(() {
            surveys[0]["feedbackQuestion"][index]["answer"] = value;
          });
          //Disabling all other tickboxes with same questionTitle
          disableAllOthers(
              surveys[0]["feedbackQuestion"][index]["questionTitle"], index);
        },
        checkColor: Colors.white,
        hoverColor: Colors.red,
      );
    }

    if (answerType.contains("Yes")) {
      // surveys[0]["feedbackQuestion"][index]["answer"] =
      //     (surveys[0]["feedbackQuestion"][index]["answer"] == ""
      //         ? "Yes"
      //         : surveys[0]["feedbackQuestion"][index]["answer"]);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToggleSwitch(
            minWidth: 90.0,
            minHeight: 40.0,
            fontSize: 15.0,
            initialLabelIndex:
                surveys[0]["feedbackQuestion"][index]["answer"] == ""
                    ? -1
                    : responses.indexOf(
                        surveys[0]["feedbackQuestion"][index]["answer"]),
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.grey[900],
            totalSwitches: 2,
            radiusStyle: true,
            labels: responses,
            onToggle: (index1) {
              surveys[0]["feedbackQuestion"][index]["answer"] =
                  responses[index1!];

              if (surveys[0]["feedbackQuestion"][questionIndex]["question"] ==
                  "I complained to the manufacturer/retailer") {
                print("questionIndex is " + questionIndex.toString());
                updateCurrentSurveyWithComplaintStatus(responses[index1]);
              }
            },
          ),
          const SizedBox(
            height: 120,
          )
        ],
      );
    } else if (answerType == ("CheckBox")) {
      print("In checkbos");
      return Container(
        child: Checkbox(
          value: surveys[0]["feedbackQuestion"][index]["answer"] == ""
              ? false
              : surveys[0]["feedbackQuestion"][index]["answer"],
          onChanged: (value) {
            setState(() {
              surveys[0]["feedbackQuestion"][index]["answer"] = value;
            });
          },
          checkColor: Colors.blue,
          hoverColor: Colors.yellow,
        ),
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
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
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
                  style: const TextStyle(color: Colors.red),
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
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
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
                  "${getWordCount(surveys[0]["feedbackQuestion"][index]["answer"]["text"])}/100",
                  style: const TextStyle(color: Colors.red),
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
                  color: Colors.teal,
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
                  color: Colors.teal,
                ),
              ),
              InkResponse(
                onTap: (() {
                  AlertDialog alert = AlertDialog(
                    title: const Text("Select Upload type"),
                    content: StatefulBuilder(
                      builder: (BuildContext context, _setState) {
                        return Column(
                          children: [
                            Builder(builder: (context) {
                              return RadioListTile(
                                title: const Text("Image file"),
                                value: "image",
                                groupValue: fileType,
                                onChanged: (value) {
                                  fileType = value.toString();
                                  _setState(() {
                                    fileType = value.toString();
                                  });
                                  print("Radio tile is $fileType");
                                },
                              );
                            }),
                            Builder(builder: (context) {
                              return RadioListTile(
                                title: const Text("Video File"),
                                value: "video",
                                groupValue: fileType,
                                onChanged: (value) {
                                  _setState(() {
                                    fileType = value.toString();
                                  });
                                },
                              );
                            }),
                          ],
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickFiles(fileType);
                          },
                          child: const Text("Continue")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"))
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                }),
                child: const Icon(Icons.upload_file),
              )
            ],
          ),
          checkForAudioFileStatus(index),
          checkForImageFileStatus(index),
          checkForVideoFileStatus(index),
        ],
      );
    } else if (answerType == "Audio/Descriptive") {
      print(surveys[0]["feedbackQuestion"][index]["answer"]);
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
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
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
                  "${getWordCount(surveys[0]["feedbackQuestion"][index]["answer"]["text"])}/100",
                  style: const TextStyle(color: Colors.red),
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
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          checkForAudioFileStatus(index),
        ],
      );
    } else if (answerType.contains("Rating")) {
      try {
        getRatingsArray(answerType, index);
        var responses = responseArray;

        surveys[0]["feedbackQuestion"][index]["answer"] =
            surveys[0]["feedbackQuestion"][index]["answer"] == ""
                ? ""
                : surveys[0]["feedbackQuestion"][index]["answer"];

        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < responses.length; i++)
                  InkWell(
                    onTap: (() {
                      setState(() {
                        for (int j = 0; j < isSelected[index]!.length; j++) {
                          isSelected[index]![j] = j == i;
                          surveys[0]["feedbackQuestion"][index]["answer"] =
                              i.toString();
                        }
                      });
                    }),
                    child: SizedBox(
                      width: getWidth(
                          responses[i],
                          GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: color)),
                      child: Text(responses[i],
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: surveys[0]["feedbackQuestion"][index]
                                          ["answer"] ==
                                      i.toString()
                                  ? Colors.green
                                  : Colors.orange)),
                    ),
                  ),
                const SizedBox(
                  height: 25,
                )
              ],
            )
          ],
        ));
      } on Exception catch (_) {
        print(
            "Exception index - $index Current isSelected[index] - ${isSelected[index]} responses - $responseArray");
      } catch (error) {
        print(
            "Exception index - $index Current isSelected[index] - ${isSelected[index]} responses - $responseArray");
      }
    }

    // for (int i = 0; i < responses.length; i++)
    //   Text(
    //     responses[i],
    //     style: GoogleFonts.roboto(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 12.0,
    //         color: Colors.orange),
    //     maxLines: 2,
    //   ),

    return Container();
  }

  getBottomButtonSet() {
    var arraySize = surveys[0]["feedbackQuestion"].length;
    if (questionIndex <= 1 && questionIndex < arraySize - 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
              child: Image.asset(
                "images/right.png",
                width: 40,
                height: 30,
              ),
              onTap: () {
                setState(() {
                  questionIndex++;
                  ratingsArrayLoaded = false;
                });
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
                width: 40,
                height: 30,
              ),
              onTap: () {
                setState(() {
                  questionIndex = questionIndex - endIndex;
                  ratingsArrayLoaded = false;
                });
              }),
          SizedBox(width: size.width * .71),
          InkWell(
              child: Image.asset(
                "images/right.png",
                width: 35,
                height: 30,
              ),
              onTap: () {
                setState(() {
                  questionIndex++;
                  ratingsArrayLoaded = false;
                });
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
                    width: 40,
                    height: 30,
                  ),
                  onTap: () {
                    setState(() {
                      questionIndex -= endIndex;
                      lastTitle = "LoadLastLine";
                      questionIndex = 0;
                    });
                  }),
              SizedBox(
                width: size.width * .30,
              ),
              Material(
                color: Colors.blue,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 2.0,
                child: MaterialButton(
                  onPressed: () {
                    if (surveys[0]["surveyId"] == "ReplacementSurvey") {
                      ProcessReplacementSurveyResponse(
                          surveys[0]["feedbackQuestion"][superIndex]["answer"]);
                    } else if ((surveys[0]["surveyId"] !=
                        "ReplacementSurvey")) {
                      setState(() {
                        showThankyouMessage = true;
                        questionIndex = 0;
                        superIndex = 0;
                        setNextSurvey(true);
                      });
                    }
                  },
                  minWidth: 50.0,
                  height: 32.0,
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 14),
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
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }
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
    if (question.length > 0) {
      var values = <String>[];
      values = productSelected.toString().split("-");
      question = question.replaceAll("product", values[0].toLowerCase());
      question = question.replaceAll("\"", "");
      question = question.replaceAll("\\n", "\n");
    }

    return question;
  }

  getRatingsArray(answerType, int index) {
    responseArray = [];
    for (int i = 0; i < ratings[answerType].length; i++) {
      responseArray.add(ratings[answerType][i].toString());
    }
  }

  void loadRatingsList() async {
    if (!ratingsArrayLoaded) {
      var url = Uri.parse(Apis.ratingsArray());
      var response = await http.get(url);

      List<dynamic> responseList = jsonDecode(response.body);

      for (int i = 0; i < responseList.length; i++) {
        ratings[responseList[i]["answerType"].toString()] =
            responseList[i]["ratingValues"];
      }

      ratingsArrayLoaded = true;
    }
  }

  startFeedback() {
    String titleLine =
        surveys[0]["feedbackQuestion"][questionIndex]["titleLine"].toString();

    if (lastTitle.isNotEmpty &&
        titleLine.isNotEmpty &&
        (lastTitle == "LoadLastLine" || lastTitle != titleLine)) {
      lastTitle = titleLine;
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
        child: Column(
          children: [
            Text(
              processQuestion(titleLine),
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30.0,
            ),
            MaterialButton(
              color: Colors.white60,
              onPressed: () {
                setState(() {
                  showTitleLineNow = false;
                  lastTitle = titleLine;
                });
              },
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.pink, fontSize: 14.0),
              ),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.only(left: size.width * .7),
            child: InkWell(
              onTap: () async {
                setState(() {
                  AlertDialog alert = AlertDialog(
                    title: const Text("Warning"),
                    content: const Text(
                        "You are leaving the survey while its not complete.If you proceed, it may reset and not"
                        " get recorded.\n\nDo you wish to abort feedback ?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              showThankyouMessage = false;
                              showFeedback = false;
                              showRegistrationPage = false;
                              showSpinnerMyProducts = true;
                              goToHome = true;
                            });

                            //saving data from survey in myProduct selected
                            if (isDefectSurvey) {
                              setState(() {
                                myProductSelected["currentDefectSurvey"] =
                                    surveys[0];
                              });
                            } else {
                              setState(() {
                                myProductSelected["currentMainSurvey"] =
                                    surveys[0];
                                print(myProductSelected["currentMainSurvey"]);
                              });
                            }

                            Navigator.pop(context);
                            questionIndex = 0;

                            setState(() {
                              showSpinnerMyProducts = false;
                            });
                          },
                          child: const Text("Continue")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"))
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                });
              },
              child: const Icon(
                Icons.home,
                size: 35,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Survey id - " + surveys[0]["surveyId"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      "Product - $productSelected",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
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

  MyProducts(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinnerMyProducts,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * .6),
                          child: Row(
                            children: [
                              Material(
                                color: Colors.blue,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0)),
                                child: MaterialButton(
                                    child: const Text(
                                      "Register Product",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.red),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        for (int i = 0;
                                            i < featureList.keys.length;
                                            i++) {
                                          featureList[featureList.keys
                                              .elementAt(i)] = "";
                                        }
                                        year = null;
                                        month = null;
                                        type = null;
                                        showRegistrationPage = true;
                                        isFirstRegistration = true;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Registerd Products",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: DataTable(
                      columnSpacing: 3.0,
                      columns: [
                        const DataColumn(
                            label: Text(
                          "Product",
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        )),
                        const DataColumn(
                            label: Text(
                          "Purchased\nOn",
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        )),
                        const DataColumn(
                            label: Text(
                          "",
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        )),
                        const DataColumn(
                            label: Text(
                          "",
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        ))
                      ],
                      rows: [
                        for (var product in myProducts)
                          DataRow(cells: [
                            DataCell(Text(
                              product["productName"].toString(),
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 13.0),
                            )),
                            DataCell(Text(
                              product["features"]["Purchase Date"].toString(),
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 13.0),
                            )),
                            DataCell(InkWell(
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onTap: () {
                                AlertDialog alert = AlertDialog(
                                  title: const Text("Alert"),
                                  content: Text(
                                      "Do you wish to remove ${product["productName"].toString()}"
                                      " from your list of products ? "),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            myProducts.remove(product);
                                          });
                                          RemoveProductFromUser(product);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Continue")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"))
                                  ],
                                );

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    });
                              },
                            )),
                            DataCell(InkWell(
                              child: const Icon(
                                Icons.info,
                                color: Colors.blue,
                              ),
                              onTap: () {
                                AlertDialog alert = AlertDialog(
                                  title: const Text("Product Details"),
                                  content: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: getFeaturesAsRowWidget(product),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Back"))
                                  ],
                                );

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                          child: alert);
                                    });
                              },
                            )),
                          ]),
                      ],
                    ),
                  )
                ]),
          ),
        ));
  }

  MyProductsPage(BuildContext context) {
    if (showRegistrationPage) {
      return RegisterProduct(context);
    } else {
      return MyProducts(context);
    }
  }

  Future<void> RemoveProductFromUser(product) async {
    var url =
        Uri.parse(Apis.deleteProductFromUser(product["productName"], mobile));
    print(url);
    var response = await http.delete(url, body: jsonEncode(product));
    print('Deleted user product successfully - ${response.body}');
  }

  DataCell checkForActiveFeedbackAndGetDataCell(product) {
    if (product["currentMainSurvey"]["next"]) {
      return DataCell(MaterialButton(
        color: Colors.white60,
        onPressed: () {
          if (product["currentMainSurvey"]["surveyId"] == "QS2") {
            setState(() {
              ApplicationData.audioMessage =
                  "Voice record your reason for not complaining. Limit 02 minutes";
            });
          }
          if (product["currentMainSurvey"]["surveyId"] == "QS1") {
            setState(() {
              myProductSelected = product;
              setBrand(myProductSelected);
              startSurveyProcess(myProductSelected["currentMainSurvey"]);
              isDefectSurvey = false;
            });
          } else {
            for (var survey in allSurveys) {
              if (survey["surveyId"] == "ReplacementSurvey") {
                setState(() {
                  myProductSelected = product;
                  setBrand(myProductSelected);
                  startSurveyProcess(survey);
                  isDefectSurvey = false;
                });
              }
            }
          }
        },
        child: const Text(
          "Pending Feedback",
          style: TextStyle(color: Colors.pink, fontSize: 12.0),
        ),
      ));
    }
    return const DataCell(
      Text(
        "No Pending Feedback",
        style: TextStyle(color: Colors.pink, fontSize: 12.0),
      ),
    );
  }

  DataCell SetDefectReportAndGetDataCell(product) {
    myProductSelected = product;
    setBrand(myProductSelected);

    return DataCell(MaterialButton(
      color: Colors.white60,
      onPressed: () {
        setState(() {
          myProductSelected = product;
          setBrand(myProductSelected);
          startSurveyProcess(myProductSelected["currentDefectSurvey"]);
          isDefectSurvey = true;
          ApplicationData.audioMessage =
              "Voice record your issue in detail. Limit 02 minutes";
        });
        print('product is ' + product["productName"]);
      },
      child: const Text(
        "Report a problem",
        style: TextStyle(color: Colors.pink, fontSize: 12.0),
      ),
    ));
  }

  void setIsSelected(int index) {
    print('Question index is $questionIndex');
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
        const Text(
          "Audio",
          style: TextStyle(fontSize: 15, color: Colors.brown),
        ),
        InkResponse(
          onTap: (() {
            AudioPlayer(
              source: surveys[0]["feedbackQuestion"][superIndex]["answer"]
                  ["audio"]!,
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
    });
    var url = ProcessUrl(Apis.setNextSurveyForFeedback(mobile,
        myProductSelected["productName"], surveyId, isReplacementSurvey));
    print(url);

    var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(currentSurvey));
    print("Response to setNextSurvey = ${response.body}");
    loadMyProducts();
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> loadAllSurveys() async {
    setState(() {
      showSpinner = true;
    });
    var response = await http.get(Uri.parse(Apis.getAllSurveys()));

    print(Apis.getAllSurveys());
    var data = json.decode(response.body);

    for (var element in data) {
      if (element["surveyId"] == "QS2   Defect") {
        qs2DefectSurveyLength = element["feedbackQuestion"].length;
      }
      allSurveys.add(element);
    }
    // productSelected = products[0];
    setState(() {
      //  productSelected = products[0];

      showSpinner = false;
    });
  }

  String ProcessUrl(String url) {
    url = url.replaceAll(" ", '%20');
    return url;
  }

  void ProcessReplacementSurveyResponse(String response) {
    if (response == "Yes") {
      AlertDialog alert = AlertDialog(
        title: const Text("Alert"),
        content: Text(
            "You have chosen that your ${getProductName(myProductSelected).toString().toLowerCase()}"
            " has been replaced. You will be redirected to register the new product. "),
        actions: [
          TextButton(
              onPressed: () {
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
              child: const Text("Continue")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"))
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
    print(
        "surveys[0]['feedbackQuestion'].length - ${surveys[0]["feedbackQuestion"].length}");
    print("qs2DefectSurveyLength - $qs2DefectSurveyLength");
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
      getBottomButtonSet();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ApplicationData.audioMessage,
                style: TextStyle(fontSize: 16, color: Colors.red),
                overflow: TextOverflow.clip,
              )
            ],
          ),
          SizedBox(
            height: ApplicationData.screenHeight * .25,
            width: ApplicationData.screenWidth,
            child: AudioRecorder(
              onStop: (path) {
                if (kDebugMode) print('Recorded file path: $path');
                setState(() {
                  surveys[0]["feedbackQuestion"][superIndex]["answer"]
                      ["audio"] = path.toString();
                });
              },
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
                    showRecording = false;
                  });
                  //   loadMyProducts();
                });
              },
              minWidth: 50.0,
              height: 32.0,
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 14),
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
                source: surveys[0]["feedbackQuestion"][superIndex]["answer"]
                    ["audio"]!,
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
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 14),
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
        const Text(
          "Audio File uploaded.",
          style: TextStyle(color: Colors.deepOrange, fontSize: 16),
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
        const Text(
          "Image File uploaded.",
          style: TextStyle(color: Colors.deepPurple, fontSize: 16),
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
                        content: Image.file(File(surveys[0]["feedbackQuestion"]
                                [index]["answer"]["image"]
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
                              child: const Text(
                                'Back',
                                style: TextStyle(fontSize: 14),
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
        const Text(
          "Video File uploaded.",
          style: TextStyle(color: Colors.deepPurple, fontSize: 16),
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
                    return VideoApp(surveys[0]["feedbackQuestion"][index]
                        ["answer"]["video"]);
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
        onImageCaptured: (value) {
          final String path = value.path;
          if (path.contains('jpg')) {
            print("Path is $path");

            setState(() {
              surveys[0]["feedbackQuestion"][superIndex]["answer"]["image"] =
                  path;
              ApplicationData.showVideoPlayer = false;
              showFeedback = true;
            });
          } else {
            setState(() {
              ApplicationData.showVideoPlayer = false;
              showFeedback = true;
            });
          }
        },
        onVideoRecorded: (value) {
          final path = value.path;
          print('::::::::::::::::::::::::;; $path');

          setState(() {
            surveys[0]["feedbackQuestion"][superIndex]["answer"]["video"] =
                path;
            ApplicationData.showVideoPlayer = false;
            showFeedback = true;
          });

          ///Show video preview .mp4
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
    setState(() {
      if (_paths != null) {
        if (fileType == "image") {
          surveys[0]["feedbackQuestion"][superIndex]["answer"]["image"] =
              _paths![0].path.toString();
        } else {
          surveys[0]["feedbackQuestion"][superIndex]["answer"]["video"] =
              _paths![0].path.toString();
        }
      }
    });
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
}
