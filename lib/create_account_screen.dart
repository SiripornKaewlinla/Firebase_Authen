import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackbar('Please fill in all fields', Colors.red);
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('Passwords do not match', Colors.red);
      return;
    }

    try {
      User? user =
          await AuthService().createUserWithEmailAndPassword(email, password);
      if (user != null) {
        Navigator.pop(context);
      } else {
        _showSnackbar('Account creation failed', Colors.red);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again later.";
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
      }
      _showSnackbar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackbar('An unexpected error occurred.', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Create Account',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                _buildTextField('Email', Icons.email, _emailController, false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next),
                SizedBox(height: 16.0),
                _buildTextField(
                    'Password', Icons.lock, _passwordController, true,
                    textInputAction: TextInputAction.next),
                SizedBox(height: 16.0),
                _buildTextField('Confirm Password', Icons.lock_outline,
                    _confirmPasswordController, true,
                    textInputAction: TextInputAction.done),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _createAccount,
                  child: Text('Create Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 134, 188, 232),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller, bool obscureText,
      {TextInputType? keyboardType, TextInputAction? textInputAction}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
        hintText: label,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
    );
  }
}
