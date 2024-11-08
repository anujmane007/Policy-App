// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:privacy_app/screens/PrivacyScreen.dart';
// import 'package:privacy_app/screens/login.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:timezone/data/latest.dart' as tzData;

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key, required this.userEmail});
//   final String userEmail;

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String _searchQuery = '';
//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     tzData.initializeTimeZones();
//     requestNotificationPermissions();
//     AwesomeNotifications().initialize(
//       'resource://drawable/ic_notification',
//       [
//         NotificationChannel(
//           channelKey: 'basic_channel',
//           channelName: 'Basic Notifications',
//           channelDescription: 'Notification channel for basic tests',
//           defaultColor: const Color(0xFF9D50DD),
//           ledColor: Colors.white,
//           importance: NotificationImportance.High,
//         ),
//       ],
//     );
//     fetchPoliciesAndScheduleNotifications();
//   }

//   Future<void> requestNotificationPermissions() async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) {
//       AwesomeNotifications().requestPermissionToSendNotifications();
//     }
//   }

//   void fetchPoliciesAndScheduleNotifications() async {
//     try {
//       final userPolicies = await FirebaseFirestore.instance
//           .collection('policy')
//           .where('policyHolder', isEqualTo: widget.userEmail)
//           .get();

//       print("Working 1");

//       if (userPolicies.docs.isEmpty) {
//         print('No policies found for the user.');
//         return;
//       }

//       for (var document in userPolicies.docs) {
//         final policy = document.data();
//         final String policyName = policy['policyName'] ?? 'No Name';
//         final Timestamp? premiumDueDateTimestamp =
//             policy['premiumDueDate'] as Timestamp?;
//         print("working 2");

//         if (premiumDueDateTimestamp == null) {
//           print('No premium due date found for policy: $policyName');
//           continue;
//         }

//         final DateTime premiumDueDate = premiumDueDateTimestamp.toDate();
//         schedulePolicyExpiryNotification(
//             policyName, premiumDueDate, document.id);
//       }
//     } catch (error) {
//       print('Failed to fetch policies: $error');
//     }
//   }

//   void schedulePolicyExpiryNotification(
//       String policyName, DateTime premiumDueDate, String policyId) {
//     final DateTime currentDate = DateTime.now();
//     final int remainingDays = premiumDueDate.difference(currentDate).inDays + 1;

//     print(remainingDays);
//     // Schedule a notification 15 days before premium due date
//     if (remainingDays == 15 || remainingDays == 30 || remainingDays == 180) {
//       AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: policyId.hashCode,
//           channelKey: 'basic_channel',
//           title: 'Policy Expiry Reminder',
//           body: 'Your policy $policyName expires in $remainingDays days.',
//           notificationLayout: NotificationLayout.Default,
//         ),
//         schedule: NotificationCalendar(
//           year: DateTime.now().year,
//           month: DateTime.now().month,
//           day: DateTime.now().day,
//           hour: 16, // 4 PM in 24-hour format
//           minute: 0,
//           second: 0,
//           timeZone:
//               'UTC', // You can adjust the time zone to the local one if needed
//           repeats: true,
//         ),
//       );
//       print('Scheduled notification for policy: $policyName');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Policies', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         leading: IconButton(
//           icon: const Icon(Icons.logout, color: Colors.white),
//           onPressed: () {
//             _showSignOutConfirmationDialog(context);
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search Policies',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                 ),
//               ),
//               onChanged: (query) {
//                 setState(() {
//                   _searchQuery = query.toLowerCase();
//                 });
//               },
//             ),
//           ),

//           // List of policies (filtered)
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('policy')
//                   .where('policyHolder', isEqualTo: widget.userEmail)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final documents = snapshot.data?.docs ?? [];

//                 if (documents.isEmpty) {
//                   return const Center(child: Text('No policies available.'));
//                 }

//                 // Filter the documents based on the search query
//                 final filteredDocuments = documents.where((doc) {
//                   final policyData = doc.data() as Map<String, dynamic>;

//                   final policyHolder =
//                       (policyData['name'] ?? '').toString().toLowerCase();
//                   final policyNo =
//                       (policyData['policyNo'] ?? '').toString().toLowerCase();
//                   final policyType =
//                       (policyData['policyType'] ?? '').toString().toLowerCase();

