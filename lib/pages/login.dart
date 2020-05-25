import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:nivocourier/models/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _email, _error, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final BaseAuth auth = Auth();

  Future<void> _signIn() async {
    setState(() {
      _error = '';
    });
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        AuthResult result = await auth.signIn(_email, _password);
        final String uid = result.user.uid;
        if (uid != null && uid != '') {
          Navigator.pushNamed(context, '/orders');
        }
      } on PlatformException catch (err) {
        setState(() {
          _error = err.message;
        });
      } catch (err) {
        print(err);
        _error = err.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.all(20),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  validator: (value) =>
                      value.isEmpty ? 'Please type your email' : null,
                  onSaved: (value) => _email = value,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  validator: (value) => value.length < 6
                      ? 'Your password needs to be atleast 6 characters'
                      : null,
                  onSaved: (value) => _password = value,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                Text(
                  _error != null && _error != '' ? _error : '',
                  style: TextStyle(color: Colors.red),
                ),
                RaisedButton(
                  onPressed: _signIn,
                  child: Text('Sign in'),
                )
              ],
            )),
      ),
    );
  }
}
