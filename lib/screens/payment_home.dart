import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:privacy_app/screens/login.dart';
import 'package:privacy_app/screens/payment_method.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class AddPayment extends StatefulWidget {
  final String documentId; // Policy document ID

  const AddPayment({Key? key, required this.documentId}) : super(key: key);

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  late Future<void> _initializePayments;

  @override
  void initState() {
    super.initState();
    _initializePayments = _generateYearlyPayments();
  }

  // Function to fetch yearly payments based on policy document
  Future<void> _generateYearlyPayments() async {
    try {
      DocumentSnapshot policyDoc = await FirebaseFirestore.instance
          .collection('policy')
          .doc(widget.documentId)
          .get();

      if (!policyDoc.exists) {
        print('Policy document not found');
        return;
      }

      Map<String, dynamic>? policyData =
          policyDoc.data() as Map<String, dynamic>?;

      if (policyData == null ||
          !policyData.containsKey('issueDate') ||
          !policyData.containsKey('maturaityDate')) {
        print('Issue or maturity date missing');
        return;
      }

      DateTime issueDate = (policyData['issueDate'] as Timestamp).toDate();
      DateTime maturityDate =
          (policyData['maturaityDate'] as Timestamp).toDate();

      List<DateTime> yearlyDates = [];
      DateTime currentDate = issueDate;
      while (currentDate.isBefore(maturityDate)) {
        yearlyDates.add(currentDate);
        currentDate =
            DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
      }

      CollectionReference paymentsRef = FirebaseFirestore.instance
          .collection('Payments')
          .doc(widget.documentId)
          .collection('Methods');

      for (DateTime date in yearlyDates) {
        QuerySnapshot existingRecords = await paymentsRef
            .where('tDate', isEqualTo: Timestamp.fromDate(date))
            .get();

        if (existingRecords.docs.isEmpty) {
          await paymentsRef.add({
            'tDate': Timestamp.fromDate(date), // Store as Timestamp
          });
        }
      }
    } catch (e) {
      print('Error generating yearly payments: $e');
    }
  }

  // Stream to listen to payment methods in the Firestore collection
  Stream<QuerySnapshot> _getPaymentMethods() {
    return FirebaseFirestore.instance
        .collection('Payments')
        .doc(widget.documentId)
        .collection('Methods')
        .orderBy('tDate')
        .snapshots();
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String message, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Execute the delete function
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePaymentMethod(
      BuildContext context, String documentId) async {
    _showConfirmationDialog(
      context,
      "Are you sure you want to clear payment data?",
      () async {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('Payments')
            .doc(widget.documentId)
            .collection('Methods')
            .doc(documentId);

        DocumentSnapshot snapshot = await docRef.get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          Map<String, dynamic> updatedData = {};
          if (data.containsKey('tDate')) {
            updatedData['tDate'] = data['tDate'];
          }

          await docRef.set(updatedData);
        }
      },
    );
  }

  Future<void> _deletePaymentMethodAll(
      BuildContext context, String documentId) async {
    _showConfirmationDialog(
      context,
      "Are you sure you want to delete this payment method permanently?",
      () async {
        await FirebaseFirestore.instance
            .collection('Payments')
            .doc(widget.documentId)
            .collection('Methods')
            .doc(documentId)
            .delete();
      },
    );
  }

  // Function to show a dialog with payment details
  void _showPaymentDetailsDialog(Map<String, dynamic> paymentData) {
    String paymentMethod = paymentData['paymentMethod'] ?? 'Unknown';
    String paymentAmountStr =
        (paymentData['TransactionAmount']?.toString().isNotEmpty == true
                ? paymentData['TransactionAmount'].toString()
                : paymentData['cashTransactionAmount']?.toString()) ??
            paymentData['paymentAmountNumber']?.toString() ??
            '0';

    double paymentAmount = double.tryParse(paymentAmountStr) ?? 0;

    String transactionid = _getTransactionId(paymentData, paymentMethod);
    String transactionDate = _getTransactionDate(paymentData, paymentMethod);

    String penaltyChargesStr = '0';
    if (paymentMethod == 'Card') {
      penaltyChargesStr = paymentData['Penalty'] ?? '0';
    } else if (paymentMethod == 'Check') {
      penaltyChargesStr = paymentData['PenaltyCheck'] ?? '0';
    } else if (paymentMethod == 'UPI') {
      penaltyChargesStr = paymentData['PanaltyUpi'] ?? '0';
    } else if (paymentMethod == 'Cash') {
      penaltyChargesStr = paymentData['cashPanaltyCash'] ?? '0';
    }
    double penaltyCharges = double.tryParse(penaltyChargesStr) ?? 0;

    double totalPayment = paymentAmount + penaltyCharges;

    String payeeName = _getPayeeName(paymentData, paymentMethod);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaction Date: $transactionDate'),
                Text('Payment Method: $paymentMethod'),
                Text('Card/Check/UPI Number: $transactionid'),
                Text('Payment Amount: $paymentAmount'),
                Text('Penalty Charges: $penaltyCharges'),
                Text('Total Payment: $totalPayment'),
                Text('Payee Name: $payeeName'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to get the transaction ID based on payment method
  String _getTransactionId(
      Map<String, dynamic> paymentData, String paymentMethod) {
    if (paymentMethod == 'Card') {
      return paymentData['cardNumber'] ?? 'N/A';
    } else if (paymentMethod == 'Check') {
      return paymentData['checkNumber'] ?? 'N/A';
    } else if (paymentMethod == 'UPI') {
      return paymentData['upiId'] ?? 'N/A';
    } else if (paymentMethod == 'Cash') {
      return 'N/A';
    } else {
      return 'N/A';
    }
  }

  // Helper method to get the transaction date based on payment method
  String _getTransactionDate(
      Map<String, dynamic> paymentData, String paymentMethod) {
    if (paymentMethod == 'Card') {
      return paymentData['transactionDate'] ?? 'N/A';
    } else if (paymentMethod == 'Check') {
      return paymentData['checkDate'] ?? 'N/A';
    } else if (paymentMethod == 'UPI') {
      return paymentData['transactionDate'] ?? 'N/A';
    } else if (paymentMethod == 'Cash') {
      return paymentData['cashtransactionDate'] ?? 'N/A';
    } else {
      return 'N/A';
    }
  }

  // Helper method to get the payee name based on payment method
  String _getPayeeName(Map<String, dynamic> paymentData, String paymentMethod) {
    if (paymentMethod == 'Card' || paymentMethod == 'UPI') {
      return paymentData['sender'] ?? 'N/A';
    } else if (paymentMethod == 'Check') {
      return paymentData['payeeName'] ?? 'N/A';
    } else if (paymentMethod == 'Cash') {
      return paymentData['cashsender'] ?? 'N/A';
    } else {
      return 'N/A';
    }
  }

  // Helper method to get the penalty charges based on payment method
  String _getPenalty(Map<String, dynamic> paymentData, String paymentMethod) {
    if (paymentMethod == 'Card') {
      return paymentData['Penalty'] ?? '0';
    } else if (paymentMethod == 'Check') {
      return paymentData['PenaltyCheck'] ?? '0';
    } else if (paymentMethod == 'UPI') {
      return paymentData['PanaltyUpi'] ?? '0';
    } else if (paymentMethod == 'Cash') {
      return paymentData['cashPanaltyCash'] ?? '0';
    } else {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: _initializePayments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot>(
            stream: _getPaymentMethods(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No payment records found.'));
              }

              final paymentMethods = snapshot.data!.docs;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Sr. No')),
                          DataColumn(label: Text('Transaction Date')),
                          DataColumn(label: Text('Actions')),
                          DataColumn(label: Text('Payment Method')),
                          DataColumn(label: Text('Card/Check/UPI Number')),
                          DataColumn(label: Text('Payment Amount')),
                          DataColumn(label: Text('Penalty Charges')),
                          DataColumn(label: Text('Total Payment')),
                          DataColumn(label: Text('Payee Name')),
                        ],
                        rows: paymentMethods.asMap().entries.map((entry) {
                          int index = entry.key;
                          var paymentData =
                              entry.value.data() as Map<String, dynamic>;

                          DateTime tDate =
                              (paymentData['tDate'] as Timestamp).toDate();
                          String paymentMethod =
                              paymentData['paymentMethod'] ?? 'Unknown';
                          String paymentAmountStr = (paymentData[
                                              'TransactionAmount']
                                          ?.toString()
                                          .isNotEmpty ==
                                      true
                                  ? paymentData['TransactionAmount'].toString()
                                  : paymentData['cashTransactionAmount']
                                      ?.toString()) ??
                              paymentData['paymentAmountNumber']?.toString() ??
                              '0';

                          double paymentAmount =
                              double.tryParse(paymentAmountStr) ?? 0;
                          double penaltyCharges = double.tryParse(
                                  _getPenalty(paymentData, paymentMethod)) ??
                              0;
                          double totalPayment = paymentAmount + penaltyCharges;

                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())), // Sr. No
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(
                                  tDate))), // Transaction Date in DD/MM/YYYY format
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentMethod(
                                              documentId: widget.documentId,
                                              paymentMethodId: entry.value.id,
                                              paymentData: paymentData,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear_all),
                                      onPressed: () {
                                        _deletePaymentMethod(
                                            context, entry.value.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deletePaymentMethodAll(
                                            context, entry.value.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () =>
                                          _showPaymentDetailsDialog(
                                              paymentData),
                                    ),
                                  ],
                                ),
                              ), // Actions column
                              DataCell(Text(paymentMethod)), // Payment Method
                              DataCell(Text(_getTransactionId(paymentData,
                                  paymentMethod))), // Card/Check/UPI Number
                              DataCell(Text(
                                  paymentAmount.toString())), // Payment Amount
                              DataCell(Text(penaltyCharges
                                  .toString())), // Penalty Charges
                              DataCell(Text(
                                  totalPayment.toString())), // Total Payment
                              DataCell(Text(_getPayeeName(
                                  paymentData, paymentMethod))), // Payee Name
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   icon: const Icon(Icons.add),
      //   label: const Text('Add Payment'),
      //   backgroundColor: Colors.teal,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) =>
      //             PaymentMethod(documentId: widget.documentId),
      //       ),
      //     );
      //   },
      // ),
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
