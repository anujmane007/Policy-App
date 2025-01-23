import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:privacy_app/screens/login.dart';
import 'package:privacy_app/screens/payment_method.dart';

class AddPayment extends StatefulWidget {
  final String documentId; // Pass documentId from previous screen

  const AddPayment({super.key, required this.documentId});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  // Function to fetch payment methods from Firestore
  Stream<QuerySnapshot> _getPaymentMethods() {
    return FirebaseFirestore.instance
        .collection('Payments')
        .doc(widget.documentId)
        .collection('Methods')
        .snapshots(); // Real-time stream of payment methods
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transactions',
            style: TextStyle(color: Colors.white)),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPaymentMethods(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No payment methods added yet.'));
                }

                final paymentMethods = snapshot.data!.docs;

                // Build DataTable for displaying transaction history
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Sr. No')),
                      DataColumn(label: Text('Transaction Date')),
                      DataColumn(label: Text('Payment Method')),
                      DataColumn(label: Text('Card/Check/UPI Number')),
                      DataColumn(label: Text('Payment Amount')),
                      DataColumn(label: Text('Panalty Charges')),
                      DataColumn(label: Text('Total Payment')),
                      DataColumn(label: Text('Payee Name')),
                    ],
                    rows: paymentMethods.asMap().entries.map((entry) {
                      int index = entry.key;
                      var paymentData =
                          entry.value.data() as Map<String, dynamic>;

                      String paymentMethod =
                          paymentData['paymentMethod'] ?? 'Unknown';
                      String paymentAmountStr =
                          (paymentData['TransactionAmount']
                                          ?.toString()
                                          .isNotEmpty ==
                                      true
                                  ? paymentData['TransactionAmount'].toString()
                                  : paymentData['paymentAmountNumber']
                                      ?.toString()) ??
                              '0';
                      double paymentAmount =
                          double.tryParse(paymentAmountStr) ?? 0;

                      // Payment ID No
                      String transactionid;
                      if (paymentMethod == 'Card') {
                        transactionid = paymentData['cardNumber'] ?? 'N/A';
                      } else if (paymentMethod == 'Check') {
                        transactionid = paymentData['checkNumber'] ?? 'N/A';
                      } else if (paymentMethod == 'UPI') {
                        transactionid = paymentData['upiId'] ?? 'N/A';
                      } else {
                        transactionid = 'N/A';
                      }

                      // Determine transaction date based on payment method
                      String transactionDate;
                      if (paymentMethod == 'Card') {
                        transactionDate =
                            paymentData['transactionDate'] ?? 'N/A';
                      } else if (paymentMethod == 'Check') {
                        transactionDate = paymentData['checkDate'] ?? 'N/A';
                      } else if (paymentMethod == 'UPI') {
                        transactionDate =
                            paymentData['transactionDate'] ?? 'N/A';
                      } else {
                        transactionDate = 'N/A';
                      }

                      String penaltyChargesStr = '0';
                      if (paymentMethod == 'Card') {
                        penaltyChargesStr = paymentData['Penalty'] ?? '0';
                      } else if (paymentMethod == 'Check') {
                        penaltyChargesStr = paymentData['PenaltyCheck'] ?? '0';
                      } else if (paymentMethod == 'UPI') {
                        penaltyChargesStr = paymentData['PanaltyUpi'] ?? '0';
                      }
                      double penaltyCharges =
                          double.tryParse(penaltyChargesStr) ?? 0;

                      // Calculate Total Payment
                      double totalPayment = paymentAmount + penaltyCharges;

                      // Determine correct payee name field based on payment method
                      String payeeName;
                      if (paymentMethod == 'Card' || paymentMethod == 'UPI') {
                        payeeName = paymentData['sender'] ?? 'N/A';
                      } else if (paymentMethod == 'Check') {
                        payeeName = paymentData['payeeName'] ?? 'N/A';
                      } else {
                        payeeName = 'N/A';
                      }

                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())), // Sr. No
                        DataCell(Text(transactionDate)),
                        DataCell(Text(paymentMethod)),
                        DataCell(Text(transactionid)),
                        DataCell(Text(paymentAmount.toString())),
                        DataCell(Text(penaltyCharges.toString())),
                        DataCell(
                            Text(totalPayment.toString())), // Total Payment
                        DataCell(Text(payeeName)),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PaymentMethod(documentId: widget.documentId),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
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
