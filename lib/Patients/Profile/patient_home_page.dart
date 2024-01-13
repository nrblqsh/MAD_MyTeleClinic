import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_teleclinic/Patients/Profile/CountDown.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';
//import 'package:my_teleclinic/Chatbox/chatbox.dart';
//import '../../Map/mapLocation.dart';
import '../../Main/main.dart';
import '../../Model/consultation.dart';
import '../../Specialists/ZegoCloud/videocall_zegocloud.dart';
import '../../VideoConsultation/videocall_page.dart';
import '../Chatbox/chatbox.dart';
import '../EMR/add_vital_info.dart';
import '../EMR/current_vital.dart';
import '../EMR/e_medical_record.dart';
import '../EMR/vital_info_report.dart';
import '../Map/mapLocation.dart';
import '../Telemedicine/view_appointment.dart';
import '../Telemedicine/view_specialist.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomePage extends StatefulWidget {
  final String phone;
  final String patientName;
  final int patientID;

  HomePage(
      {required this.phone,
      required this.patientName,
      required this.patientID});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String phone; // To store the retrieved phone number
  late String patientName;
  late int patientID;
  int specialistID=0;
  DateTime consultationDateTime = DateTime.now();
  String consultationStatus='';
  String consultationSymptom='';
  String consultationTreatment = '';
  String specialistName = '';






  int _currentIndex = 2;
  bool hasNewMessage = false;
  int newMessagesCount = 0;
  Position? userLocation;

  int consultationID=29;




  @override
  void initState() {
    _loadData();
    getFCMToken(patientID); // Add this line to retrieve the FCM token
    super.initState();
    getUserLocation();

    // Handle incoming FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleIncomingCall(message);
    });

    // Handle when the app is opened by tapping on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleIncomingCall(message);
    });
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CountdownProvider(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 72,
          backgroundColor: Colors.white,
          title: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "asset/MYTeleClinic.png",
                  width: 594,
                  height: 258,
                ),
              ],
            ),
          ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 255.0, bottom: 3),
                    child: Text(
                      "Welcome,",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        textStyle:
                            const TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, right: 52),
                    child: Text(
                      "${patientName}",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        textStyle:
                        const TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Services",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          textStyle:
                              const TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Icon(
                        Icons.people_alt_sharp,
                        size: 24,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.0),
                      InkWell(
                        onTap: () async {
                          // Check and request camera and microphone permissions
                          var statusCamera = await Permission.camera.request();
                          var statusMicrophone = await Permission.microphone.request();

                          if (statusCamera.isGranted && statusMicrophone.isGranted) {
                            String? callID = await getCallID(consultationID);
                            if (callID != null) {
                              // Handle the case where the channel name is not null
                              print('callID: $callID');
                              print("tess$consultationID");
                              print(patientName);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyCall(callID: callID,id:
                                  patientID.toString(),
                                    name: patientName,
                                  roleId:0),
                                ),
                              );
                            } else {
                              // Handle the case where the channel name is null
                              print('Failed to get channel name from backend.');
                            }

                          } else {
                            // Permissions not granted, show an alert or handle accordingly
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Permission Required'),
                                  content: Text('Camera and microphone permissions are required for video calls.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 180),
                              child: Icon(
                                Icons.mail,
                                size: 32,
                                color: hasNewMessage ? Colors.grey : Colors.grey,
                              ),
                            ),
                            if (hasNewMessage)
                              Positioned(
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: Text(
                                    newMessagesCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MedicalRecordScreen(patientID: patientID)),
                              );
                            },
                            child: Column(
                              children: [
                                Image.network(
                                  "https://cdn-icons-png.flaticon.com/512/1076/1076325.png",
                                  height: 64,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "E-Medical Record",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    textStyle: const TextStyle(
                                        fontSize: 14, color: Colors.blueGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        viewSpecialistScreen(patientID: patientID,)),
                              );
                            },
                            child: Column(
                              children: [
                                Image.network(
                                  "https://cdn-icons-png.flaticon.com/512/5980/5980109.png",
                                  width: 64,
                                  height: 64,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "TeleMedicine",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    textStyle: const TextStyle(
                                        fontSize: 14, color: Colors.blueGrey),
                                  ),
                                ),
                              ],
                            ),

                          ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            ViewAppointmentScreen(patientID: patientID,)),
                      );
                    },
                    child: Column(
                      children: [
                        Image.network(
                          "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678116-calendar-512.png",
                          width: 64,
                          height: 64,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          "View Booking",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            textStyle: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                        ],
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 16.0),
                        child: Row(
                          children: [
                            Text(
                              "Nearby Clinic",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.location_pin,
                              size: 24,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      // Container with FlipClockPlus.countdown

                      Container(
                        height: 407,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.only(left: 15, right: 15, top: 2),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              SizedBox(
                                width: 550,
                                height: 500,
                                child: _buildConsultationList(),
                                // Call a function to build the list
                              ),

                            ],
                          ),
                        ),
                      ),

                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 16.0),
                    child: Row(
                      children: [
                        Text(
                          "Nearby Clinic",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            textStyle: const TextStyle(
                                fontSize: 22, color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Icons.location_pin,
                          size: 24,
                          color: Colors.red,
                        ),
                        SizedBox(height: 25.0),
                      ],
                    ),
                  ),
              Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MapLocation()),
                            );
                          },
                          child: Container(
                            height: 380,
                            width: 250,
                            margin: EdgeInsets.symmetric(vertical: 16.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: userLocation != null
                                        ? LatLng(userLocation!.latitude,
                                            userLocation!.longitude)
                                        : const LatLng(
                                            2.3232303497978815, 102.29396072202006),
                                    zoom: 14,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapLocation()),
                                        );
                                        print("Button tapped!");
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(hexColor('C73B3B'))),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.0), // Adjust the radius as needed
                                          ),
                                        ),
                                      ),
                                      child: Text("Navigate to Map Screen"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            if (index == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MedicalRecordScreen(patientID: patientID)));
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => viewSpecialistScreen(patientID: patientID,)));
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/menu');
            } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewAppointmentScreen(patientID: patientID,)));
            } else if (index == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(patientID: patientID,)));
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'EMR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety),
              label: 'TeleMedicine',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'View Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          backgroundColor: Colors.grey[700],
          selectedItemColor: Colors.blueGrey,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
  // Handle incoming call notification
  void handleIncomingCall(RemoteMessage message) {
    // Extract information from the FCM message
    final Map<String, dynamic> data = message.data;
    final String callId = data['call_id'];

    // Show an incoming call dialog or navigate to the call screen
    // For simplicity, let's assume you have a widget named IncomingCallScreen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incoming Video Call'),
        content: Text('You have an incoming video call from the caller.'),
        actions: [
          TextButton(
            onPressed: () {
              // Reject the call
              Navigator.pop(context);
            },
            child: Text('Reject'),
          ),
          TextButton(
            onPressed: () {
              // Accept the call and navigate to the call screen
              Navigator.pop(context);
              navigateToCallScreen(callId);
            },
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }

  // Navigate to the video call screen
  void navigateToCallScreen(String callId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyCall(
        callID: callId,
        id: patientID.toString(),
        name: patientName,
      roleId: 0)),
    );
  }
  Widget _buildConsultationList() {
    return FutureBuilder<List<Consultation>>(
      future: _fetchTodayConsultationsPatientSide(patientID),
      builder: (BuildContext context, AsyncSnapshot<List<Consultation>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Data for Appointment Today'));
        } else {
          List<Consultation> consultations = snapshot.data!;
          return ListView.builder(
            itemCount: consultations.length,
            itemBuilder: (BuildContext context, index) {
              Consultation consult = consultations[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.blueAccent),
                ),
                child: SizedBox(
                  height: 123,
                  child: Flexible(
                    child: Container(
                      // Rest of your code for the second Column
                      padding: EdgeInsets.only(left: 12, right: 12, top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(5.0, 5.0),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${consult.specialistName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 3,),
                                Text(
                                  'Date: ${DateFormat('dd/MM/yyyy').format(consult.consultationDateTime)}',
                                ),
                                SizedBox(height: 3,),
                                Text(
                                  'Time: ${DateFormat('hh:mm a').format(consult.consultationDateTime)}',
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 23,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color(_getStatusColor(consult.consultationStatus)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${consult.consultationStatus}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 200,// Adjust the width as needed
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Spacer(),
                                  if (consult.consultationStatus == 'Accepted')
                                    //
                                    // Container(
                                    //   width: 100,  // Set your desired width
                                    //   height: 50,  // Set your desired height
                                    //   child: FlipClockPlus.countdown(
                                    //     duration: const Duration(hours: 1),
                                    //     digitColor: Colors.white,
                                    //     backgroundColor: Colors.black,
                                    //     digitSize: 5.0,
                                    //     borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                    //     onDone: () {
                                    //       print('OnDone');
                                    //     },
                                    //   ),
                                    // ),

                                    Expanded(
                                      child: Column(
                                        children: [
                                          buildCountdownWidget(),



                                          IconButton(
                                            icon: Icon(Icons.add_ic_call_sharp, size: 30, color: Color(hexColor("228B22"))),
                                            onPressed: () async {
                                              // Check and request camera and microphone permissions
                                              var statusCamera = await Permission.camera.request();
                                              var statusMicrophone = await Permission.microphone.request();

                                              if (statusCamera.isGranted && statusMicrophone.isGranted) {
                                                String? callID = await getCallID(consultationID);

                                                if (callID != null) {
                                                  // Handle the case where the channel name is not null
                                                  print('callID: $callID');
                                                  print("tess$consultationID");
                                                  print(patientName);

                                                  // Navigate to the MyCall widget
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => MyCall(
                                                        callID: callID,
                                                        id: patientID.toString(),
                                                        name: patientName,
                                                        roleId: 0,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Permissions are not granted
                                                // Show a message to inform the user using a Dialog
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Permission Required'),
                                                      content: Text('Camera and microphone permissions are required to make a call.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop(false);
                                                          },
                                                          child: Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                          Text('Ready to Call'),

                                        ],


                                      ),
                                    ),

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }



  Future<List<Consultation>> _fetchTodayConsultationsPatientSide(int patientID) async {
    try {
      final List<Consultation> fetchedConsultations =
      await Consultation(
        specialistID: specialistID,
        consultationDateTime: consultationDateTime,
        specialistName: specialistName,
        consultationStatus: consultationStatus,
        consultationSymptom: consultationSymptom,
        consultationTreatment: consultationTreatment,
        patientID: patientID,
      ).fetchTodayConsultationsPatientSide(patientID);

      return fetchedConsultations;
    } catch (e) {
      print('Error fetching today\'s consultations: $e');
      return []; // Return an empty list in case of an error
    }
  }


  Future<void> _loadData() async {
    setState(() {
      phone = widget.phone;
      patientName = widget.patientName;
      patientID = widget.patientID;
    });
    print("apptpt$patientID");


    List<Consultation> consultations = await _fetchTodayConsultationsPatientSide(patientID);

    print('Fetched Consultations: $consultations');


  }


  Future<String?> getCallID(int consultationID) async {
    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}/teleclinic/dynamicCallID.php?consultationID=$consultationID'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response and return the channel name
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['dynamicCallID'];
    } else {
      // Handle error (e.g., server error, network error)
      throw Exception('Failed to get channel from backend');
    }
  }

  Future<void> getUserLocation() async {
    await Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.denied) {
        print('Location permission denied');
      }
    }).onError((error, stackTrace) {
      print('error $error');
    });

    userLocation = await Geolocator.getCurrentPosition();
  }

  Future<String?> getFCMToken(int patientID) async {
    final FirebaseMessaging _firebaseMessaging =  FirebaseMessaging.instance;

    String? fcmToken = await _firebaseMessaging.getToken();   //get token from firebase

    print('FCM Token: $fcmToken');
    try {

      final response = await http.post(
        Uri.parse('http://${MyApp.ipAddress}/teleclinic/getFCMToken.php'),
        body: {
          'patientID': patientID.toString(),
          'fcmToken': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        print('Status updated successfully');
        setState(() {});
      } else {
        print('Failed to update status. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }


  int _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green.value;
      case 'Decline':
        return Colors.red.value;
      case 'Pending':
      // Use your hexColor function here for the desired color
        return hexColor('FFC000');
      case 'CustomColor': // Add a case for a custom color
        return hexColor('1A2B3C'); // Replace with your custom hexadecimal color
      default:
        return Colors.transparent.value; // Default color
    }
  }

  Widget buildCountdownWidget() {
    return Consumer<CountdownProvider>(
      builder: (context, countdownProvider, _) => Countdown(
        seconds: countdownProvider.seconds,
        build: (BuildContext context, double time) => Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
          ),
          child: Center(
            child: Text(
              '${(time / 60).floor()}:${(time % 60).floor()}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
        interval: Duration(seconds: 1),
        onFinished: () {
          print('Countdown finished!');
        },
      ),
    );
  }
}


  int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}
