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
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Text('Policy ID: ${widget.documentId}',
          //       style: const TextStyle(fontSize: 16)),
          // ),
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

                return ListView.builder(
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    // Extracting data from Firestore
                    Map<String, dynamic> paymentData =
                        paymentMethods[index].data() as Map<String, dynamic>;

                    // Build a card for each payment method
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method: ${paymentData['paymentMethod'] ?? 'Unknown'}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            // Display data based on the payment method
                            if (paymentData['paymentMethod'] == 'Card') ...[
                              Text(
                                  'Card Number: ${paymentData['cardNumber'] ?? ''}'),
                              Text('Sender: ${paymentData['sender'] ?? ''}'),
                              Text(
                                  'Date Of Transaction: ${paymentData['transactionDate'] ?? ''}'),
                              Text(
                                  'Payment Amount: ${paymentData['TransactionAmount'] ?? ''}'),
                            ] else if (paymentData['paymentMethod'] ==
                                'Check') ...[
                              Text(
                                  'Account Number: ${paymentData['accountNumber'] ?? ''}'),
                              Text(
                                  'Check Number: ${paymentData['checkNumber'] ?? ''}'),
                              Text(
                                  'Check Date: ${paymentData['checkDate'] ?? ''}'),
                              Text(
                                  'Payee Name: ${paymentData['payeeName'] ?? ''}'),
                              Text(
                                  'Payee Name: ${paymentData['paymentAmountNumber'] ?? ''}'),
                            ] else if (paymentData['paymentMethod'] ==
                                'UPI') ...[
                              Text('UPI ID: ${paymentData['upiId'] ?? ''}'),
                              Text('Sender: ${paymentData['sender'] ?? ''}'),
                              Text(
                                  'Transaction Amount: ${paymentData['TransactionAmount'] ?? ''}'),
                            ],
                          ],
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
