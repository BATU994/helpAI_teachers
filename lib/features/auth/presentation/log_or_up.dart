import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';
import 'package:helpai_teachers/home.dart';
import 'package:helpai_teachers/theme/apptheme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogOrUp extends StatefulWidget {
  final bool isSigned;
  const LogOrUp({super.key, required this.isSigned});

  @override
  State<LogOrUp> createState() => _LogOrUpState();
}

class _LogOrUpState extends State<LogOrUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _jobController = TextEditingController();
  final _descController = TextEditingController();
  final _skillsController = TextEditingController();
  final _expController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isloggedin') ?? false;
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) _showSnackBar('Sign-in cancelled');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user != null && user.email != null) {
        Provider.of<DataProvider>(
          context,
          listen: false,
        ).fetchAndSetUserData(user.uid);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isloggedin', true);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      }
    } catch (e) {
      String message =
          e is FirebaseException
              ? e.message ?? 'Google Sign-In failed'
              : 'Google Sign-In failed';
      if (mounted) _showSnackBar(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginOrRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      User? user;

      if (widget.isSigned) {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        user = userCredential.user;
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users_teachers')
              .doc(user.uid)
              .set({
                'firstName': _firstController.text.toString(),
                'lastName': _lastController.text.toString(),
                'job': _jobController.text.toString(),
                'desc': _descController.text.toString(),
                'uid': user.uid.toString(),
                'skills': _skillsController.text.toString(),
                'exp': _expController.text.toString(),
                'imageUrl': 'https://i.pravatar.cc/150?img=3',
                'createdAt': FieldValue.serverTimestamp(),
                'lastSeen': FieldValue.serverTimestamp(),
                'chats': [],
                'available': '',
                'metadata': {
                  'role': 'user',
                  'createdAt': DateTime.now().toIso8601String(),
                  'updatedAt': FieldValue.serverTimestamp(),
                },
              });
        }
      }

      if (user != null && user.email != null) {
        Provider.of<DataProvider>(
          context,
          listen: false,
        ).fetchAndSetUserData(user.uid);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isloggedin', true);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      } else {
        if (mounted) _showSnackBar('Authentication failed.');
      }
    } catch (e) {
      String errorMessage = 'An error occurred';

      if (e is FirebaseAuthException) {
        errorMessage = _getErrorMessage(e);
      } else if (e is FirebaseException) {
        errorMessage = e.message ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      if (mounted) _showSnackBar(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email';
      case 'weak-password':
        return 'Password too weak';
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid credentials';
      default:
        return 'An error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                height: 150,
                color: AppTheme.primary,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    widget.isSigned ? 'Log In' : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          !widget.isSigned
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'First Name',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _firstController,
                                    decoration: _inputDecoration(
                                      'Enter your First Name',
                                      toggleVisibility: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your First Name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Last Name',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _lastController,
                                    decoration: _inputDecoration(
                                      'Enter your First Name',
                                      toggleVisibility: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your First Name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Job',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _jobController,
                                    decoration: _inputDecoration(
                                      'Enter kind of job',
                                      toggleVisibility: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter kind of job';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Description',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _descController,
                                    decoration: _inputDecoration(
                                      'Description',
                                      toggleVisibility: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your description';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Skills',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _skillsController,
                                    decoration: _inputDecoration(
                                      'Skills',
                                      toggleVisibility: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your skills';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Work Experience',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _expController,
                                    decoration: _inputDecoration(
                                      'Work Experience',
                                      toggleVisibility: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Work Experience';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                ],
                              )
                              : SizedBox.shrink(),
                          const Text('Email', style: TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: _inputDecoration('Enter your email'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Password',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: _inputDecoration(
                              'Enter your password',
                              toggleVisibility: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),

                          FilledButton(
                            onPressed: _isLoading ? null : _loginOrRegister,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              widget.isSigned ? 'Log In' : 'Sign Up',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                shape: const CircleBorder(),
                                elevation: 0,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.white,
                              ),
                              child: SvgPicture.asset(
                                'assets/images/google_icon.svg',
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hintText, {
    bool toggleVisibility = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      suffixIcon:
          toggleVisibility
              ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
              : null,
    );
  }
}
