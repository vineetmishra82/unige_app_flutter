import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera/flutter_camera.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/LoginScreen.dart';

import '../Other_data/Apis.dart';

class HomePage extends StatefulWidget {
  static String id = "HomePage";
  String mobileNum;
  HomePage(this.mobileNum);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool showSpinner = false;
  Color color = Colors.orange;
  final recorder = FlutterSoundRecorder();
  AudioPlayer player = AudioPlayer();
  PlayerState playerState = PlayerState.paused;
  String name = "",
      email = "",
      mobile = ApplicationData.mobile,
      myProductBrand = "",
      feedbackType = "Next Feedback",
      lastTitle = "LoadLastLine",
      type = 'New Product';
  String myProductSelected = "";
  String? productSelected = null, month = null, year = null, audioFile = null;
  String audioFilePath = "";

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
      isPlaying = false;

  var featureList = {};
  int val = 3, tabIndex = 0;

  bool showThankyouMessage = false;

  bool showTitleLineNow = true;
  late TabController tabController;
  Map<int, List<bool>> isSelected = {};
  IconData icon = Icons.mic;

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
    year = currentYear.year.toString();
    getMonths();
    tabController = TabController(length: 3, vsync: this);
    initRecorder();

    player.onPlayerStateChanged.listen((PlayerState p) {
      setState(() {
        playerState = p;
      });
      print("Player state is $playerState");
    });
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(ApplicationData.screenHeight * .2),
          child: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: kToolbarHeight,
                    margin: EdgeInsets.only(
                        top: 20.0, left: ApplicationData.screenWidth * .1),
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(left: ApplicationData.screenWidth * .2),
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
            children: [MyProductsPage(), MyFeedback(), MyProfile()],
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

  MyProfile() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: const Text(
              "Profile  details",
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 28.0,
          ),
          Container(
            child: Text(
              "Name - " + name,
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 28.0,
          ),
          Container(
            child: Text(
              "Mobile - " + mobile,
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 28.0,
          ),
          Container(
            child: Text(
              "Email - " + email,
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 28.0,
          ),
        ]);
  }

  getUserDetails() async {
    String mobile = ApplicationData.mobile;

    if (mobile.isNotEmpty) {
      // setState(() {
      //   showSpinner = true;
      // });

      var url = Uri.parse(Apis.getUser(mobile));
      var response = await http.get(url);

      setState(() {
        showSpinner = false;
      });

      Map<String, dynamic> values = json.decode(response.body);
      name = values["name"];
      email = values["email"];
    }
  }

  Future<void> loadProducts() async {
    setState(() {
      showSpinner = true;
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

      showSpinner = false;
    });
  }

