import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:privacy_app/screens/PolicyDetailsPage.dart';
import 'package:privacy_app/screens/PrivacyScreen.dart';
import 'package:privacy_app/screens/login.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzData;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userEmail});
  final String userEmail;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilterField = 'policyType'; // Default field to filter on
  String? _selectedFilterValue; // Value selected for filtering
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  int _preferredDaysBeforeNotification = 15;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones();
    requestNotificationPermissions();
    scheduleNotifications();
    createNotificationChannel();
    _loadPreferredDays();
    listenToPolicyUpdates();
  }

  void listenToPolicyUpdates() {
    FirebaseFirestore.instance
        .collection('policy')
        .where('policyHolder', isEqualTo: widget.userEmail)
        .snapshots()
        .listen((snapshot) async {
      final prefs = await SharedPreferences.getInstance();
      final int preferredDays =
          prefs.getInt('preferredDaysBeforeNotification') ?? 15;

      final today = DateTime.now();

      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added ||
            docChange.type == DocumentChangeType.modified) {
          final data = docChange.doc.data();
          final Timestamp? premiumDueDateTimestamp =
              data?['premiumDueDate'] as Timestamp?;

          if (premiumDueDateTimestamp != null) {
            final DateTime premiumDueDate = premiumDueDateTimestamp.toDate();
            final int difference = premiumDueDate.difference(today).inDays;

            // Ensure notifications are sent only once per day for the same content
            String notificationKey =
                '${docChange.doc.id}_${today.toIso8601String().split('T')[0]}';
            bool alreadyNotified = prefs.getBool(notificationKey) ?? false;

            if (difference >= 0 &&
                !alreadyNotified &&
                difference <= preferredDays) {
              // Create a unique notification ID using the document ID and day
              int notificationId =
                  docChange.doc.hashCode + today.day + today.month;

              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: notificationId,
                  channelKey: 'basic_channel',
                  title: 'Premium Due Reminder',
                  body:
                      'Your policy "${data?['policyName'] ?? 'Unnamed Policy'}" has a premium due on ${DateFormat('MMMM d, yyyy').format(premiumDueDate)} remaining days are $difference.',
                  notificationLayout: NotificationLayout.BigText,
                ),
              );

              // Mark notification as sent for today
              await prefs.setBool(notificationKey, true);
            }
          }
        }
      }
    });
  }

  Future<void> _loadPreferredDays() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preferredDaysBeforeNotification =
          prefs.getInt('preferredDaysBeforeNotification') ?? 15;
    });
  }

  Future<void> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> _savePreferredDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preferredDaysBeforeNotification', days);
    setState(() {
      _preferredDaysBeforeNotification = days;
    });
  }

  Future<void> createNotificationChannel() async {
    await AwesomeNotifications().initialize(
      null, // Default icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Colors.teal,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        )
      ],
    );
  }

  void _showDaysPreferenceDialog() {
    final controller = TextEditingController(
        text: _preferredDaysBeforeNotification.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Notification Days'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Days before due date',
              hintText: 'Enter number of days',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final days = int.tryParse(controller.text);
                if (days != null && days > 0) {
                  _savePreferredDays(days);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> scheduleNotifications() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('policy')
  //       .where('policyHolder', isEqualTo: widget.userEmail)
  //       .get();

  //   final prefs = await SharedPreferences.getInstance();
  //   final int preferredDays =
  //       prefs.getInt('preferredDaysBeforeNotification') ?? 15;

  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //     final Timestamp? premiumDueDateTimestamp =
  //         data['premiumDueDate'] as Timestamp?;
  //     if (premiumDueDateTimestamp != null) {
  //       final DateTime premiumDueDate = premiumDueDateTimestamp.toDate();
  //       final DateTime today = DateTime.now();
  //       final int difference = premiumDueDate.difference(today).inDays + 1;

  //       print(difference);
  //       print(preferredDays);
  //       if (difference <= preferredDays) {
  //         // Schedule notification at 10:25 AM
  //         final DateTime notificationTime = DateTime(
  //           today.year,
  //           today.month,
  //           today.day,
  //           11, // 10 AM
  //           57, // 25 minutes past the hour
  //         );

  //         if (notificationTime.isAfter(today)) {
  //           await AwesomeNotifications().createNotification(
  //             content: NotificationContent(
  //               id: doc.hashCode, // Unique ID for the notification
  //               channelKey: 'basic_channel',
  //               title: 'Premium Due Reminder',
  //               body:
  //                   'Your policy "${data['policyName'] ?? 'Unnamed Policy'}" has a premium due on ${DateFormat('MMMM d, yyyy').format(premiumDueDate)}.',
  //               notificationLayout: NotificationLayout.BigText,
  //             ),
  //             schedule: NotificationCalendar(
  //               year: notificationTime.year,
  //               month: notificationTime.month,
  //               day: notificationTime.day,
  //               hour: notificationTime.hour,
  //               minute: notificationTime.minute,
  //               second: 0,
  //               millisecond: 0,
  //               timeZone:
  //                   await AwesomeNotifications().getLocalTimeZoneIdentifier(),
  //               repeats: false,
  //             ),
  //           );
  //         }
  //       }
  //     }
  //   }
  // }

  // Future<void> scheduleNotifications() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('policy')
  //       .where('policyHolder', isEqualTo: widget.userEmail)
  //       .get();

  //   final prefs = await SharedPreferences.getInstance();
  //   final int preferredDays =
  //       prefs.getInt('preferredDaysBeforeNotification') ?? 15;

  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //     final Timestamp? premiumDueDateTimestamp =
  //         data['premiumDueDate'] as Timestamp?;
  //     if (premiumDueDateTimestamp != null) {
  //       final DateTime premiumDueDate = premiumDueDateTimestamp.toDate();
  //       final DateTime today = DateTime.now();
  //       final int difference = premiumDueDate.difference(today).inDays;

  //       print(difference);
  //       print(preferredDays);

  //       if (difference <= preferredDays) {
  //         print('Working');
  //         // Notify immediately
  //         await AwesomeNotifications().createNotification(
  //           content: NotificationContent(
  //             id: doc.hashCode, // Unique ID for the notification
  //             channelKey: 'basic_channel',
  //             title: 'Premium Due Reminder',
  //             body:
  //                 'Your policy "${data['policyName'] ?? 'Unnamed Policy'}" has a premium due on ${DateFormat('MMMM d, yyyy').format(premiumDueDate)}.',
  //             notificationLayout: NotificationLayout.BigText,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

//Working 1

  Future<void> scheduleNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('policy')
        .where('policyHolder', isEqualTo: widget.userEmail)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? premiumDueDateTimestamp =
          data['premiumDueDate'] as Timestamp?;
      if (premiumDueDateTimestamp != null) {
        final DateTime premiumDueDate = premiumDueDateTimestamp.toDate();
        final DateTime today = DateTime.now();
        final int difference = premiumDueDate.difference(today).inDays + 1;

        print(difference);
        if (difference == 15) {
          // Schedule notification at 10:25 AM
          final DateTime notificationTime = DateTime(
            today.year,
            today.month,
            today.day,
            10, // 10 AM
            33, // 25 minutes past the hour
          );

          if (notificationTime.isAfter(today)) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: doc.hashCode, // Unique ID for the notification
                channelKey: 'basic_channel',
                title: 'Premium Due Reminder',
                body:
                    'Your policy "${data['policyName'] ?? 'Unnamed Policy'}" has a premium due on ${DateFormat('MMMM d, yyyy').format(premiumDueDate)}.',
                notificationLayout: NotificationLayout.BigText, // Expanded text
              ),
              schedule: NotificationCalendar(
                year: notificationTime.year,
                month: notificationTime.month,
                day: notificationTime.day,
                hour: notificationTime.hour,
                minute: notificationTime.minute,
                second: 0,
                millisecond: 0,
                timeZone:
                    await AwesomeNotifications().getLocalTimeZoneIdentifier(),
                repeats: false,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('My Policies', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showSignOutConfirmationDialog(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: _showDaysPreferenceDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Dropdown to select filter field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Filter by:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedFilterField,
                    items: [
                      'policyName',
                      'name',
                      'policyType',
                      'companyName',
                      'fdBankName',
                      'fdUsername',
                    ].map((field) {
                      return DropdownMenuItem<String>(
                        value: field,
                        child: Text(field),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilterField = value!;
                        _selectedFilterValue = null; // Reset selected value
                      });
                    },
                  ),
                ],
              ),
            ),

            // List of unique values for the selected filter field
            FutureBuilder<List<String>>(
              future: _fetchUniqueValues(_selectedFilterField),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final uniqueValues = snapshot.data ?? [];
                if (uniqueValues.isEmpty) {
                  return const Center(child: Text('No data available.'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: uniqueValues.map((value) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterValue = value;
                          });
                        },
                        child: Chip(
                          label: Text(value),
                          backgroundColor: _selectedFilterValue == value
                              ? Colors.teal
                              : Colors.grey.shade300,
                          labelStyle: TextStyle(
                            color: _selectedFilterValue == value
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // Display the filtered list of cards
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

                  // Filter documents based on the selected filter value
                  final filteredDocuments = documents.where((doc) {
                    final policyData = doc.data() as Map<String, dynamic>;
                    if (_selectedFilterValue == null) return true; // No filter
                    return (policyData[_selectedFilterField] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(_selectedFilterValue!.toLowerCase());
                  }).toList();

                  if (filteredDocuments.isEmpty) {
                    return const Center(
                        child: Text('No matching policies found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final policy = filteredDocuments[index].data()
                          as Map<String, dynamic>;
                      final documentId = filteredDocuments[index].id;

                      final policyType = policy['policyType'] ?? 'No Type';

                      // If the policyType is 'FD', render FD-specific card
                      if (policyType.toLowerCase() == 'fd') {
                        final fdNameOfBank = policy['fdBankName'] ?? 'N/A';
                        final fdUsername = policy['fdUsername'] ?? 'N/A';
                        final fdAccountNumber = policy['fdNo'] ?? 'N/A';
                        final fdInterestRate = policy['interestRate'] ?? 'N/A';

                        // FD Start Date
                        final fdStartDateTimestamp =
                            policy['fdStartDate'] as Timestamp?;
                        final DateTime fdStartDate =
                            fdStartDateTimestamp?.toDate() ?? DateTime.now();
                        final String formattedFdStartDate =
                            DateFormat('MMMM d, yyyy').format(fdStartDate);

                        // FD End Date
                        final fdEndDateTimestamp =
                            policy['fdEndDate'] as Timestamp?;
                        final DateTime fdEndDate =
                            fdEndDateTimestamp?.toDate() ?? DateTime.now();
                        final String formattedFdEndDate =
                            DateFormat('MMMM d, yyyy').format(fdEndDate);

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PolicyDetailsPage(
                                  policyData: policy,
                                  documentId: documentId,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                '$policyType - $fdNameOfBank',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text('FD Holder Name: $fdUsername'),
                                  Text('Account Number: $fdAccountNumber'),
                                  Text('Interest Rate: $fdInterestRate%'),
                                  Text('FD Start Date: $formattedFdStartDate'),
                                  Text('FD End Date: $formattedFdEndDate'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PrivacyScreen(
                                            userEmail: widget.userEmail,
                                            uid: documentId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.view_list, size: 16),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PolicyDetailsPage(
                                            policyData: policy,
                                            documentId: documentId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // General policy card
                      final companyName = policy['companyName'] ?? 'No Company';
                      final policyName = policy['policyName'] ?? 'No Name';
                      final name = policy['name'] ?? 'No Holder';
                      final policyNo =
                          policy['policyNo'] ?? 'Unknown Policy No';

                      final Timestamp? premiumDueDateTimestamp =
                          policy['premiumDueDate'] as Timestamp?;
                      final DateTime premiumDueDate =
                          premiumDueDateTimestamp?.toDate() ?? DateTime.now();
                      final String formattedpremiumDueDate =
                          DateFormat('MMMM d, yyyy').format(premiumDueDate);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PolicyDetailsPage(
                                policyData: policy,
                                documentId: documentId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              '$policyType - $companyName $policyName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text('Policy Holder: $name'),
                                Text('Policy No: $policyNo'),
                                Text('Premium Date: $formattedpremiumDueDate'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivacyScreen(
                                          userEmail: widget.userEmail,
                                          uid: documentId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.view_list, size: 16),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PolicyDetailsPage(
                                          policyData: policy,
                                          documentId: documentId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Floating Action Button to add policy
        floatingActionButton: FloatingActionButton.extended(
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
          icon: const Icon(Icons.add),
          label: const Text('Add Policy'),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }

  // Fetch unique values from Firestore based on the selected filter field
  Future<List<String>> _fetchUniqueValues(String field) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('policy')
        .where('policyHolder', isEqualTo: widget.userEmail)
        .get();

    final uniqueValues = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      uniqueValues.add(data[field]?.toString() ?? '');
    }

    return uniqueValues.toList();
  }

  // Sign out confirmation dialog
  void _showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
