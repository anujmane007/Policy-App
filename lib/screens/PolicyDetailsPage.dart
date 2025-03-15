import 'dart:convert'; // To decode Base64
import 'dart:typed_data'; // For ByteData and image manipulation
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:privacy_app/screens/payment_method.dart';

// ignore: must_be_immutable
class PolicyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> policyData;
  final String documentId;

  PolicyDetailsPage(
      {Key? key, required this.policyData, required this.documentId})
      : super(key: key);

  // Function to fetch payment methods from Firestore
  Stream<QuerySnapshot> _getPaymentMethods() {
    return FirebaseFirestore.instance
        .collection('Payments')
        .doc(documentId)
        .collection('Methods')
        .orderBy('tDate', descending: false)
        .snapshots(); // Real-time stream of payment methods
  }

  // Map of old field names to new field names
  Map<String, String> fieldNameMapping = {
    'address': 'Address',
    'ageOfCommencement': 'Age Of Commencement',
    'clientId': 'Client Id',
    'dob': 'DOB',
    'fdAmount': 'FD Amount',
    'fdBankName': 'FD Bank Name',
    'fdEndDate': 'FD End Date',
    'fdMaturityAmount': 'FD Maturity Amount',
    'fdNo': 'FD No',
    'fdStartDate': 'FD Start Date',
    'fdUsername': 'FD Holder Name',
    'finalPremiumDueDate': 'Final Premium Date',
    'interestRate': 'FD Interest Rate',
    'issueDate': 'Policy Issue Date',
    'name': 'Policy Holder Name',
    'notes': 'Notes',
    'policyHolder': 'Policy Holder',
    'policyName': 'Policy Name',
    'policyNo': 'Policy No',
    'policyTerm': 'Policy Term',
    'policyType': 'Policy Type',
    'premiumAmountPerFrequency': 'Premium Frequency',
    'premiumDueDate': 'Premium Due Date',
    'premiumPayingTerm': 'Premium Paying Term',
    'sumAssured': 'Sum Assured'
  };

  @override
  Widget build(BuildContext context) {
    // Fetch the base64 image string
    String? base64Image =
        policyData['image']; // Assuming 'image' is the field in Firestore

    // Decode the Base64 string to a Uint8List
    Uint8List? decodedImage;
    if (base64Image != null && base64Image.isNotEmpty) {
      decodedImage = base64Decode(base64Image); // Decode Base64 image string
    }

    // Filter and create rows for the DataTable, only including non-null/empty values
    List<DataRow> policyRows = policyData.entries
        .where((entry) =>
            entry.value != null &&
            entry.value.toString().isNotEmpty &&
            entry.key != 'image' &&
            entry.key != 'isJointFD')
        .map((entry) {
      String displayName = fieldNameMapping[entry.key] ?? entry.key;
      String valueDisplay;

      if (entry.value is Timestamp) {
        DateTime dateTime = (entry.value as Timestamp).toDate();
        valueDisplay = DateFormat('MMMM d, yyyy').format(dateTime);
      } else {
        valueDisplay = entry.value.toString();
      }

      return DataRow(cells: [
        DataCell(Text(displayName)),
        DataCell(Text(valueDisplay)),
      ]);
    }).toList();

    if (policyData['fdBankName'] != null &&
        policyData['fdBankName'].toString().isNotEmpty) {
      String displayName = fieldNameMapping['isJointFD'] ?? 'isJointFD';
      String valueDisplay = policyData['isJointFD']?.toString() ?? 'N/A';

      policyRows.add(DataRow(cells: [
        DataCell(Text(displayName)),
        DataCell(Text(valueDisplay)),
      ]));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display the image above the table if available
              if (decodedImage != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImagePage(image: decodedImage!),
                      ),
                    );
                  },
                  child: Image.memory(
                    decodedImage,
                    height: 200, // Adjust size accordingly
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              // Title for Details Table
              const Text(
                'Details Table',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // Make the table scrollable
              if (policyRows.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 1.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Field')),
                        DataColumn(label: Text('Value')),
                      ],
                      rows: policyRows,
                    ),
                  ),
                )
              else
                const Center(child: Text('No data available.')),
              const SizedBox(height: 20),
              // Title for Payment Details Table
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // Display Payments table
              StreamBuilder<QuerySnapshot>(
                stream: _getPaymentMethods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No payment methods added yet.'),
                          SizedBox(
                              height:
                                  16), // Add some spacing between text and button
                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => PaymentMethod(
                          //           documentId: documentId,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   child: const Text('Add Payment Method'),
                          // ),
                        ],
                      ),
                    );
                  }

                  final paymentMethods = snapshot.data!.docs;

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

                        DateTime tDate =
                            (paymentData['tDate'] as Timestamp).toDate();
                        String formattedTDate =
                            DateFormat('dd/MM/yyyy').format(tDate);

                        // Determine transaction date based on payment method
                        String transactionDate;
                        if (paymentData['paymentMethod'] == 'Card') {
                          transactionDate = formattedTDate;
                        } else if (paymentData['paymentMethod'] == 'Check') {
                          transactionDate = formattedTDate;
                        } else if (paymentData['paymentMethod'] == 'UPI') {
                          transactionDate = formattedTDate;
                        } else if (paymentData['paymentMethod'] == 'Cash') {
                          transactionDate = formattedTDate;
                        } else {
                          transactionDate =
                              formattedTDate; // Default to tDate if no other date exists
                        }

                        String penaltyChargesStr = '0';
                        if (paymentMethod == 'Card') {
                          penaltyChargesStr = paymentData['Penalty'] ?? '0';
                        } else if (paymentMethod == 'Check') {
                          penaltyChargesStr =
                              paymentData['PenaltyCheck'] ?? '0';
                        } else if (paymentMethod == 'UPI') {
                          penaltyChargesStr = paymentData['PanaltyUpi'] ?? '0';
                        } else if (paymentMethod == 'Cash') {
                          penaltyChargesStr =
                              paymentData['cashPanaltyCash'] ?? '0';
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
                        } else if (paymentMethod == 'UPI') {
                          payeeName = paymentData['sender'] ?? 'N/A';
                        } else if (paymentMethod == 'Cash') {
                          payeeName = paymentData['cashsender'] ?? 'N/A';
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
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final Uint8List image;

  const FullScreenImagePage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen Image'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allow panning
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1, // Minimum scale for zoom
          maxScale: 2.0, // Maximum scale for zoom
          child: Image.memory(image), // Display the image in full screen
        ),
      ),
    );
  }
}
