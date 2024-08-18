import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:privacy_app/screens/PrivacyScreen.dart';
import 'package:privacy_app/screens/login.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// ignore: library_prefixes
import 'package:timezone/data/latest.dart' as tzData;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userEmail});
  final String userEmail;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    tzData.initializeTimeZones();

    requestNotificationPermissions();

    // Initialize Awesome Notifications
    AwesomeNotifications().initialize(
      'resource://drawable/ic_notification', // Use the correct icon name
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
    );

    // Schedule notifications every 2 minutes
    // schedulePeriodicNotifications();
    fetchPoliciesAndScheduleNotifications();
  }

  Future<void> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  void fetchPoliciesAndScheduleNotifications() async {
    try {
      print('Success Boss');
      final userPolicies = await FirebaseFirestore.instance
          .collection('policy')
          .where('policyHolder', isEqualTo: widget.userEmail)
          .get();

      for (var document in userPolicies.docs) {
        final policy = document.data();
        final String policyName = policy['policyName'] ?? 'No Name';
        final Timestamp dueTimestamp = policy['premiumDate'] as Timestamp;
        final DateTime dueDate = dueTimestamp.toDate(); //4

        // Schedule notification for each policy
        schedulePolicyExpiryNotification(policyName, dueDate, document.id,
            isPM: true);
      }
    } catch (error) {
      print('Failed to fetch policies: $error');
    }
  }

  void schedulePolicyExpiryNotification(
      String policyName, DateTime dueDate, String policyId, //3
      {bool isPM = true}) {
    final DateTime currentDate = DateTime.now();
    final int remainingDays = dueDate.difference(currentDate).inDays + 1;
    print('working boss');
    print(remainingDays);

    if (remainingDays == 15) {
      int hour = isPM ? 16 : 4;
      AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: policyId.hashCode, // Unique notification id
            channelKey: 'basic_channel',
            title: 'Policy Expiry Reminder',
            body: 'Your policy $policyName expires in $remainingDays days.',
            notificationLayout: NotificationLayout.Default,
          ),
          // schedule: NotificationInterval(
          //   interval: 60, // Schedule every 1 minute
          //   timeZone: 'UTC',
          //   repeats: true,
          // ),
          schedule: NotificationCalendar(
            hour: hour,
            minute: 30,
            second: 0,
            repeats: false,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Policies'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            _showSignOutConfirmationDialog(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyScreen(
                    userEmail: widget.userEmail,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('policy')
            .where('policyHolder', isEqualTo: widget.userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(child: Text('No policies available.'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final policy = documents[index].data() as Map<String, dynamic>;
              final documentId = documents[index].id;

              // Ensure values are not null and handle default values
              final policyName = policy['policyName'] ?? 'No Name';
              final policyNo = policy['policyNo'] ?? 'Unknown Policy No';

              // Convert Timestamp to DateTime and then format it
              final Timestamp dueTimestamp =
                  policy['premiumDate'] as Timestamp; //2
              final String policyname = policy['policyName'];
              final DateTime dueDate = dueTimestamp.toDate(); //1
              final String formattedDueDate =
                  DateFormat('yyyy/MM/dd').format(dueDate);

              // Schedule notification for policy expiry
              schedulePolicyExpiryNotification(policyname, dueDate, documentId);

              return ListTile(
                title: Text(policyName),
                subtitle: Text('Policy No: $policyNo'),
                trailing: Container(
                  width: 100, // Adjust the width as needed
                  alignment: Alignment.centerRight,
                  child: Text('Premium Date: $formattedDueDate'),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacyScreen(
                      userEmail: widget.userEmail,
                      uid: documentId,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ); // Navigate to the login page
              },
            ),
          ],
        );
      },
    );
  }
}
