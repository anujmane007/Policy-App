import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:privacy_app/constants.dart';
// import 'package:privacy_app/screens/Home.dart';
import 'package:privacy_app/screens/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;
  String? selectedGender = 'Male';

  void _try_Submit() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // Validate the form
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Show a loading indicator
      if (phoneController.text.length == 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating account...')),
        );

        // Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'age': ageController.text.trim(),
            'gender': selectedGender,
            'aadhar': aadharController.text.trim(),
            'phone': phoneController.text.trim(),
            'address': addressController.text.trim(),
            'password': passwordController.text.trim(),
            'createdAt': Timestamp.now(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // builder: (context) => HomeScreen(userEmail: emailController.text.trim()),
              builder: (context) => LoginPage(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone no invalid')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign Up failed. Please try again.';
      debugPrint(e.code);

      if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello there,',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 5),
            const Text(
              'We are excited to see you here',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.name,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your name';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your email';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.email, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: ageController,
              keyboardType: TextInputType.number,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your age';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Age',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.cake, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  const Icon(Icons.wc, color: kPrimaryColor),
                  const SizedBox(width: 16),
                  const Text('Gender',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(220, 57, 6, 64))),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Male',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                      const Text('Male'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Female',
                        // fillColor: const WidgetStatePropertyAll(Colors.black),
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                      const Text('Female'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: aadharController,
              keyboardType: TextInputType.number,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your Aadhr No';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Aadhar No',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.fingerprint, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: phoneController,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your Phone No';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Phone No',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.phone, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: addressController,
              keyboardType: TextInputType.multiline,
              cursorColor: kPrimaryColor,
              minLines: 3,
              maxLines: null,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your Address';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                hintText: 'Address',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Icon(Icons.home, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: kPrimaryColor,
              obscureText: _isPasswordVisible,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your Password';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock, color: kPrimaryColor),
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: _isPasswordVisible
                        ? const Icon(Icons.visibility, color: kPrimaryColor)
                        : const Icon(Icons.visibility_off,
                            color: kPrimaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _isConfirmPasswordVisible,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Confirm your Password';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'Confirm password',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock, color: kPrimaryColor),
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: _isConfirmPasswordVisible
                        ? const Icon(Icons.visibility, color: kPrimaryColor)
                        : const Icon(Icons.visibility_off,
                            color: kPrimaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _try_Submit,
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ))
          ],
        ),
      ),
    );
  }
}
