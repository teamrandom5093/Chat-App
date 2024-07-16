import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_sign_in/consts.dart';
import 'package:social_sign_in/sevices/alert_service.dart';
import 'package:social_sign_in/sevices/auth_service.dart';
import 'package:social_sign_in/sevices/navigation_service.dart';
import '../Widgets/custom_form_field.dart';
import 'package:get_it/get_it.dart';

class SigninPage extends StatefulWidget {
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Center(
          child: Column(
            children: [_headerText(), _loginForm()],
          ),
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to OPC",
            style: TextStyle(
              height: 1,
              fontWeight: FontWeight.w800,
              fontSize: 25,
            ),
          ),
          Text(
            "Start chatting with your friends",
            style: TextStyle(
              color: Colors.grey,
              height: 2,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.4,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05,
        ),
        child: Form(
            key: _loginFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomFormField(
                  hintText: 'email',
                  height: MediaQuery.sizeOf(context).height * 0.12,
                  validationRegEx: EMAIL_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                CustomFormField(
                  hintText: 'password',
                  height: MediaQuery.sizeOf(context).height * 0.12,
                  validationRegEx: PASSWORD_VALIDATION_REGEX,
                  obscureText: true,
                  onSaved: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                _loginButton(),
                _createAnAccountLink(),
              ],
            )));
  }

  Widget _loginButton() {
    return SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: MaterialButton(
          onPressed: () async {
            if (_loginFormKey.currentState?.validate() ?? false) {
              _loginFormKey.currentState?.save();
              bool result = await _authService.login(email!, password!);
              print(result);
              if (result) {
                _alertService.showToast(
                    text: "Logged in successfully.", icon: Icons.login);
                _navigationService.pushReplacementNamed("/home");
              } else {
                _alertService.showToast(
                  text: "Failed to login, try again!",
                  icon: Icons.error,
                );
              }
            }
          },
          color: Theme.of(context).colorScheme.primary,
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  Widget _createAnAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("Don't have an account? "),
          GestureDetector(
            onTap: (){
              _navigationService.pushNamed("/register");
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
