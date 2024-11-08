// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
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
//   final TextEditingController _expiryDateController = TextEditingController();
//   final TextEditingController _cvvController = TextEditingController();
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

//   // Function to save payment details to Firestore with custom document ID
//   Future<void> _savePaymentDetails() async {
//     Map<String, dynamic> paymentData = {};

//     if (_selectedPaymentMethod == 'Card') {
//       paymentData['cardNumber'] = _cardNumberController.text;
//       paymentData['expiryDate'] = _expiryDateController.text;
//       // paymentData['cvv'] = _cvvController.text;
//     } else if (_selectedPaymentMethod == 'Check') {
//       paymentData['checkNumber'] = _checkNumberController.text;
//       paymentData['checkDate'] = _checkDateController.text;
//       paymentData['payeeName'] = _payeeNameController.text;
//       paymentData['paymentAmountNumber'] = _paymentAmountNumberController.text;
//       paymentData['paymentAmountWords'] = _paymentAmountWordsController.text;
//       paymentData['routingNumber'] = _routingNumberController.text;
//       paymentData['accountNumber'] = _accountNumberController.text;
//     } else if (_selectedPaymentMethod == 'UPI') {
//       paymentData['upiId'] = _upiIdController.text;
//     }

//     paymentData['paymentMethod'] = _selectedPaymentMethod;

//     // Create a unique custom ID for each payment method
//     String customDocId =
//         const Uuid().v4(); // Using uuid to generate a unique ID

//     // Save the payment data to Firestore under the documentId with custom doc ID
//     await FirebaseFirestore.instance
//         .collection('Payments')
//         .doc(widget.documentId) // Document ID for the main payment document
//         .collection('Methods') // Sub-collection for payment methods
//         .doc(customDocId) // Custom document ID for this specific method
//         .set(paymentData); // Save payment data under the custom document ID
//   }

//   // Function to display form fields based on payment method
//   Widget _buildPaymentFields() {
//     switch (_selectedPaymentMethod) {
//       case 'Card':
//         return Column(
//           children: [
//             TextFormField(
//               controller: _cardNumberController,
//               decoration: const InputDecoration(labelText: 'Card Number'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter card number';
//                 } else if (value.length != 16) {
//                   return 'Card number must be exactly 16 digits';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _expiryDateController,
//               decoration:
//                   const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
//               keyboardType: TextInputType.datetime,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter expiry date';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _cvvController,
//               decoration: const InputDecoration(labelText: 'CVV'),
//               keyboardType: TextInputType.number,
//               obscureText: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter CVV';
//                 } else if (value.length != 3) {
//                   return 'CVV must be exactly 3 digits';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         );
//       case 'Check':
//         return Column(
//           children: [
//             TextFormField(
//               controller: _checkDateController,
//               decoration: const InputDecoration(labelText: 'Date (DD/MM/YYYY)'),
//               keyboardType: TextInputType.datetime,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the date';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _checkNumberController,
//               decoration: const InputDecoration(labelText: 'Check Number'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter check number';
//                 }
//                 if (value.length != 6) {
//                   return 'Check number must be exactly 6 digits';
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
//               decoration:
//                   const InputDecoration(labelText: 'Payment Amount (Numbers)'),
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
//               controller: _paymentAmountWordsController,
//               decoration:
//                   const InputDecoration(labelText: 'Payment Amount (Words)'),
//               keyboardType: TextInputType.text,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter payment amount in words';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _routingNumberController,
//               decoration: const InputDecoration(labelText: 'Routing Number'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter routing number';
//                 }
//                 if (value.length != 6) {
//                   return 'Routing number must be exactly 6 digits';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _accountNumberController,
//               decoration: const InputDecoration(labelText: 'Account Number'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter account number';
//                 }
//                 if (!RegExp(r'^\d{8,17}$').hasMatch(value)) {
//                   return 'Account number must be between 8 and 17 digits';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         );
//       case 'UPI':
//         return TextFormField(
//           controller: _upiIdController,
//           decoration: const InputDecoration(labelText: 'UPI ID'),
//           keyboardType: TextInputType.text,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter UPI ID';
//             }
//             if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(value)) {
//               return 'Please enter a valid UPI ID';
//             }
//             return null;
//           },
//         );
//       default:
//         return Container();
//     }
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
//                   items: ['Card', 'Check', 'UPI'].map((String method) {
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
import 'package:uuid/uuid.dart'; // For generating unique custom IDs

class PaymentMethod extends StatefulWidget {
  final String documentId; // Accept documentId in the constructor
  const PaymentMethod({super.key, required this.documentId});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'Card';

  // Controllers for the fields
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _checkDateController = TextEditingController();
  final TextEditingController _payeeNameController = TextEditingController();
  final TextEditingController _paymentAmountNumberController =
      TextEditingController();
  final TextEditingController _paymentAmountWordsController =
      TextEditingController();
  final TextEditingController _routingNumberController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _transactionDateController =
      TextEditingController();
  final TextEditingController _upiTransactionDateController =
      TextEditingController();

