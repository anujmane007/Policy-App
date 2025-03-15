// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:privacy_app/screens/payment_home.dart';
// import 'package:uuid/uuid.dart'; // For generating unique custom IDs

// class PaymentMethod extends StatefulWidget {
//   final String documentId; // Accept documentId in the constructor
//   const PaymentMethod({super.key, required this.documentId});

//   @override
//   State<PaymentMethod> createState() => _PaymentMethodState();
// }

// class _PaymentMethodState extends State<PaymentMethod> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String _selectedPaymentMethod = 'Card';

//   // Controllers for the fields
//   final TextEditingController _cardNumberController = TextEditingController();
//   final TextEditingController _checkNumberController = TextEditingController();
//   final TextEditingController _checkDateController = TextEditingController();
//   final TextEditingController _payeeNameController = TextEditingController();
//   final TextEditingController _paymentAmountNumberController =
//       TextEditingController();
//   final TextEditingController _paymentAmountWordsController =
//       TextEditingController();
//   final TextEditingController _routingNumberController =
//       TextEditingController();
//   final TextEditingController _accountNumberController =
//       TextEditingController();
//   final TextEditingController _upiIdController = TextEditingController();
//   final TextEditingController _senderController = TextEditingController();
//   final TextEditingController _transactionDateController =
//       TextEditingController();
//   final TextEditingController _upiTransactionDateController =
//       TextEditingController();

//   // Added missing controllers for 'Other'
//   final TextEditingController _otherCardController = TextEditingController();
//   final TextEditingController _panaltyCheckController = TextEditingController();
//   final TextEditingController _otherCheckController = TextEditingController();
//   final TextEditingController _panaltyUpiController = TextEditingController();
//   final TextEditingController _otherUpiController = TextEditingController();
//   final TextEditingController _transactionamountCardController =
//       TextEditingController();
//   final TextEditingController _penaltyCardController = TextEditingController();
//   final TextEditingController _transactionamountCheckController =
//       TextEditingController();
//   final TextEditingController _transactionamountUpiController =
//       TextEditingController();
//   final TextEditingController _cashsenderController = TextEditingController();
//   final TextEditingController _cashTransactionDateController =
//       TextEditingController();
//   final TextEditingController _cashtransactionamountCashController =
//       TextEditingController();
//   final TextEditingController _panaltyCashController = TextEditingController();
//   final TextEditingController _otherCashController = TextEditingController();
//   // Function to save payment details to Firestore with custom document ID
//   Future<void> _savePaymentDetails() async {
//     Map<String, dynamic> paymentData = {};

//     if (_selectedPaymentMethod == 'Card') {
//       paymentData['cardNumber'] = _cardNumberController.text;
//       paymentData['transactionDate'] = _transactionDateController.text;
//       // paymentData['cvv'] = _cvvController.text; // Uncomment if needed
//       paymentData['sender'] =
//           _senderController.text; // Added sender field for Card
//       paymentData['other'] =
//           _otherCardController.text; // Added other field for Card
//       paymentData['TransactionAmount'] = _transactionamountCardController.text;
//       paymentData['Penalty'] = _penaltyCardController.text;
//     } else if (_selectedPaymentMethod == 'Check') {
//       paymentData['checkNumber'] = _checkNumberController.text;
//       paymentData['checkDate'] = _checkDateController.text;
//       paymentData['payeeName'] = _payeeNameController.text;
//       paymentData['paymentAmountNumber'] = _paymentAmountNumberController.text;
//       paymentData['paymentAmountWords'] = _paymentAmountWordsController.text;
//       paymentData['routingNumber'] = _routingNumberController.text;
//       paymentData['accountNumber'] = _accountNumberController.text;
//       paymentData['PenaltyCheck'] = _panaltyCheckController.text;
//       paymentData['other'] =
//           _otherCheckController.text; // Added other field for Check
//       paymentData['TransactionAmount'] = _transactionamountCheckController.text;
//     } else if (_selectedPaymentMethod == 'UPI') {
//       paymentData['upiId'] = _upiIdController.text;
//       paymentData['transactionDate'] = _upiTransactionDateController.text;
//       paymentData['sender'] =
//           _senderController.text; // Added sender field for UPI
//       paymentData['PanaltyUpi'] = _panaltyUpiController.text;
//       paymentData['other'] =
//           _otherUpiController.text; // Added other field for UPI
//       paymentData['TransactionAmount'] =
//           _transactionamountUpiController.text; // Added other field for UPI
//     } else if (_selectedPaymentMethod == 'Cash') {
//       paymentData['cashsender'] = _cashsenderController.text;
//       paymentData['cashtransactionDate'] = _cashTransactionDateController.text;
//       paymentData['cashTransactionAmount'] =
//           _cashtransactionamountCashController.text;
//       paymentData['cashPanaltyCash'] = _panaltyCashController.text;
//       paymentData['other'] = _otherCashController.text;
//     }

