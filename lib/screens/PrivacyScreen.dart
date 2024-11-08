import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:privacy_app/screens/payment_home.dart'; // Firestore integration

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key, required this.userEmail, this.uid});
  final String userEmail;
  final String? uid;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState(userEmail, uid);
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  _PrivacyScreenState(this.userEmail, this.uid);

  final String? uid;
  final String userEmail;
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('yyyy-MM-dd');

  // Controllers for text fields
  final _policyTypeController = TextEditingController();
  final _policyNameController = TextEditingController();
  final _policyNoController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _premiumDueDateController = TextEditingController();
  final _finalPremiumDueDateController = TextEditingController();
  // final _ageController = TextEditingController();
  final _premiumAmountController = TextEditingController();
  final _sumAssuredController = TextEditingController();
  final _policyTermController = TextEditingController();
  final _premiumPayingTermController = TextEditingController();
  final _fdUserName = TextEditingController(); //Change
  final _fdMaturityDateController = TextEditingController(); // FD field
  final _fdInterestRateController = TextEditingController(); // FD field
  final _fdNoController = TextEditingController(); //Change
  final _bankFdName = TextEditingController(); //Change
  final _fdStartDate = TextEditingController(); //Change
  final _fdEndDate = TextEditingController(); //Change
  final _fdAmount = TextEditingController(); //Change
  final _fdMaturatyAmount = TextEditingController(); //Change
  final _notesController = TextEditingController();

  bool _isEditing = false;
  String? _currentDocumentId;
  bool _showFDFields = false;

  @override
  void initState() {
    super.initState();
    _currentDocumentId = uid;
    if (_currentDocumentId != null) {
      _retrieveData();
    } else {
      _addNewPolicy();
    }
  }

  Future<void> _retrieveData() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('policy')
            .doc(_currentDocumentId)
            .get();

    _populateFields(documentSnapshot);
    _isEditing = false;
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      final dob = _dobController.text.isNotEmpty
          ? dateFormat.parse(_dobController.text)
          : null;
      final issueDate = _issueDateController.text.isNotEmpty
          ? dateFormat.parse(_issueDateController.text)
          : null;
      final premiumDueDate = _premiumDueDateController.text.isNotEmpty
          ? dateFormat.parse(_premiumDueDateController.text)
          : null;
      final finalPremiumDueDate = _finalPremiumDueDateController.text.isNotEmpty
          ? dateFormat.parse(_finalPremiumDueDateController.text)
          : null;
      final fdMaturityDate = _fdMaturityDateController.text.isNotEmpty
          ? dateFormat.parse(_fdMaturityDateController.text)
          : null;

      //FD DATE Controller
      final fdStartDate = _fdStartDate.text.isNotEmpty
          ? dateFormat.parse(_fdStartDate.text)
          : null;

      final fdEndDate =
          _fdEndDate.text.isNotEmpty ? dateFormat.parse(_fdEndDate.text) : null;

      final policyData = {
        'policyHolder': userEmail,
        'policyType': _policyTypeController.text,
        'policyName': _policyNameController.text,
        'policyNo': _policyNoController.text,
        'clientId': _clientIdController.text,
        'name': _nameController.text,
        'address': _addressController.text,
        'dob': dob != null ? Timestamp.fromDate(dob) : null,
        'issueDate': issueDate != null ? Timestamp.fromDate(issueDate) : null,
        'premiumDueDate':
            premiumDueDate != null ? Timestamp.fromDate(premiumDueDate) : null,
        'finalPremiumDueDate': finalPremiumDueDate != null
            ? Timestamp.fromDate(finalPremiumDueDate)
            : null,
        'fdusername': _fdUserName.text, //Change
        'nameofbank': _bankFdName.text, //Change
        'fdNo': _fdNoController.text, //Change
        'fdstartDate': //Change
            fdStartDate != null ? Timestamp.fromDate(fdStartDate) : null,
        'fdendtDate':
            fdEndDate != null ? Timestamp.fromDate(fdEndDate) : null, //Change
        'fdMaturityDate':
            fdMaturityDate != null ? Timestamp.fromDate(fdMaturityDate) : null,
        'fdInterestRate': _fdInterestRateController.text.isNotEmpty
            ? double.parse(_fdInterestRateController.text)
            : null,
        'fdAmount': _fdAmount.text,
        'fdMaturatyAmount': _fdMaturatyAmount.text,
        // 'ageOfCommencement': _ageController.text.isNotEmpty
        //     ? int.parse(_ageController.text)
        //     : null,
        'premiumAmountPerFrequency': _premiumAmountController.text.isNotEmpty
            ? double.parse(_premiumAmountController.text)
            : null,
        'sumAssured': _sumAssuredController.text.isNotEmpty
            ? double.parse(_sumAssuredController.text)
            : null,
        'policyTerm': _policyTermController.text.isNotEmpty
            ? int.parse(_policyTermController.text)
            : null,
        'premiumPayingTerm': _premiumPayingTermController.text.isNotEmpty
            ? int.parse(_premiumPayingTermController.text)
            : null,
        'notes': _notesController.text,
      };

      try {
        if (_isEditing && _currentDocumentId != null) {
          await FirebaseFirestore.instance
              .collection('policy')
              .doc(uid)
              .update(policyData);
          _showConfirmationDialog('Success', 'Policy updated successfully.',
              () {
            setState(() {
              _isEditing = false;
            });
          });
        } else {
          await FirebaseFirestore.instance.collection('policy').add(policyData);
          _showConfirmationDialog('Success', 'Policy saved successfully.', () {
            setState(() {
              _isEditing = false;
            });
          });
        }
      } catch (e) {
        print('Error saving data to Firestore: $e');
      }
    }
  }

  Future<void> _deleteItem() async {
    if (_currentDocumentId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('policy')
            .doc(_currentDocumentId)
            .delete();
        _showConfirmationDialog('Deleted', 'Policy deleted successfully.', () {
          setState(() {
            _isEditing = false;
            _clearForm();
          });
        });
      } catch (e) {
        print('Error deleting document: $e');
      }
    } else {
      _showConfirmationDialog('Error', 'No policy selected to delete.', () {});
    }
  }

  void _addNewPolicy() {
    setState(() {
      _isEditing = true;
      _clearForm();
    });
  }

  void _clearForm() {
    _policyTypeController.clear();
    _policyNameController.clear();
    _policyNoController.clear();
    _clientIdController.clear();
    _nameController.clear();
    _addressController.clear();
    _dobController.clear();
    _issueDateController.clear();
    _premiumDueDateController.clear();
    _finalPremiumDueDateController.clear();
    // _ageController.clear();
    _premiumAmountController.clear();
    _sumAssuredController.clear();
    _policyTermController.clear();
    _premiumPayingTermController.clear();
    _fdMaturityDateController.clear();
    _fdInterestRateController.clear();
    _fdAmount.clear();
    _fdEndDate.clear();
    _fdStartDate.clear();
    _bankFdName.clear();
    _fdNoController.clear();
    _fdUserName.clear();
    _fdMaturatyAmount.clear();
    _currentDocumentId = null;
    _notesController.clear();
    _showFDFields = false;
  }

  void _populateFields(DocumentSnapshot doc) {
    _policyTypeController.text = doc['policyType'];
    _policyNameController.text = doc['policyName'];
    _policyNoController.text = doc['policyNo'];
    _clientIdController.text = doc['clientId'];
    _nameController.text = doc['name'];
    _addressController.text = doc['address'];
    _dobController.text = dateFormat.format(doc['dob'].toDate());
    _issueDateController.text = dateFormat.format(doc['issueDate'].toDate());
    _premiumDueDateController.text =
        dateFormat.format(doc['premiumDueDate'].toDate());
    _finalPremiumDueDateController.text =
        dateFormat.format(doc['finalPremiumDueDate'].toDate());
    // _ageController.text = doc['ageOfCommencement'].toString();
    _premiumAmountController.text = doc['premiumAmountPerFrequency'].toString();
    _sumAssuredController.text = doc['sumAssured'].toString();
    _policyTermController.text = doc['policyTerm'].toString();
    _premiumPayingTermController.text = doc['premiumPayingTerm'].toString();
    //Change
    _fdUserName.text = doc['fdusername'];
    _fdNoController.text = doc['fdNo'];
    _bankFdName.text = doc['nameofbank'];
    _fdStartDate.text = doc['fdstartDate'];
    _fdEndDate.text = doc['fdendtDate'];
    _fdMaturatyAmount.text = doc['fdMaturityDate'];
    _fdMaturityDateController.text = doc['fdMaturityDate'] != null
        ? dateFormat.format(doc['fdMaturityDate'].toDate())
        : '';
    _fdInterestRateController.text = doc['fdInterestRate']?.toString() ?? '';
    _notesController.text = doc['notes'].toString();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = dateFormat.format(picked);
      });
    }
  }

  void _showConfirmationDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Policy"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Policy Type'),
                  value: _policyTypeController.text.isEmpty
                      ? null
                      : _policyTypeController.text,
                  onChanged: _isEditing
                      ? (value) {
                          setState(() {
                            _policyTypeController.text = value!;
                            _showFDFields = value == 'FD';
                          });
                        }
                      : null,
                  items: ['FD', 'Insurance', 'Policy'].map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a policy type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // FD-specific fields
                if (_showFDFields) ...[
                  TextFormField(
                    controller: _fdUserName,
                    decoration:
                        const InputDecoration(labelText: 'FD Holder Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _bankFdName,
                    decoration:
                        const InputDecoration(labelText: 'Name Of Bank'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdNoController,
                    decoration:
                        const InputDecoration(labelText: 'FD Account Number'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdStartDate,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectDate(context, _fdStartDate);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdEndDate,
                    decoration: const InputDecoration(labelText: 'End Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectDate(context, _fdEndDate);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdAmount,
                    decoration:
                        const InputDecoration(labelText: 'Deposit Amount'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdInterestRateController,
                    decoration:
                        const InputDecoration(labelText: 'Interest Rate (%)'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdMaturatyAmount,
                    decoration:
                        const InputDecoration(labelText: 'Maturity Amount'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  // TextFormField(
                  //   controller: _fdMaturityDateController,
                  //   decoration:
                  //       const InputDecoration(labelText: 'Maturity Date'),
                  //   enabled: _isEditing,
                  //   onTap: () {
                  //     if (_isEditing) {
                  //       _selectDate(context, _fdMaturityDateController);
                  //     }
                  //   },
                  // ),`
                ],

                // Common fields for Insurance and Policy
                if (!_showFDFields) ...[
                  TextFormField(
                    controller: _policyNameController,
                    decoration: const InputDecoration(labelText: 'Policy Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _policyNoController,
                    decoration:
                        const InputDecoration(labelText: 'Policy Number'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _clientIdController,
                    decoration: const InputDecoration(labelText: 'Client ID'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _dobController,
                    decoration:
                        const InputDecoration(labelText: 'Date of Birth'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectDate(context, _dobController);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _issueDateController,
                    decoration: const InputDecoration(labelText: 'Issue Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectDate(context, _issueDateController);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _premiumDueDateController,
                    decoration:
                        const InputDecoration(labelText: 'Premium Due Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectDate(context, _premiumDueDateController);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _finalPremiumDueDateController,
                    decoration: const InputDecoration(
                        labelText: 'Final Premium Due Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectDate(context, _finalPremiumDueDateController);
                      }
                    },
                  ),
                  // const SizedBox(height: 16.0),
                  // TextFormField(
                  //   controller: _ageController,
                  //   decoration:
                  //       const InputDecoration(labelText: 'Age of Commencement'),
                  //   enabled: _isEditing,
                  // ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _premiumAmountController,
                    decoration: const InputDecoration(
                        labelText: 'Premium Amount Per Frequency'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _sumAssuredController,
                    decoration: const InputDecoration(labelText: 'Sum Assured'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _policyTermController,
                    decoration:
                        const InputDecoration(labelText: 'Policy Term (years)'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _premiumPayingTermController,
                    decoration: const InputDecoration(
                        labelText: 'Premium Paying Term (years)'),
                    enabled: _isEditing,
                  ),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isEditing ? _saveItem : null,
                  child: const Text('Save'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: !_isEditing
                      ? () {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      : null,
                  child: const Text('Edit'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _deleteItem,
                  child: const Text('Delete'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_currentDocumentId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddPayment(documentId: _currentDocumentId!),
                        ),
                      );
                    } else {
                      _showConfirmationDialog('Error',
                          'No policy selected for payment history.', () {});
                    }
                  },
                  child: const Text('Payment History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