//                   // Apply search filters on policy holder, policy number, and policy type
//                   return policyHolder.contains(_searchQuery) ||
//                       policyNo.contains(_searchQuery) ||
//                       policyType.contains(_searchQuery);
//                 }).toList();

//                 if (filteredDocuments.isEmpty) {
//                   return const Center(
//                       child: Text('No matching policies found.'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: filteredDocuments.length,
//                   itemBuilder: (context, index) {
//                     final policy =
//                         filteredDocuments[index].data() as Map<String, dynamic>;
//                     final documentId = filteredDocuments[index].id;

//                     final policyType = policy['policyType'] ?? 'No Type';
//                     final policyName = policy['policyName'] ?? 'No Name';
//                     final name = policy['name'] ?? 'No Holder';
//                     final policyNo = policy['policyNo'] ?? 'Unknown Policy No';

//                     final Timestamp? issueDateTimestamp =
//                         policy['issueDate'] as Timestamp?;
//                     final Timestamp? premiumDueDateTimestamp =
//                         policy['premiumDueDate'] as Timestamp?;
//                     final Timestamp? finalPremiumDueDateTimestamp =
//                         policy['finalPremiumDueDate'] as Timestamp?;

//                     final DateTime issueDate =
//                         issueDateTimestamp?.toDate() ?? DateTime.now();
//                     final DateTime premiumDueDate =
//                         premiumDueDateTimestamp?.toDate() ?? DateTime.now();
//                     final DateTime finalPremiumDueDate =
//                         finalPremiumDueDateTimestamp?.toDate() ??
//                             DateTime.now();

//                     final String formattedIssueDate =
//                         DateFormat('MMMM d, yyyy').format(issueDate);
//                     final String formattedPremiumDueDate =
//                         DateFormat('MMMM d, yyyy').format(premiumDueDate);
//                     final String formattedFinalPremiumDueDate =
//                         DateFormat('MMMM d, yyyy').format(finalPremiumDueDate);