  // Added missing controllers for 'Other'
  final TextEditingController _otherCardController = TextEditingController();
  final TextEditingController _otherCheckController = TextEditingController();
  final TextEditingController _otherUpiController = TextEditingController();
  final TextEditingController _transactionamountCardController =
      TextEditingController();
  final TextEditingController _transactionamountCheckController =
      TextEditingController();
  final TextEditingController _transactionamountUpiController =
      TextEditingController();
  // Function to save payment details to Firestore with custom document ID
  Future<void> _savePaymentDetails() async {
    Map<String, dynamic> paymentData = {};

    if (_selectedPaymentMethod == 'Card') {
      paymentData['cardNumber'] = _cardNumberController.text;
      paymentData['transactionDate'] = _transactionDateController.text;
      // paymentData['cvv'] = _cvvController.text; // Uncomment if needed
      paymentData['sender'] =
          _senderController.text; // Added sender field for Card
      paymentData['other'] =
          _otherCardController.text; // Added other field for Card
      paymentData['TransactionAmount'] = _transactionamountCardController.text;
    } else if (_selectedPaymentMethod == 'Check') {
      paymentData['checkNumber'] = _checkNumberController.text;
      paymentData['checkDate'] = _checkDateController.text;
      paymentData['payeeName'] = _payeeNameController.text;
      paymentData['paymentAmountNumber'] = _paymentAmountNumberController.text;
      paymentData['paymentAmountWords'] = _paymentAmountWordsController.text;
      paymentData['routingNumber'] = _routingNumberController.text;
      paymentData['accountNumber'] = _accountNumberController.text;
      paymentData['other'] =
          _otherCheckController.text; // Added other field for Check
      paymentData['TransactionAmount'] = _transactionamountCheckController.text;
    } else if (_selectedPaymentMethod == 'UPI') {
      paymentData['upiId'] = _upiIdController.text;
      paymentData['transactionDate'] = _upiTransactionDateController.text;
      paymentData['sender'] =
          _senderController.text; // Added sender field for UPI
      paymentData['other'] =
          _otherUpiController.text; // Added other field for UPI
      paymentData['TransactionAmount'] =
          _transactionamountUpiController.text; // Added other field for UPI
    }

    paymentData['paymentMethod'] = _selectedPaymentMethod;

    // Create a unique custom ID for each payment method
    String customDocId =
        const Uuid().v4(); // Using uuid to generate a unique ID

    // Save the payment data to Firestore under the documentId with custom doc ID
    await FirebaseFirestore.instance
        .collection('Payments')
        .doc(widget.documentId)
        .collection('Methods')
        .doc(customDocId)
        .set(paymentData);
  }

  // Function to display form fields based on payment method
  Widget _buildPaymentFields() {
    switch (_selectedPaymentMethod) {
      case 'Card':
        return Column(
          children: [
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                } else if (value.length != 16) {
                  return 'Card number must be exactly 16 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _transactionDateController,
              decoration: const InputDecoration(
                  labelText: 'Transaction Date (DD/MM/YY)'),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter transaction date';
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
            //   controller: _paymentAmountNumberController,
            //   decoration:
            //       const InputDecoration(labelText: 'Payment Amount (Numbers)'),
            //   keyboardType: TextInputType.number,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter payment amount';
            //     }
            //     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            //       return 'Payment amount must be a number';
            //     }
            //     return null;
            //   },
            // ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _transactionamountCardController,
              decoration:
                  const InputDecoration(labelText: 'Transaction amount'),
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
              decoration: const InputDecoration(labelText: 'Account Number'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account number';
                }
                if (!RegExp(r'^\d{8,17}$').hasMatch(value)) {
                  return 'Account number must be between 8 and 17 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _checkDateController,
              decoration: const InputDecoration(
                  labelText: 'Transaction Date (DD/MM/YYYY)'),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the date';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _checkNumberController,
              decoration: const InputDecoration(labelText: 'Check Number'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter check number';
                }
                if (value.length != 6) {
                  return 'Check number must be exactly 6 digits';
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
              decoration:
                  const InputDecoration(labelText: 'Payment Amount (Numbers)'),
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
              controller: _otherCheckController,
              decoration: const InputDecoration(labelText: 'Other'),
              keyboardType: TextInputType.text,
            ),
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
                if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(value)) {
                  return 'Please enter a valid UPI ID';
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
            const SizedBox(height: 20),
            TextFormField(
              controller: _upiTransactionDateController,
              decoration: const InputDecoration(
                  labelText: 'Transaction Date (DD/MM/YYYY)'),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter transaction date';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
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
              controller: _otherUpiController,
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
    // Clean up the controllers
    _cardNumberController.dispose();
    _checkNumberController.dispose();
    _checkDateController.dispose();
    _payeeNameController.dispose();
    _paymentAmountNumberController.dispose();
    _paymentAmountWordsController.dispose();
    _routingNumberController.dispose();
    _accountNumberController.dispose();
    _upiIdController.dispose();
    _senderController.dispose();
    _transactionDateController.dispose();
    _upiTransactionDateController.dispose();
    _otherCardController.dispose();
    _otherCheckController.dispose();
    _otherUpiController.dispose();
    _transactionamountCardController.dispose();
    _transactionamountCheckController.dispose();
    _transactionamountUpiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
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
                  items: ['Card', 'Check', 'UPI'].map((String method) {
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
                      // Save the payment details to Firestore
                      await _savePaymentDetails();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Payment Details Submitted')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
