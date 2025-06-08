import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signInWithEmail() async {
    if (_formkey.currentState!.validate()){
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
        Navigator.pushReplacementNamed(context, '/permissions');
      } on FirebaseAuthException catch (e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Authentication Failed!')));
        
      }
  }
  }

  Future<void> _signInWithGoogle() async {
    try {
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
     if (googleUser == null) return;

     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth.idToken,
       idToken: googleAuth.idToken,
     );

     await FirebaseAuth.instance.signInWithCredential(credential);
     Navigator.pushReplacementNamed(context, '/permissions');
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign in failed')),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Password reset failed')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: _signInWithEmail, child: const Text('Login')),
              TextButton(onPressed: _resetPassword, child: const Text('Forgot Password?')),
              const Divider(),
              ElevatedButton(onPressed: _signInWithGoogle, child: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,   // replaces primary
                foregroundColor: Colors.black,   // replaces onPrimary
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