//     paymentData['paymentMethod'] = _selectedPaymentMethod;

//     // Create a unique custom ID for each payment method
//     String customDocId =
//         const Uuid().v4(); // Using uuid to generate a unique ID

//     // Save the payment data to Firestore under the documentId with custom doc ID
//     await FirebaseFirestore.instance
//         .collection('Payments')
//         .doc(widget.documentId)
//         .collection('Methods')
//         .doc(customDocId)
//         .set(paymentData);
//   }

//   // Function to display form fields based on payment method
//   Widget _buildPaymentFields() {
//     switch (_selectedPaymentMethod) {
//       case 'Card':
//         return Column(
//           children: [
//             TextFormField(
//               controller: _cardNumberController,
//               decoration: const InputDecoration(
//                   labelText: 'Card Number (Enter Last 4 Digits Only)'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter card number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _transactionDateController,
//               decoration: const InputDecoration(
//                 labelText: 'Transaction Date (DD/MM/YY)',
//                 suffixIcon: Icon(Icons.calendar_today),
//               ),
//               readOnly: true,
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _transactionDateController.text =
//                         "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _senderController,
//               decoration:
//                   const InputDecoration(labelText: 'To whom you have to send'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             TextFormField(
//               controller: _transactionamountCardController,
//               decoration:
//                   const InputDecoration(labelText: 'Transaction amount'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _penaltyCardController,
//               decoration: const InputDecoration(labelText: 'Penalty Charges'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//           ],
//         );
//       case 'Check':
//         return Column(
//           children: [
//             TextFormField(
//               controller: _accountNumberController,
//               decoration: const InputDecoration(
//                   labelText: 'Account Number  (Enter Last 4 Digits Only)'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter account number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _checkDateController,
//               decoration: const InputDecoration(
//                 labelText: 'Check Date (DD/MM/YYYY)',
//                 suffixIcon: Icon(Icons.calendar_today),
//               ),
//               readOnly: true,
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _checkDateController.text =
//                         "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _checkNumberController,
//               decoration: const InputDecoration(
//                   labelText: 'Check Number (Enter Last 4 Digits Only)'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter check number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _payeeNameController,
//               decoration: const InputDecoration(labelText: 'Payee Name'),
//               keyboardType: TextInputType.text,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter payee name';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _paymentAmountNumberController,
//               decoration: const InputDecoration(labelText: 'Payment Amount'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter payment amount';
//                 }
//                 if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                   return 'Payment amount must be a number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             TextFormField(
//               controller: _panaltyCheckController,
//               decoration: const InputDecoration(labelText: 'Panalty Charges'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _otherCheckController,
//               decoration: const InputDecoration(labelText: 'Other'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//           ],
//         );
//       case 'UPI':
//         return Column(
//           children: [
//             TextFormField(
//               controller: _upiIdController,
//               decoration: const InputDecoration(labelText: 'UPI ID'),
//               keyboardType: TextInputType.text,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter UPI ID';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _senderController,
//               decoration:
//                   const InputDecoration(labelText: 'To whom you have to send'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _upiTransactionDateController,
//               decoration: const InputDecoration(
//                 labelText: 'Transaction Date (DD/MM/YYYY)',
//                 suffixIcon: Icon(Icons.calendar_today),
//               ),
//               readOnly: true,
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _upiTransactionDateController.text =
//                         "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//                   });
//                 }
//               },
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             TextFormField(
//               controller: _transactionamountUpiController,
//               decoration:
//                   const InputDecoration(labelText: 'Transaction Amount'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter payment amount';
//                 }
//                 if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                   return 'Payment amount must be a number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _panaltyUpiController,
//               decoration: const InputDecoration(labelText: 'Panalty Charges'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _otherUpiController,
//               decoration: const InputDecoration(labelText: 'Other'),
//               keyboardType: TextInputType.text,
//             ),
//           ],
//         );

//       //CASH Option
//       case 'Cash':
//         return Column(
//           children: [
//             TextFormField(
//               controller: _cashsenderController,
//               decoration:
//                   const InputDecoration(labelText: 'To whom you have to send'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _cashTransactionDateController,
//               decoration: const InputDecoration(
//                 labelText: 'Transaction Date (DD/MM/YYYY)',
//                 suffixIcon: Icon(Icons.calendar_today),
//               ),
//               readOnly: true,
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _cashTransactionDateController.text =
//                         "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//                   });
//                 }
//               },
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             TextFormField(
//               controller: _cashtransactionamountCashController,
//               decoration:
//                   const InputDecoration(labelText: 'Transaction Amount'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter payment amount';
//                 }
//                 if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                   return 'Payment amount must be a number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _panaltyCashController,
//               decoration: const InputDecoration(labelText: 'Panalty Charges'),
//               keyboardType: TextInputType.text,
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _otherCashController,
//               decoration: const InputDecoration(labelText: 'Other'),
//               keyboardType: TextInputType.text,
//             ),
//           ],
//         );
//       default:
//         return Container();
//     }
//   }

//   @override
//   void dispose() {
//     // Clean up the controllers
//     _cardNumberController.dispose();
//     _checkNumberController.dispose();
//     _checkDateController.dispose();
//     _payeeNameController.dispose();
//     _paymentAmountNumberController.dispose();
//     _paymentAmountWordsController.dispose();
//     _routingNumberController.dispose();
//     _accountNumberController.dispose();
//     _upiIdController.dispose();
//     _senderController.dispose();
//     _transactionDateController.dispose();
//     _upiTransactionDateController.dispose();
//     _otherCardController.dispose();
//     _otherCheckController.dispose();

//     _otherUpiController.dispose();
//     _transactionamountCardController.dispose();
//     _penaltyCardController.dispose();
//     _panaltyUpiController.dispose();
//     _panaltyCheckController.dispose();

//     _transactionamountCheckController.dispose();
//     _transactionamountUpiController.dispose();
//     _cashsenderController.dispose();
//     _cashTransactionDateController.dispose();
//     _cashtransactionamountCashController.dispose();
//     _panaltyCashController.dispose();
//     _otherCashController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Payment Method'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 16.0),
//                 DropdownButtonFormField<String>(
//                   decoration:
//                       const InputDecoration(labelText: 'Payment Method'),
//                   value: _selectedPaymentMethod,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedPaymentMethod = newValue!;
//                     });
//                   },
//                   items: ['Card', 'Check', 'UPI', 'Cash'].map((String method) {
//                     return DropdownMenuItem(
//                       value: method,
//                       child: Text(method),
//                     );
//                   }).toList(),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a payment method';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16.0),
//                 _buildPaymentFields(),
//                 const SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       // Save the payment details to Firestore
//                       await _savePaymentDetails();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('Payment Details Submitted')),
//                       );
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AddPayment(
//                                   documentId: widget.documentId,
//                                 )),
//                       );
//                     }
//                   },
//                   child: const Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:privacy_app/screens/payment_home.dart';
import 'package:uuid/uuid.dart'; // For generating unique custom IDs

class PaymentMethod extends StatefulWidget {
  final String documentId; // Parent document ID
  final String?
      paymentMethodId; // Optional: existing payment method document ID for editing
  final Map<String, dynamic>? paymentData; // Optional: existing payment data

  const PaymentMethod({
    super.key,
    required this.documentId,
    this.paymentMethodId,
    this.paymentData,
  });

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'Card';

  // Controllers for Card fields
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _transactionDateController =
      TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _otherCardController = TextEditingController();
  final TextEditingController _transactionamountCardController =
      TextEditingController();
  final TextEditingController _penaltyCardController = TextEditingController();

  // Controllers for Check fields
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _checkDateController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _payeeNameController = TextEditingController();
  final TextEditingController _paymentAmountNumberController =
      TextEditingController();
  final TextEditingController _paymentAmountWordsController =
      TextEditingController();
  final TextEditingController _routingNumberController =
      TextEditingController();
  final TextEditingController _transactionamountCheckController =
      TextEditingController();
  final TextEditingController _panaltyCheckController = TextEditingController();
  final TextEditingController _otherCheckController = TextEditingController();

  // Controllers for UPI fields
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _upiTransactionDateController =
      TextEditingController();
  final TextEditingController _transactionamountUpiController =
      TextEditingController();
  final TextEditingController _panaltyUpiController = TextEditingController();
  final TextEditingController _otherUpiController = TextEditingController();

  // Controllers for Cash fields
  final TextEditingController _cashsenderController = TextEditingController();
  final TextEditingController _cashTransactionDateController =
      TextEditingController();
  final TextEditingController _cashtransactionamountCashController =
      TextEditingController();
  final TextEditingController _panaltyCashController = TextEditingController();
  final TextEditingController _otherCashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If paymentData is provided, we are in editing mode.
    if (widget.paymentData != null) {
      _selectedPaymentMethod =
          widget.paymentData!['paymentMethod'] ?? _selectedPaymentMethod;
      if (_selectedPaymentMethod == 'Card') {
        _cardNumberController.text = widget.paymentData!['cardNumber'] ?? '';
        _transactionDateController.text =
            widget.paymentData!['transactionDate'] ?? '';
        _senderController.text = widget.paymentData!['sender'] ?? '';
        _otherCardController.text = widget.paymentData!['other'] ?? '';
        _transactionamountCardController.text =
            widget.paymentData!['TransactionAmount'] ?? '';
        _penaltyCardController.text = widget.paymentData!['Penalty'] ?? '';
      } else if (_selectedPaymentMethod == 'Check') {
        _accountNumberController.text =
            widget.paymentData!['accountNumber'] ?? '';
        _checkDateController.text = widget.paymentData!['checkDate'] ?? '';
        _checkNumberController.text = widget.paymentData!['checkNumber'] ?? '';
        _payeeNameController.text = widget.paymentData!['payeeName'] ?? '';
        _paymentAmountNumberController.text =
            widget.paymentData!['paymentAmountNumber'] ?? '';
        _paymentAmountWordsController.text =
            widget.paymentData!['paymentAmountWords'] ?? '';
        _routingNumberController.text =
            widget.paymentData!['routingNumber'] ?? '';
        _transactionamountCheckController.text =
            widget.paymentData!['TransactionAmount'] ?? '';
        _panaltyCheckController.text =
            widget.paymentData!['PenaltyCheck'] ?? '';
        _otherCheckController.text = widget.paymentData!['other'] ?? '';
      } else if (_selectedPaymentMethod == 'UPI') {
        _upiIdController.text = widget.paymentData!['upiId'] ?? '';
        _upiTransactionDateController.text =
            widget.paymentData!['transactionDate'] ?? '';
        _senderController.text = widget.paymentData!['sender'] ?? '';
        _transactionamountUpiController.text =
            widget.paymentData!['TransactionAmount'] ?? '';
        _panaltyUpiController.text = widget.paymentData!['PanaltyUpi'] ?? '';
        _otherUpiController.text = widget.paymentData!['other'] ?? '';
      } else if (_selectedPaymentMethod == 'Cash') {
        _cashsenderController.text = widget.paymentData!['cashsender'] ?? '';
        _cashTransactionDateController.text =
            widget.paymentData!['cashtransactionDate'] ?? '';
        _cashtransactionamountCashController.text =
            widget.paymentData!['cashTransactionAmount'] ?? '';
        _panaltyCashController.text =
            widget.paymentData!['cashPanaltyCash'] ?? '';
        _otherCashController.text = widget.paymentData!['other'] ?? '';
      }
    }
  }

  // Save new or update existing payment details in Firestore.
  Future<void> _saveOrUpdatePaymentDetails() async {
    Map<String, dynamic> paymentData = {};

    if (_selectedPaymentMethod == 'Card') {
      paymentData['cardNumber'] = _cardNumberController.text;
      paymentData['transactionDate'] = _transactionDateController.text;
      paymentData['sender'] = _senderController.text;
      paymentData['other'] = _otherCardController.text;
      paymentData['TransactionAmount'] = _transactionamountCardController.text;
      paymentData['Penalty'] = _penaltyCardController.text;
    } else if (_selectedPaymentMethod == 'Check') {
      paymentData['accountNumber'] = _accountNumberController.text;
      paymentData['checkDate'] = _checkDateController.text;
      paymentData['checkNumber'] = _checkNumberController.text;
      paymentData['payeeName'] = _payeeNameController.text;
      paymentData['paymentAmountNumber'] = _paymentAmountNumberController.text;
      paymentData['paymentAmountWords'] = _paymentAmountWordsController.text;
      paymentData['routingNumber'] = _routingNumberController.text;
      paymentData['TransactionAmount'] = _transactionamountCheckController.text;
      paymentData['PenaltyCheck'] = _panaltyCheckController.text;
      paymentData['other'] = _otherCheckController.text;
    } else if (_selectedPaymentMethod == 'UPI') {
      paymentData['upiId'] = _upiIdController.text;
      paymentData['transactionDate'] = _upiTransactionDateController.text;
      paymentData['sender'] = _senderController.text;
      paymentData['TransactionAmount'] = _transactionamountUpiController.text;
      paymentData['PanaltyUpi'] = _panaltyUpiController.text;
      paymentData['other'] = _otherUpiController.text;
    } else if (_selectedPaymentMethod == 'Cash') {
      paymentData['cashsender'] = _cashsenderController.text;
      paymentData['cashtransactionDate'] = _cashTransactionDateController.text;
      paymentData['cashTransactionAmount'] =
          _cashtransactionamountCashController.text;
      paymentData['cashPanaltyCash'] = _panaltyCashController.text;
      paymentData['other'] = _otherCashController.text;
    }

    paymentData['paymentMethod'] = _selectedPaymentMethod;

    if (widget.paymentMethodId != null) {
      // Update existing document.
      await FirebaseFirestore.instance
          .collection('Payments')
          .doc(widget.documentId)
          .collection('Methods')
          .doc(widget.paymentMethodId)
          .update(paymentData);
    } else {
      // Create a new document.
      String customDocId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('Payments')
          .doc(widget.documentId)
          .collection('Methods')
          .doc(customDocId)
          .set(paymentData);
    }
  }

  // Build the fields based on selected payment method.
  Widget _buildPaymentFields() {
    switch (_selectedPaymentMethod) {
      case 'Card':
        return Column(
          children: [
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                  labelText: 'Card Number (Enter Last 4 Digits Only)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                return null;
              },
            ),
            // const SizedBox(height: 20),
            // TextFormField(
            //   controller: _transactionDateController,
            //   decoration: const InputDecoration(
            //     labelText: 'Transaction Date (DD/MM/YY)',
            //     suffixIcon: Icon(Icons.calendar_today),
            //   ),
            //   readOnly: true,
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(2000),
            //       lastDate: DateTime(2101),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _transactionDateController.text =
            //             "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            //       });
            //     }
            //   },
            // ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _senderController,
              decoration:
                  const InputDecoration(labelText: 'To whom you have to send'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _transactionamountCardController,
              decoration:
                  const InputDecoration(labelText: 'Transaction amount'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _penaltyCardController,
              decoration: const InputDecoration(labelText: 'Penalty Charges'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
          ],
        );
      case 'Check':
        return Column(
          children: [
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                  labelText: 'Account Number (Enter Last 4 Digits Only)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account number';
                }
                return null;
              },
            ),
            // const SizedBox(height: 20),
            // TextFormField(
            //   controller: _checkDateController,
            //   decoration: const InputDecoration(
            //     labelText: 'Check Date (DD/MM/YYYY)',
            //     suffixIcon: Icon(Icons.calendar_today),
            //   ),
            //   readOnly: true,
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(2000),
            //       lastDate: DateTime(2101),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _checkDateController.text =
            //             "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            //       });
            //     }
            //   },
            // ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _checkNumberController,
              decoration: const InputDecoration(
                  labelText: 'Check Number (Enter Last 4 Digits Only)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter check number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _payeeNameController,
              decoration: const InputDecoration(labelText: 'Payee Name'),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payee name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _paymentAmountNumberController,
              decoration: const InputDecoration(labelText: 'Payment Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Payment amount must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _panaltyCheckController,
              decoration: const InputDecoration(labelText: 'Panalty Charges'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otherCheckController,
              decoration: const InputDecoration(labelText: 'Other'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
          ],
        );
      case 'UPI':
        return Column(
          children: [
            TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(labelText: 'UPI ID'),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter UPI ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _senderController,
              decoration:
                  const InputDecoration(labelText: 'To whom you have to send'),
              keyboardType: TextInputType.text,
            ),
            // const SizedBox(height: 20),
            // TextFormField(
            //   controller: _upiTransactionDateController,
            //   decoration: const InputDecoration(
            //     labelText: 'Transaction Date (DD/MM/YYYY)',
            //     suffixIcon: Icon(Icons.calendar_today),
            //   ),
            //   readOnly: true,
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(2000),
            //       lastDate: DateTime(2101),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _upiTransactionDateController.text =
            //             "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            //       });
            //     }
            //   },
            // ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _transactionamountUpiController,
              decoration:
                  const InputDecoration(labelText: 'Transaction Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Payment amount must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _panaltyUpiController,
              decoration: const InputDecoration(labelText: 'Panalty Charges'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otherUpiController,
              decoration: const InputDecoration(labelText: 'Other'),
              keyboardType: TextInputType.text,
            ),
          ],
        );
      case 'Cash':
        return Column(
          children: [
            TextFormField(
              controller: _cashsenderController,
              decoration:
                  const InputDecoration(labelText: 'To whom you have to send'),
              keyboardType: TextInputType.text,
            ),
            // const SizedBox(height: 20),
            // TextFormField(
            //   controller: _cashTransactionDateController,
            //   decoration: const InputDecoration(
            //     labelText: 'Transaction Date (DD/MM/YYYY)',
            //     suffixIcon: Icon(Icons.calendar_today),
            //   ),
            //   readOnly: true,
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(2000),
            //       lastDate: DateTime(2101),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _cashTransactionDateController.text =
            //             "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            //       });
            //     }
            //   },
            // ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cashtransactionamountCashController,
              decoration:
                  const InputDecoration(labelText: 'Transaction Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Payment amount must be a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _panaltyCashController,
              decoration: const InputDecoration(labelText: 'Panalty Charges'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otherCashController,
              decoration: const InputDecoration(labelText: 'Other'),
              keyboardType: TextInputType.text,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _transactionDateController.dispose();
    _senderController.dispose();
    _otherCardController.dispose();
    _transactionamountCardController.dispose();
    _penaltyCardController.dispose();
    _accountNumberController.dispose();
    _checkDateController.dispose();
    _checkNumberController.dispose();
    _payeeNameController.dispose();
    _paymentAmountNumberController.dispose();
    _paymentAmountWordsController.dispose();
    _routingNumberController.dispose();
    _transactionamountCheckController.dispose();
    _panaltyCheckController.dispose();
    _otherCheckController.dispose();
    _upiIdController.dispose();
    _upiTransactionDateController.dispose();
    _transactionamountUpiController.dispose();
    _panaltyUpiController.dispose();
    _otherUpiController.dispose();
    _cashsenderController.dispose();
    _cashTransactionDateController.dispose();
    _cashtransactionamountCashController.dispose();
    _panaltyCashController.dispose();
    _otherCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentMethodId != null
            ? 'Edit Payment Method'
            : 'Add Payment Method'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
                  value: _selectedPaymentMethod,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  },
                  items: ['Card', 'Check', 'UPI', 'Cash'].map((String method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildPaymentFields(),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveOrUpdatePaymentDetails();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.paymentMethodId != null
                              ? 'Payment Details Updated'
                              : 'Payment Details Submitted'),
                        ),
                      );
                      // Redirect back to the home/list page.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddPayment(documentId: widget.documentId),
                        ),
                      );
                    }
                  },
                  child: Text(
                      widget.paymentMethodId != null ? 'Update' : 'Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
