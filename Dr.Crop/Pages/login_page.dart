import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_crop/pages/home_page.dart';

void main() {
  runApp(const login_page());
}

class login_page extends StatelessWidget {
  const login_page({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drcrop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent! Check your inbox.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your email to reset your password",
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  Future<String?> _getEmailFromUsername(String username) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first['email'];
      }
    } catch (e) {
      print("Error fetching email: $e");
    }
    return null;
  }

  Future<void> _login() async {
    if (_emailOrUsernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Email/Username and password cannot be empty!";
      });
      return;
    }

    String loginInput = _emailOrUsernameController.text.trim();
    String? email;

    if (!loginInput.contains("@")) {
      email = await _getEmailFromUsername(loginInput);
      if (email == null) {
        setState(() {
          _errorMessage = "Username not found!";
        });
        return;
      }
    } else {
      email = loginInput;
    }

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email!,
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(
          //   builder: (context) => HomePage(user: userCredential.user!),
          // ),
          MaterialPageRoute(builder: (context) => const DrCropApp()),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Invalid username/email or password";
      });
    }
  }


  Future<void> _saveUserToFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'lastLogin': DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        _saveUserToFirestore(userCredential.user!);
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (context) => HomePage(user: userCredential.user!)),
          MaterialPageRoute(builder: (context) => const DrCropApp()),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Google Sign-In failed: ${error.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("lib/assets/logo.png"),
                      onBackgroundImageError: (error, stackTrace) => const Icon(Icons.image, size: 50),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    TextField(
                      controller: _emailOrUsernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Colors.black),
                        hintText: 'Username or Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('LOGIN'),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const Text('Or', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _signInWithGoogle(context),
                        icon: Image.asset(
                          "lib/assets/google_logo.png",
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 24),
                        ),
                        label: const Text('Sign in with Google'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  // Future<bool> _isUsernameTaken(String username) async {
  //   try {
  //     QuerySnapshot query = await _firestore
  //         .collection('users')
  //         .where('username', isEqualTo: username)
  //         .get();
  //
  //     return query.docs.isNotEmpty;
  //   } catch (e) {
  //     print("Error checking username: $e");
  //     return false; // Assume username is available if there's an error
  //   }
  // }

  Future<bool> _isUsernameTaken(String username) async {
    try {
      QuerySnapshot query = await _firestore.collection('users')
          .where('username', isEqualTo: username)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print("Error checking username: $e");
      return false;
    }
  }

  void _registerUser() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = "Passwords do not match!";
      });
      return;
    }

    if (await _isUsernameTaken(_usernameController.text.trim())) {
      setState(() {
        _errorMessage = "Username already taken!";
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Store user details in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': _usernameController.text.trim(),
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context); // Go back to Login Screen after registration
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Registration failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "lib/assets/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("lib/assets/logo.png", height: 100),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(labelText: "Username"),
                            ),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: "Email"),
                            ),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: "Password"),
                            ),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: "Confirm Password"),
                            ),
                            const SizedBox(height: 10),
                            if (_errorMessage != null)
                              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _registerUser,
                              child: const Text("REGISTER"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Home Page with Logout Button
class HomePage extends StatelessWidget {
  final User user;

  const HomePage({required this.user, Key? key}) : super(key: key);

  void _showUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.photoURL != null)
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.photoURL!),
                ),
              const SizedBox(height: 10),
              Text("Name: ${user.displayName ?? 'N/A'}"),
              Text("Email: ${user.email}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Ensure LoginScreen exists
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-out failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          // User Icon (Clickable to Show Details)
          IconButton(
            icon: CircleAvatar(
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : const AssetImage("lib/assets/default_avatar.png") as ImageProvider,
            ),
            onPressed: () => _showUserDetails(context),
          ),

          // Sign Out Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _signOut(context), // Fixed logout function
          ),
        ],
      ),
      body: Center(
        child: const Text("Welcome to Dr.Crop", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}


