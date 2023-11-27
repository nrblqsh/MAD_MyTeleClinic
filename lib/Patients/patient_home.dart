import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/settings.dart';

class PatientHomePage extends StatefulWidget {
  final String phone;
  final String patientName;

  PatientHomePage({required this.phone, required this.patientName});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late String phone; // To store the retrieved phone number
  late String patientName;

  @override
  void initState() {
    super.initState();
    _loadData(); // Call the method to load data when the widget is initialized
  }

  Future<void> _loadData() async {

    setState(() {
      phone = widget.phone;
      patientName = widget.patientName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${patientName ?? 'Loading...'}"), // Use null-aware operator to handle potential null value
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome $patientName"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                SettingsScreen()));

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Username"),
                      content: Text("Your username is: $patientName"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Check Username"),
            ),
          ],
        ),
      ),
    );
  }
}
