import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

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
  final dateFormat = DateFormat('yyyy-MM-dd'); // Date format for validation

  // Controllers for the text fields
  final _policyNameController = TextEditingController();
  final _policyNoController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _startDateController = TextEditingController();
  final _premiumDateController = TextEditingController();
  final _durationController = TextEditingController();
  final _rotationOfPolicyController = TextEditingController();

  bool _isEditing = false; // Track if the user is editing
  String? _currentDocumentId; // Track the document ID for editing/deleting

  @override
  void initState() {
    super.initState();
    _currentDocumentId = uid;
    if (_currentDocumentId != null) {
      _retrieveData();
    } else {
      _addNewPolicy(); // Make the form fillable on screen load
    }
  }

  Future<void> _retrieveData() async {
    debugPrint('uid = $uid');
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('policy')
            .doc(_currentDocumentId)
            .get();

    _populateFields(documentSnapshot);
    _isEditing = false;
  }

  // Method to save or update the policy
  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Convert string input to DateTime objects
      final dueDate = dateFormat.parse(_dueDateController.text);
      final startDate = dateFormat.parse(_startDateController.text);
      final premiumDate = dateFormat.parse(_premiumDateController.text);

      // Prepare data to save
      final policyData = {
        'policyHolder': userEmail,
        'policyName': _policyNameController.text,
        'policyNo': _policyNoController.text,
        'dueDate': Timestamp.fromDate(dueDate),
        'startDate': Timestamp.fromDate(startDate),
        'premiumDate': Timestamp.fromDate(premiumDate),
        'duration': int.parse(_durationController.text),
        'rotationOfPolicy': _rotationOfPolicyController.text,
      };

      try {
        if (_isEditing && _currentDocumentId != null) {
          // Update the existing document
          await FirebaseFirestore.instance
              .collection('policy')
              .doc(uid)
              .update(policyData);
          _showConfirmationDialog('Success', 'Policy updated successfully.',
              () {
            setState(() {
              _isEditing = false; // Disable editing after save
            });
          });
        } else {
          // Save a new document
          await FirebaseFirestore.instance.collection('policy').add(policyData);
          _showConfirmationDialog('Success', 'Policy saved successfully.', () {
            setState(() {
              _isEditing = false; // Disable editing after save
            });
          });
        }
      } catch (e) {
        print('Error saving data to Firestore: $e');
        // You can show an error dialog here
      }
    }
  }

  // Method to edit an existing policy
  // Future<void> _editItem() async {
  //   // Simulate fetching an existing document
  //   // In a real application, you would get the document from a list or a Firestore query
  //   final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //       .collection('policy')
  //       .where('policyNo', isEqualTo: _policyNoController.text)
  //       .get()
  //       .then((querySnapshot) => querySnapshot.docs.first);

  //   if (documentSnapshot.exists) {
  //     setState(() {
  //       _currentDocumentId = documentSnapshot.id;
  //       _isEditing = true;
  //       _populateFields(documentSnapshot);
  //     });
  //   } else {
  //     _showConfirmationDialog('Error', 'Policy not found.', () {});
  //   }
  // }

  // Method to delete an existing policy
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
        // You can show an error dialog here
      }
    } else {
      _showConfirmationDialog('Error', 'No policy selected to delete.', () {});
    }
  }

  // Method to add a new policy (clear the form for new entry)
  void _addNewPolicy() {
    setState(() {
      _isEditing = true;
      _clearForm();
    });
  }

  // Helper method to clear the form
  void _clearForm() {
    _policyNameController.clear();
    _policyNoController.clear();
    _dueDateController.clear();
    _startDateController.clear();
    _premiumDateController.clear();
    _durationController.clear();
    _rotationOfPolicyController.clear();
    _currentDocumentId = null;
  }

  // Method to populate fields with data from Firestore when editing
  void _populateFields(DocumentSnapshot doc) {
    _policyNameController.text = doc['policyName'];
    _policyNoController.text = doc['policyNo'];
    _dueDateController.text = dateFormat.format(doc['dueDate'].toDate());
    _startDateController.text = dateFormat.format(doc['startDate'].toDate());
    _premiumDateController.text =
        dateFormat.format(doc['premiumDate'].toDate());
    _durationController.text = doc['duration'].toString();
    _rotationOfPolicyController.text = doc['rotationOfPolicy'];
  }

  // Method to show confirmation dialog
  void _showConfirmationDialog(
      String title, String content, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk();
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
                // Policy Name
                TextFormField(
                  controller: _policyNameController,
                  decoration: const InputDecoration(labelText: 'Policy Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the policy name';
                    }
                    return null;
                  },
                  enabled: _isEditing,
                ),
                const SizedBox(height: 20),
                // Policy No
                TextFormField(
                  controller: _policyNoController,
                  decoration: const InputDecoration(labelText: 'Policy No'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the policy number';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                      return 'Policy No should be alphanumeric';
                    }
                    return null;
                  },
                  enabled: _isEditing,
                ),
                const SizedBox(height: 20),

                // Due Date
                GestureDetector(
                  onTap: _isEditing
                      ? () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dueDateController.text =
                                  dateFormat.format(selectedDate);
                            });
                          }
                        }
                      : null,
                  child: AbsorbPointer(
                    child: TextFormField(
                      enabled: _isEditing,
                      controller: _dueDateController,
                      decoration: const InputDecoration(labelText: 'Due Date'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the due date';
                        }
                        try {
                          dateFormat.parseStrict(value);
                        } catch (e) {
                          return 'Enter a valid date (yyyy-MM-dd)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Start Date
                GestureDetector(
                  onTap: _isEditing
                      ? () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _startDateController.text =
                                  dateFormat.format(selectedDate);
                            });
                          }
                        }
                      : null,
                  child: AbsorbPointer(
                    child: TextFormField(
                      enabled: _isEditing,
                      controller: _startDateController,
                      decoration:
                          const InputDecoration(labelText: 'Start Date'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the start date';
                        }
                        try {
                          dateFormat.parseStrict(value);
                        } catch (e) {
                          return 'Enter a valid date (yyyy-MM-dd)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Premium Date
                GestureDetector(
                  onTap: _isEditing
                      ? () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _premiumDateController.text =
                                  dateFormat.format(selectedDate);
                            });
                          }
                        }
                      : null,
                  child: AbsorbPointer(
                    child: TextFormField(
                      enabled: _isEditing,
                      controller: _premiumDateController,
                      decoration:
                          const InputDecoration(labelText: 'Premium Date'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the premium date';
                        }
                        try {
                          dateFormat.parseStrict(value);
                        } catch (e) {
                          return 'Enter a valid date (yyyy-MM-dd)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Duration
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the duration';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Duration must be a number';
                    }
                    return null;
                  },
                  enabled: _isEditing,
                ),
                const SizedBox(height: 20),

                // Rotation of Policy
                TextFormField(
                  controller: _rotationOfPolicyController,
                  decoration:
                      const InputDecoration(labelText: 'Rotation of Policy'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rotation of the policy';
                    }
                    return null;
                  },
                  enabled: _isEditing,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isEditing ? _saveItem : null,
                        child: const Text(
                          'Save',
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        // onPressed: !_isEditing ? _editItem : null,
                        onPressed: () => setState(() {
                          _isEditing = true;
                        }),
                        child: const Text(
                          'Edit',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteItem,
                        child: const Text(
                          'Delete',
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addNewPolicy,
                        child: const Text(
                          'Add New Policy',
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
