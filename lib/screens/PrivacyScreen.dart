import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers for text fields
  final _policyTypeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _policyNameController = TextEditingController();
  final _policyNoController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _premiumDueDateController = TextEditingController();
  final _finalPremiumDueDateController = TextEditingController();
  final _ageController = TextEditingController();
  final _premiumAmountController = TextEditingController();
  final _sumAssuredController = TextEditingController();
  final _policyTermController = TextEditingController();
  final _premiumPayingTermController = TextEditingController();
  //change
  final _fdNoController = TextEditingController();
  final _fdUsernameController = TextEditingController();
  final _NomineeNameController = TextEditingController();
  final _fdBankNameController = TextEditingController();
  final _fdInterestRateController = TextEditingController();
  final _fdAmountController = TextEditingController();
  final _fdMaturityAmountController = TextEditingController();
  final _fdStartDateController = TextEditingController();
  final _fdEndDateController = TextEditingController();
  final _fdMaturityDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _fdYearsController = TextEditingController();
  final _fdHolderNameController = TextEditingController();

  bool _isEditing = false;
  String? _currentDocumentId;
  bool _showFDFields = false;
  String? _selectedPremiumTerm;
  bool _isJointFD = false;
  String? _base64Image; // To store the Base64 encoded image
  File? _imageFile; // To store the image file locally

  final ImagePicker _picker = ImagePicker();

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
      // final fdMaturityDate = _fdMaturityDateController.text.isNotEmpty
      //     ? dateFormat.parse(_fdMaturityDateController.text)
      //     : null;

      // FD Date Controllers
      final fdStartDate = _fdStartDateController.text.isNotEmpty
          ? dateFormat.parse(_fdStartDateController.text)
          : null;
      final fdEndDate = _fdEndDateController.text.isNotEmpty
          ? dateFormat.parse(_fdEndDateController.text)
          : null;

      final policyData = {
        'policyHolder': userEmail,
        'policyType': _policyTypeController.text,
        'companyName': _companyNameController.text,
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
        'fdNo': _fdNoController.text,
        'fdUsername': _fdUsernameController.text,
        'NomineeName': _NomineeNameController.text,
        'fdBankName': _fdBankNameController.text,
        'interestRate': _fdInterestRateController.text,
        'fdAmount': _fdAmountController.text,
        'fdMaturityAmount': _fdMaturityAmountController.text.isNotEmpty
            ? double.parse(_fdMaturityAmountController.text)
            : null,
        'fdStartDate':
            fdStartDate != null ? Timestamp.fromDate(fdStartDate) : null,
        'fdEndDate': fdEndDate != null ? Timestamp.fromDate(fdEndDate) : null,
        // 'fdMaturityAmount': _fdMaturityAmount.text.isNotEmpty
        //     ? double.parse(_fdMaturityAmount.text)
        //     : null,
        'isJointFD': _isJointFD,
        'fdHolderName': _isJointFD ? _fdHolderNameController.text : '',
        'ageOfCommencement': _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        // 'premiumAmountPerFrequency': _premiumAmountController.text.isNotEmpty
        //     ? double.parse(_premiumAmountController.text)
        //     : null,
        'sumAssured': _sumAssuredController.text.isNotEmpty
            ? double.parse(_sumAssuredController.text)
            : null,
        'policyTerm': _policyTermController.text.isNotEmpty
            ? int.parse(_policyTermController.text)
            : null,
        'premiumTerm': _selectedPremiumTerm,
        'premiumPayingTerm': _premiumPayingTermController.text.isNotEmpty
            ? int.parse(_premiumPayingTermController.text)
            : null,
        'notes': _notesController.text,
        'image': _base64Image,
      };

      try {
        if (_isEditing && _currentDocumentId != null) {
          await FirebaseFirestore.instance
              .collection('policy')
              .doc(_currentDocumentId)
              .update(policyData);
          _showConfirmationDialog('Success', 'Policy updated successfully.',
              () {
            setState(() {
              _isEditing = false;
            });
          });
        } else {
          await FirebaseFirestore.instance.collection('policy').add(policyData);
          _showConfirmationDialog('Success', 'Information saved successfully.',
              () {
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

  void _calculateMaturityAmount() {
    if (_fdAmountController.text.isEmpty ||
        _fdInterestRateController.text.isEmpty ||
        _fdYearsController.text.isEmpty) {
      _fdMaturityAmountController.text = '';
      return;
    }

    double principal = double.tryParse(_fdAmountController.text) ?? 0.0;
    double rateOfInterest =
        double.tryParse(_fdInterestRateController.text) ?? 0.0;
    double years = double.tryParse(_fdYearsController.text) ?? 0.0;

    if (principal > 0 && rateOfInterest > 0 && years > 0) {
      double maturityAmount = principal * pow(1 + rateOfInterest / 100, years);
      _fdMaturityAmountController.text = maturityAmount.toStringAsFixed(2);
    } else {
      _fdMaturityAmountController.text = '';
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
    _companyNameController.clear();
    _policyNameController.clear();
    _policyNoController.clear();
    _clientIdController.clear();
    _nameController.clear();
    _addressController.clear();
    _dobController.clear();
    _issueDateController.clear();
    _premiumDueDateController.clear();
    _finalPremiumDueDateController.clear();
    _ageController.clear();
    _premiumAmountController.clear();
    _sumAssuredController.clear();
    _policyTermController.clear();
    _premiumPayingTermController.clear();
    //FD Date Controllers
    _fdMaturityDateController.clear();
    _fdInterestRateController.clear();
    _fdNoController.clear();
    _fdAmountController.clear();
    _fdUsernameController.clear();
    _NomineeNameController.clear();
    _fdBankNameController.clear();
    _fdInterestRateController.clear();
    _fdMaturityAmountController.clear();
    _fdStartDateController.clear();
    _fdEndDateController.clear();

    _currentDocumentId = null;
    _notesController.clear();
    _showFDFields = false;
  }

  // Update `_populateFields` function to reflect the new format
  void _populateFields(DocumentSnapshot doc) {
    _policyTypeController.text = doc['policyType'] ?? '';
    _companyNameController.text = doc['companyName'] ?? '';
    _policyNameController.text = doc['policyName'] ?? '';
    _policyNoController.text = doc['policyNo'] ?? '';
    _clientIdController.text = doc['clientId'] ?? '';
    _nameController.text = doc['name'] ?? '';
    _addressController.text = doc['address'] ?? '';
    _dobController.text =
        doc['dob'] != null ? dateFormat.format(doc['dob'].toDate()) : '';
    _issueDateController.text = doc['issueDate'] != null
        ? dateFormat.format(doc['issueDate'].toDate())
        : '';
    _premiumDueDateController.text = doc['premiumDueDate'] != null
        ? dateFormat.format(doc['premiumDueDate'].toDate())
        : '';
    _finalPremiumDueDateController.text = doc['finalPremiumDueDate'] != null
        ? dateFormat.format(doc['finalPremiumDueDate'].toDate())
        : '';
    _ageController.text = doc['ageOfCommencement']?.toString() ?? '';
    // _premiumAmountController.text =
    //     doc['premiumAmountPerFrequency']?.toString() ?? '';
    _sumAssuredController.text = doc['sumAssured']?.toString() ?? '';
    _policyTermController.text = doc['policyTerm']?.toString() ?? '';
    _premiumPayingTermController.text =
        doc['premiumPayingTerm']?.toString() ?? '';

    // FD-related fields
    _fdNoController.text = doc['fdNo'] ?? '';
    _fdUsernameController.text = doc['fdUsername'] ?? '';
    _NomineeNameController.text = doc['NomineeName'] ?? '';
    _fdBankNameController.text = doc['fdBankName'] ?? '';
    _fdInterestRateController.text = doc['interestRate'] ?? '';
    _fdAmountController.text = doc['fdAmount'] ?? '';
    _fdMaturityAmountController.text =
        doc['fdMaturityAmount']?.toString() ?? '';
    _fdStartDateController.text = doc['fdStartDate'] != null
        ? dateFormat.format(doc['fdStartDate'].toDate())
        : '';
    _fdEndDateController.text = doc['fdEndDate'] != null
        ? dateFormat.format(doc['fdEndDate'].toDate())
        : '';
    _fdMaturityDateController.text = doc['fdMaturityDate'] != null
        ? dateFormat.format(doc['fdMaturityDate'].toDate())
        : '';

    _notesController.text = doc['notes']?.toString() ?? '';
  }

// Update `_selectDate` to use the new date format
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

        // Check if both issueDate and finalPremiumDueDate are filled, then calculate the policy term
        if (_issueDateController.text.isNotEmpty &&
            _finalPremiumDueDateController.text.isNotEmpty) {
          final issueDate = dateFormat.parse(_issueDateController.text);
          final finalPremiumDueDate =
              dateFormat.parse(_finalPremiumDueDateController.text);

          // Calculate the difference in years
          int policyTerm = finalPremiumDueDate.year - issueDate.year;
          if (finalPremiumDueDate.month < issueDate.month ||
              (finalPremiumDueDate.month == issueDate.month &&
                  finalPremiumDueDate.day < issueDate.day)) {
            policyTerm--;
          }

          // Update the policy term controller
          _policyTermController.text = policyTerm.toString();
        }
      });
    }
  }

  Future<void> _selectFDDate(
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

        // Calculate FD Years if both start date and end date are provided
        if (_fdStartDateController.text.isNotEmpty &&
            _fdEndDateController.text.isNotEmpty) {
          final startDate = dateFormat.parse(_fdStartDateController.text);
          final endDate = dateFormat.parse(_fdEndDateController.text);

          // Calculate the difference in years
          int fdYears = endDate.year - startDate.year;
          if (endDate.month < startDate.month ||
              (endDate.month == startDate.month &&
                  endDate.day < startDate.day)) {
            fdYears--;
          }

          // Update the FD years controller
          _fdYearsController.text = fdYears.toString();
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = base64Encode(
            _imageFile!.readAsBytesSync()); // Convert image to Base64
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
                  decoration: const InputDecoration(labelText: 'Select Type'),
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
                  items: ['FD', 'Insurance', 'Other'].map((String category) {
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
                    controller: _fdUsernameController,
                    decoration:
                        const InputDecoration(labelText: 'FD Holder Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Is Joint FD?'),
                      Switch(
                        value: _isJointFD,
                        onChanged: (bool value) {
                          setState(() {
                            _isJointFD = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isJointFD) ...[
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _fdHolderNameController,
                      decoration: const InputDecoration(
                          labelText: '2nd FD Holder Name'),
                      enabled: _isEditing,
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _NomineeNameController,
                    decoration:
                        const InputDecoration(labelText: 'Nominee Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdBankNameController,
                    decoration:
                        const InputDecoration(labelText: 'FD Bank Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdNoController,
                    decoration: const InputDecoration(labelText: 'FD Number'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdStartDateController,
                    decoration:
                        const InputDecoration(labelText: 'FD Start Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectFDDate(context, _fdStartDateController);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdEndDateController,
                    decoration: const InputDecoration(labelText: 'FD End Date'),
                    enabled: _isEditing,
                    onTap: () {
                      if (_isEditing) {
                        _selectFDDate(context, _fdEndDateController);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdYearsController,
                    decoration: const InputDecoration(labelText: 'FD Years'),
                    enabled: false, // FD years are calculated automatically
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdAmountController,
                    decoration: const InputDecoration(labelText: 'FD Amount'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _calculateMaturityAmount(),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdInterestRateController,
                    decoration:
                        const InputDecoration(labelText: 'Rate of Interest'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _calculateMaturityAmount(),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _fdMaturityAmountController,
                    decoration:
                        const InputDecoration(labelText: 'FD Maturity Amount'),
                    enabled: true, // Keep it non-editable
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Image'),
                  ),
                  if (_imageFile != null) ...[
                    const SizedBox(height: 16.0),
                    Image.file(_imageFile!,
                        height: 100, width: 100, fit: BoxFit.cover),
                  ],
                ],
                // Common fields for Insurance and Policy
                if (!_showFDFields) ...[
                  TextFormField(
                    controller: _companyNameController,
                    decoration:
                        const InputDecoration(labelText: 'Company Name'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16.0),
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
                    decoration:
                        const InputDecoration(labelText: 'Policy Holder Name'),
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
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedPremiumTerm,
                    decoration: const InputDecoration(
                      labelText: 'Premium Term',
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Annually', child: Text('Annually')),
                      DropdownMenuItem(
                          value: 'Semiannually', child: Text('Semiannually')),
                      DropdownMenuItem(
                          value: 'Quarterly', child: Text('Quarterly')),
                    ],
                    onChanged: _isEditing
                        ? (value) {
                            setState(() {
                              _selectedPremiumTerm = value;
                            });
                          }
                        : null, // Disable dropdown when _isEditing is false
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
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Image'),
                  ),
                  if (_imageFile != null) ...[
                    const SizedBox(height: 16.0),
                    Image.file(_imageFile!,
                        height: 100, width: 100, fit: BoxFit.cover),
                  ],
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