//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 8),
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.all(16),
//                         title: Text(
//                           '$policyType - $policyName',
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 10),
//                             Text('Policy Holder: $name'),
//                             Text('Policy No: $policyNo'),
//                             Text('Issued Date: $formattedIssueDate'),
//                             Text('Premium Due Date: $formattedPremiumDueDate'),
//                             Text(
//                                 'Final Premium Due Date: $formattedFinalPremiumDueDate'),
//                           ],
//                         ),
//                         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PrivacyScreen(
//                               userEmail: widget.userEmail,
//                               uid: documentId,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: const Icon(Icons.add),
//         label: const Text('Add Policies'),
//         backgroundColor: Colors.teal,
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PrivacyScreen(
//                 userEmail: widget.userEmail,
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   void _showSignOutConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Sign Out'),
//           content: const Text('Are you sure you want to sign out?'),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Sign Out'),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LoginPage()),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:privacy_app/screens/PrivacyScreen.dart';
import 'package:privacy_app/screens/login.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tzData;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userEmail});
  final String userEmail;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones();
    requestNotificationPermissions();
    AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
    );
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
      final userPolicies = await FirebaseFirestore.instance
          .collection('policy')
          .where('policyHolder', isEqualTo: widget.userEmail)
          .get();

      print("Working 1");

      if (userPolicies.docs.isEmpty) {
        print('No policies found for the user.');
        return;
      }

      for (var document in userPolicies.docs) {
        final policy = document.data();
        final String policyName = policy['policyName'] ?? 'No Name';
        final Timestamp? premiumDueDateTimestamp =
            policy['premiumDueDate'] as Timestamp?;
        print("working 2");

        if (premiumDueDateTimestamp == null) {
          print('No premium due date found for policy: $policyName');
          continue;
        }

        final DateTime premiumDueDate = premiumDueDateTimestamp.toDate();
        schedulePolicyExpiryNotification(
            policyName, premiumDueDate, document.id);
      }
    } catch (error) {
      print('Failed to fetch policies: $error');
    }
  }

  void schedulePolicyExpiryNotification(
      String policyName, DateTime premiumDueDate, String policyId) {
    final DateTime currentDate = DateTime.now();
    final int remainingDays = premiumDueDate.difference(currentDate).inDays + 1;

    print(remainingDays);
    // Schedule a notification 15 days before premium due date
    if (remainingDays == 15 || remainingDays == 30 || remainingDays == 180) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: policyId.hashCode,
          channelKey: 'basic_channel',
          title: 'Policy Expiry Reminder',
          body: 'Your policy $policyName expires in $remainingDays days.',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: DateTime.now().year,
          month: DateTime.now().month,
          day: DateTime.now().day,
          hour: 16, // 4 PM in 24-hour format
          minute: 0,
          second: 0,
          timeZone:
              'UTC', // You can adjust the time zone to the local one if needed
          repeats: true,
        ),
      );
      print('Scheduled notification for policy: $policyName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Policies', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            _showSignOutConfirmationDialog(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Policies',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),

          // List of policies (filtered)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                // Filter the documents based on the search query
                final filteredDocuments = documents.where((doc) {
                  final policyData = doc.data() as Map<String, dynamic>;

                  final policyHolder =
                      (policyData['name'] ?? '').toString().toLowerCase();
                  final policyNo =
                      (policyData['policyNo'] ?? '').toString().toLowerCase();
                  final policyType =
                      (policyData['policyType'] ?? '').toString().toLowerCase();

                  // Apply search filters on policy holder, policy number, and policy type
                  return policyHolder.contains(_searchQuery) ||
                      policyNo.contains(_searchQuery) ||
                      policyType.contains(_searchQuery);
                }).toList();

                if (filteredDocuments.isEmpty) {
                  return const Center(
                      child: Text('No matching policies found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final policy =
                        filteredDocuments[index].data() as Map<String, dynamic>;
                    final documentId = filteredDocuments[index].id;

                    final policyType = policy['policyType'] ?? 'No Type';
                    final policyName = policy['policyName'] ?? 'No Name';
                    final name = policy['name'] ?? 'No Holder';
                    final policyNo = policy['policyNo'] ?? 'Unknown Policy No';

                    final Timestamp? issueDateTimestamp =
                        policy['issueDate'] as Timestamp?;
                    final Timestamp? premiumDueDateTimestamp =
                        policy['premiumDueDate'] as Timestamp?;
                    final Timestamp? finalPremiumDueDateTimestamp =
                        policy['finalPremiumDueDate'] as Timestamp?;

                    final DateTime issueDate =
                        issueDateTimestamp?.toDate() ?? DateTime.now();
                    final DateTime premiumDueDate =
                        premiumDueDateTimestamp?.toDate() ?? DateTime.now();
                    final DateTime finalPremiumDueDate =
                        finalPremiumDueDateTimestamp?.toDate() ??
                            DateTime.now();

                    final String formattedIssueDate =
                        DateFormat('MMMM d, yyyy').format(issueDate);
                    final String formattedPremiumDueDate =
                        DateFormat('MMMM d, yyyy').format(premiumDueDate);
                    final String formattedFinalPremiumDueDate =
                        DateFormat('MMMM d, yyyy').format(finalPremiumDueDate);

                    // Show different details for FD policies
                    if (policyType.toLowerCase() == 'fd') {
                      final fdAccountNumber = policy['policyNo'] ?? 'N/A';
                      final fdInterestRate = policy['fdInterestRate'] ?? 'N/A';
                      final fdMaturityDateTimestamp =
                          policy['fdMaturityDate'] as Timestamp?;
                      final DateTime fdMaturityDate =
                          fdMaturityDateTimestamp?.toDate() ?? DateTime.now();
                      final String formattedFdMaturityDate =
                          DateFormat('MMMM d, yyyy').format(fdMaturityDate);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            '$policyType',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text('Account Number: $fdAccountNumber'),
                              Text('Interest Rate: $fdInterestRate%'),
                              Text('Maturity Date: $formattedFdMaturityDate'),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyScreen(
                                userEmail: widget.userEmail,
                                uid: documentId,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // For insurance and other policy types, keep the existing UI
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            '$policyType - $policyName',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text('Policy Holder: $name'),
                              Text('Policy No: $policyNo'),
                              Text('Issued Date: $formattedIssueDate'),
                              Text(
                                  'Premium Due Date: $formattedPremiumDueDate'),
                              Text(
                                  'Final Premium Due Date: $formattedFinalPremiumDueDate'),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyScreen(
                                userEmail: widget.userEmail,
                                uid: documentId,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Policies'),
        backgroundColor: Colors.teal,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