  MyFeedback() {
    if (showThankyouMessage) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: (Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              processQuestion(surveys[0]["thankYouText"]),
              style: TextStyle(fontSize: 18, color: Colors.pink),
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
    } else if (showFeedback) {
      return startFeedback();
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            DataTable(columns: [
              DataColumn(
                label: Text(
                  "",
                  style: TextStyle(fontSize: 12.0, color: Colors.red),
                ),
              ),
              DataColumn(label: Text("")),
              DataColumn(label: Text(""))
            ], rows: [
              for (var product in myProducts)
                if (product["active"] == true)
                  DataRow(cells: [
                    DataCell(Text(
                      product["productName"],
                      style: TextStyle(
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
      );
    }
  }

  RegisterProduct() {
    bool showSpinner = false;
    return Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: ApplicationData.screenWidth * .6),
                      child: Material(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: MaterialButton(
                            child: Text(
                              "Back",
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                            onPressed: () {
                              setState(() {
                                showRegistrationPage = false;
                              });
                            }),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Select Category",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
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
                                child: Text(prod),
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
                    setState(() {
                      showSpinner = true;
                    });
                    var url = Uri.parse(
                        Apis.registerProduct(productSelected.toString()));
                    print(url);
                    print(jsonEncode(featureList));
                    var response = await http.post(url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(featureList));

                    if (response.body == "true") {
                      await loadMyProducts();
                      AlertDialog alert = AlertDialog(
                        title: Text("Success"),
                        content: Text("Thank you for registering your " +
                            productSelected.toString().toLowerCase()),
                        actions: [
                          TextButton(
                              onPressed: () {
                                tabController.animateTo(1);
                                Navigator.pop(context);
                              },
                              child: Text("Continue"))
                        ],
                      );

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          });

                      setState(() {
                        showSpinner = false;
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
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: const [
      Text(
        "No values to input",
        style: TextStyle(color: Colors.red),
      ),
    ]);
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
      showSpinner = true;
    });
    myProducts = [];
    var url = Uri.parse(Apis.getUserProducts(mobile));
    print(url);
    var response = await http.get(url);

    var data = json.decode(response.body);

    for (var element in data) {
      myProducts.add(element);
    }

    if (myProducts.isNotEmpty) {
      myProductSelected = myProducts[0]["productName"];
      setBrand(myProductSelected);
    }

    // setState(() {
    //   showSpinner = false;
    // });
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
          child: Text(
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
                Text(
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
            SizedBox(
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
            SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }
  }

  getChildOfFeaturesList(int i) {
    if (featureList.keys.elementAt(i).toString().contains("Purchase Date")) {
      featureList[featureList.keys.elementAt(i)] =
          month.toString() + "-" + year.toString();
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
                  style: TextStyle(fontSize: 18),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                month = newValue!;
              });
              featureList[featureList.keys.elementAt(i)] =
                  month.toString() + "-" + year.toString();
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
                  style: TextStyle(fontSize: 18),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                year = newValue!;
                getMonths();
              });
              featureList[featureList.keys.elementAt(i)] =
                  month.toString() + "-" + year.toString();
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
          const Text(
            "Purchase Type",
            style: TextStyle(color: Colors.blue, fontSize: 18),
          ),
          DropdownButton(
            style: const TextStyle(
              color: Colors.blue,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 18,
            iconEnabledColor: Colors.red,
            items: ['New Product', 'Used Product'].map((String prod) {
              return DropdownMenuItem(
                value: prod,
                child: Text(
                  prod,
                  style: TextStyle(fontSize: 18, color: Colors.red),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              surveys[0]["feedbackQuestion"][questionIndex]["mainScreentitle"],
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Text(
              processQuestion(surveys[0]["feedbackQuestion"][questionIndex]
                  ["questionTitle"]),
              overflow: TextOverflow.clip,
              style: TextStyle(
                overflow: TextOverflow.clip,
                fontSize: 14,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        for (int i = 0; i < currentSurvey.length; i++) ...[
          SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 10),
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
          SizedBox(
            height: 20,
          ),
        ],
        getBottomButtonSet(),
      ],
    );
  }

  getAnswerType(String answerType, int pos) {
    var responses = ['Yes', 'No'];
    int index = startIndex - pos;

    if (answerType.contains("Yes")) {
      surveys[0]["feedbackQuestion"][index]["answer"] =
          (surveys[0]["feedbackQuestion"][index]["answer"] == ""
              ? "Yes"
              : surveys[0]["feedbackQuestion"][index]["answer"]);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToggleSwitch(
            minWidth: 90.0,
            minHeight: 40.0,
            fontSize: 15.0,
            initialLabelIndex:
                (surveys[0]["feedbackQuestion"][index]["answer"] == ""
                    ? 1
                    : responses.indexOf(
                        surveys[0]["feedbackQuestion"][index]["answer"])),
            activeBgColor: [Colors.green],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.grey[900],
            totalSwitches: 2,
            radiusStyle: true,
            labels: responses,
            onToggle: (index) {
              if (surveys[0]["surveyId"] == "ReplacementSurvey") {
                ProcessReplacementSurveyResponse(responses[index!]);
              }

              surveys[0]["feedbackQuestion"][index]["answer"] =
                  responses[index!];
            },
          ),
          SizedBox(
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
                surveys[0]["feedbackQuestion"][index]["answer"] = value;
                len = value.length;
              },
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
              maxLength: 10,
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
                  surveys[0]["feedbackQuestion"][index]["answer"]
                          .length
                          .toString() +
                      "/10",
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          )
        ],
      );
    } else if (answerType == "Audio/Descriptive") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TextFormField(
              initialValue: surveys[0]["feedbackQuestion"][index]["answer"],
              maxLines: 3,
              onChanged: (String value) {
                setState(() {
                  len = value.length;
                  surveys[0]["feedbackQuestion"][index]["answer"] = value;
                });
              },
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
              maxLength: 100,
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
                  surveys[0]["feedbackQuestion"][index]["answer"].toString() +
                      "/100",
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
                  AlertDialog alert = AlertDialog(
                    title: Text(
                        "Press the mic to start recording.  Limit - 2 mins"),
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                            ),
                            StreamBuilder<RecordingDisposition>(
                              stream: recorder.onProgress,
                              builder: (context, snapshot) {
                                final duration = snapshot.hasData
                                    ? snapshot.data!.duration
                                    : Duration.zero;

                                String twoDigits(int n) =>
                                    n.toString().padLeft(2, '0');

                                final twoDigitMins =
                                    twoDigits(duration.inMinutes.remainder(60));

                                final twoDigitSecs =
                                    twoDigits(duration.inSeconds.remainder(60));

                                if ('$twoDigitMins:$twoDigitSecs' == "02:00") {
                                  stopAudioRecording();
                                }

                                return Text(
                                  '$twoDigitMins:$twoDigitSecs',
                                  style: TextStyle(
                                      fontSize: 50.0,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            ElevatedButton(
                              onPressed: (() async {
                                setState(() {
                                  if (icon == Icons.mic) {
                                    icon = Icons.stop;
                                  } else {
                                    icon = Icons.mic;
                                  }
                                });

                                if (recorder.isRecording) {
                                  await stopAudioRecording();
                                } else {
                                  await recordAudio();
                                }
                              }),
                              child: Icon(
                                icon,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    actions: [
                      TextButton(
                        onPressed: () {
                          stopAudioRecording();
                          Navigator.pop(context);
                        },
                        child: Text("Done", style: TextStyle(fontSize: 20)),
                      )
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                }),
                child: Image.asset(
                  'images/mic.png',
                  height: 40.0,
                  color: Colors.teal,
                ),
              ),
              Container(child: getAudioFileNameAndDeleteOption()),
            ],
          )
        ],
      );
    } else if (answerType == "Multimedia/Descriptive") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TextFormField(
              initialValue: surveys[0]["feedbackQuestion"][index]["answer"],
              maxLines: 3,
              onChanged: (String value) {
                setState(() {
                  surveys[0]["feedbackQuestion"][index]["answer"] = value;
                  len = value.length;
                });
              },
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
              maxLength: 100,
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
                  surveys[0]["feedbackQuestion"][index]["answer"]
                          .length
                          .toString() +
                      "/100",
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
                  AlertDialog alert = AlertDialog(
                    title: Text(
                        "Press the mic to start recording.  Limit - 2 mins"),
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                            ),
                            StreamBuilder<RecordingDisposition>(
                              stream: recorder.onProgress,
                              builder: (context, snapshot) {
                                final duration = snapshot.hasData
                                    ? snapshot.data!.duration
                                    : Duration.zero;

                                String twoDigits(int n) =>
                                    n.toString().padLeft(2, '0');

                                final twoDigitMins =
                                    twoDigits(duration.inMinutes.remainder(60));

                                final twoDigitSecs =
                                    twoDigits(duration.inSeconds.remainder(60));

                                if ('$twoDigitMins:$twoDigitSecs' == "02:00") {
                                  stopAudioRecording();
                                }

                                return Text(
                                  '$twoDigitMins:$twoDigitSecs',
                                  style: TextStyle(
                                      fontSize: 50.0,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            ElevatedButton(
                              onPressed: (() async {
                                setState(() {
                                  if (icon == Icons.mic) {
                                    icon = Icons.stop;
                                  } else {
                                    icon = Icons.mic;
                                  }
                                });

                                if (recorder.isRecording) {
                                  await stopAudioRecording();
                                } else {
                                  await recordAudio();
                                }
                              }),
                              child: Icon(
                                icon,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    actions: [
                      TextButton(
                        onPressed: () {
                          stopAudioRecording();
                          Navigator.pop(context);
                        },
                        child: Text("Done", style: TextStyle(fontSize: 20)),
                      )
                    ],
                  );

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                }),
                child: Image.asset(
                  'images/mic.png',
                  height: 40.0,
                  color: Colors.teal,
                ),
              ),
              Container(child: getAudioFileNameAndDeleteOption()),
              InkResponse(
                onTap: (() {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const CameraPage()));
                }),
                child: Image.asset(
                  'images/camera.png',
                  height: 40.0,
                  color: Colors.teal,
                ),
              )
            ],
          )
        ],
      );
    } else if (answerType == "Audio/Descriptive") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TextFormField(
              initialValue: surveys[0]["feedbackQuestion"][index]["answer"],
              maxLines: 3,
              onChanged: (String value) {
                surveys[0]["feedbackQuestion"][index]["answer"] = value;
                len = value.length;
              },
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
              maxLength: 100,
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
                  surveys[0]["feedbackQuestion"][index]["answer"]
                          .length
                          .toString() +
                      "/100",
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
                  print('Mic start');
                }),
                child: Image.asset(
                  'images/mic.png',
                  height: 40.0,
                  color: Colors.teal,
                ),
              ),
            ],
          )
        ],
      );
    } else if (answerType.contains("Rating")) {
      try {
        getRatingsArray(answerType, index);
        var responses = responseArray;

        surveys[0]["feedbackQuestion"][index]["answer"] =
            surveys[0]["feedbackQuestion"][index]["answer"] == ""
                ? val.toString()
                : surveys[0]["feedbackQuestion"][index]["answer"];

        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
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
                      print(isSelected[index]![i]);
                      print(color.toString());
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
                              color: isSelected[index]![i]
                                  ? Colors.green
                                  : Colors.orange)),
                    ),
                  ),
                SizedBox(
                  height: 25,
                )
              ],
            )
          ],
        ));
      } on Exception catch (_) {
        print("Exception index - " +
            index.toString() +
            " Current isSelected[index] - " +
            isSelected[index].toString() +
            " responses - " +
            responseArray.toString());
        print(isSelected.toString());
      } catch (error) {
        print("Exception index - " +
            index.toString() +
            " Current isSelected[index] - " +
            isSelected[index].toString() +
            " responses - " +
            responseArray.toString());
        print(isSelected.toString());
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
          SizedBox(width: ApplicationData.screenWidth * .71),
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
                width: ApplicationData.screenWidth * .30,
              ),
              Material(
                color: Colors.blue,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 2.0,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      showThankyouMessage = true;
                      questionIndex = 0;
                      setNextSurvey(true);
                    });
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
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }
  }

  void setBrand(String myProductSelected) {
    for (var prod in myProducts) {
      if (prod["productName"] == myProductSelected) {
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
        padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
        child: Column(
          children: [
            Text(
              processQuestion(titleLine),
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
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
              child: Text(
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
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.only(left: ApplicationData.screenWidth * .7),
            child: Material(
              color: Colors.blue,
              elevation: 2.0,
              child: MaterialButton(
                onPressed: () async {
                  setState(() {
                    showThankyouMessage = false;
                    showFeedback = false;
                    questionIndex = 0;
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
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Survey id - " + surveys[0]["surveyId"],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      "Product - " + productSelected.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(
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

  MyProducts() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: ApplicationData.screenWidth * .6),
                          child: Row(
                            children: [
                              Material(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: MaterialButton(
                                    child: Text(
                                      "Register Product",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.red),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showRegistrationPage = true;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Registerd Products",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: DataTable(
                      columnSpacing: 3.0,
                      columns: [
                        DataColumn(
                            label: Text(
                          "Product",
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        )),
                        DataColumn(
                            label: Text(
                          "Purchased On",
                          style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        )),
                        DataColumn(
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
                              style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 13.0),
                            )),
                            DataCell(Text(
                              product["features"]["Purchase Date"].toString(),
                              style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 13.0),
                            )),
                            DataCell(MaterialButton(
                              color: Colors.white60,
                              onPressed: () {
                                if (sendForDeleteConfirmation()) {
                                  setState(() {
                                    myProducts.remove(product);
                                  });
                                  RemoveProductFromUser(product);
                                }
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: Colors.pink, fontSize: 12.0),
                              ),
                            ))
                          ]),
                      ],
                    ),
                  )
                ]),
          ),
        ));
  }

  MyProductsPage() {
    if (showRegistrationPage) {
      return RegisterProduct();
    } else {
      return MyProducts();
    }
  }

  bool sendForDeleteConfirmation() {
    return true;
  }

  Future<void> RemoveProductFromUser(product) async {
    var url = Uri.parse(Apis.deleteProductFromUser(product["productName"]));
    print(url);
    var response = await http.delete(url, body: jsonEncode(product));
    print('Deleted user product successfully - ${response.body}');
  }

  DataCell checkForActiveFeedbackAndGetDataCell(product) {
    myProductSelected = product["productName"];
    setBrand(myProductSelected);
    for (var survey in product["surveys"]) {
      if (survey["next"] == true && survey["complete"] == false) {
        return DataCell(MaterialButton(
          color: Colors.white60,
          onPressed: () {
            setState(() {
              productSelected = product["productName"];
              surveys = [];
              surveys.add(survey);
              showFeedback = true;
              showThankyouMessage = false;
              loadRatingsIsSelected();
            });
          },
          child: Text(
            "Pending Feedback",
            style: TextStyle(color: Colors.pink, fontSize: 12.0),
          ),
        ));
      }
    }

    return DataCell(
      Text(
        "No Pending Feedback",
        style: TextStyle(color: Colors.pink, fontSize: 12.0),
      ),
    );
  }

  DataCell SetDefectReportAndGetDataCell(product) {
    myProductSelected = product["productName"];
    setBrand(myProductSelected);
    for (var survey in allSurveys) {
      if (survey["defectSurvey"] == true &&
          survey["surveyId"] == "Defect Report") {
        return DataCell(MaterialButton(
          color: Colors.white60,
          onPressed: () {
            setState(() {
              productSelected = product["productName"];
              surveys = [];
              surveys.add(survey);
              showFeedback = true;
              showThankyouMessage = false;
              loadRatingsIsSelected();
            });
            print('product is ' + product["productName"]);
          },
          child: Text(
            "Report a problem",
            style: TextStyle(color: Colors.pink, fontSize: 12.0),
          ),
        ));
      }
    }

    return DataCell(
      Text(
        "No Pending Feedback",
        style: TextStyle(color: Colors.pink, fontSize: 12.0),
      ),
    );
  }

  void setIsSelected(int index) {
    print('Question index is ' + questionIndex.toString());
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

    print(isSelected);
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

  Future stopAudioRecording() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();

    setState(() {
      audioFilePath = path.toString();
    });

    print("Path is $audioFilePath");
    getAudioFileNameAndDeleteOption();
  }

  Future recordAudio() async {
    audioFilePath = "";
    print("Pre Path is $audioFilePath");
    if (!isRecorderReady) return;
    audioFile = mobile + "-" + productSelected!;

    await recorder.startRecorder(toFile: (audioFile));
  }

  Future initRecorder() async {
    var status = await Permission.microphone.request();

    print("status is $status");

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  getAudioFileNameAndDeleteOption() {
    if (audioFilePath == "") {
      return Text("");
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Audio",
            style: TextStyle(fontSize: 15, color: Colors.brown),
          ),
          InkResponse(
            onTap: (() async {
              setState(() {
                isPlaying = !isPlaying;
              });

              if (isPlaying) {
                await player.play(AssetSource(audioFilePath));
              } else {
                await player.pause();
              }
            }),
            child: Icon(
              (playerState == PlayerState.playing)
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.red,
              size: 40,
            ),
          ),
          InkResponse(
            onTap: (() {
              setState(() {
                audioFilePath = "";
              });
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
  }

  Future<void> setNextSurvey(bool value) async {
    var currentSurvey = surveys[0];

    var surveyId = "";

    switch (currentSurvey["surveyId"]) {
      case 'QS1':
        surveyId = "QS2";
        break;

      case 'QS2':
        surveyId = "QS2";
        break;

      case 'Defect Report':
        surveyId = "QS2 Defect";
        break;

      case 'QS2 Defect':
        surveyId = "QS2";
        break;
    }

    var isReplacementSurvey = value;

    setState(() {
      showSpinner = true;
    });
    var url = ProcessUrl(Apis.setNextSurveyForFeedback(
        mobile, myProductSelected, surveyId, isReplacementSurvey));
    print(url);
    var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(currentSurvey));
    print("Response to setNextSurvey = ${response.body}");
    loadAllSurveys();
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
      allSurveys.add(element);
    }
    // productSelected = products[0];
    setState(() {
      //  productSelected = products[0];

      showSpinner = false;
    });

    print("All surveys $allSurveys");
  }

  String ProcessUrl(String url) {
    url = url.replaceAll(" ", '%20');
    return url;
  }
}

void ProcessReplacementSurveyResponse(String response) {

  if(response == "Yes")
    {

    }

}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlutterCamera(
        color: Colors.blueAccent,
        onImageCaptured: (value) {
          final path = value.path;
          print("Path is $path");
          if (path.contains('.jpg')) {
            setState(() {
              ApplicationData.imgPath = path;
            });

            // showDialog(
            //     context: context,
            //     builder: (context) {
            //       return AlertDialog(
            //         content: Image.file(File(path)),
            //       );
            //     });
          }
        },
        onVideoRecorded: (value) {
          final path = value.path;
          print('::::::::::::::::::::::::;; dkdkkd $path');

          setState(() {
            ApplicationData.videoPath = path;
          });

          ///Show video preview .mp4
        },
      ),
    );
    // return Container();
  }
}
