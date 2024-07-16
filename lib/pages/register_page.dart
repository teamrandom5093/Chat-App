import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:social_sign_in/Widgets/custom_form_field.dart';
import 'package:social_sign_in/consts.dart';
import 'package:social_sign_in/models/user_profile.dart';
import 'package:social_sign_in/sevices/alert_service.dart';
import 'package:social_sign_in/sevices/auth_service.dart';
import 'package:social_sign_in/sevices/database_service.dart';
import 'package:social_sign_in/sevices/media_service.dart';
import 'package:social_sign_in/sevices/navigation_service.dart';
import 'package:social_sign_in/sevices/storage_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  String? email, name, password;
  bool isloading = false;

  late MediaService _mediaService;
  late AuthService _authService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          _headerText(),
          if (!isloading) _registerForm(),
          if (!isloading) _loginAccountLink(),
          if (isloading)
            const Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ))
        ],
      ),
    ));
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
            "SignUp to OPC",
            style: TextStyle(
              height: 1,
              fontWeight: FontWeight.w800,
              fontSize: 25,
            ),
          ),
          Text(
            "Register to start chatting!",
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

  Widget _registerForm() {
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.60,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.sizeOf(context).height * 0.05),
        child: Form(
            key: _registerFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _pfpSelection(),
                CustomFormField(
                    hintText: "Name",
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    validationRegEx: NAME_VALIDATION_REGEX,
                    onSaved: (value) {
                      setState(() {
                        name = value;
                      });
                    }),
                CustomFormField(
                    hintText: "Email",
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    validationRegEx: EMAIL_VALIDATION_REGEX,
                    onSaved: (value) {
                      setState(() {
                        email = value;
                      });
                    }),
                CustomFormField(
                    hintText: "Password",
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    validationRegEx: PASSWORD_VALIDATION_REGEX,
                    obscureText: true,
                    onSaved: (value) {
                      setState(() {
                        password = value;
                      });
                    }),
                _registerButton(),
              ],
            )));
  }

  Widget _pfpSelection() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.15,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
        ),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            setState(() {
              isloading = true;
            });
            try {
              if (_registerFormKey.currentState?.validate() ??
                  false && selectedImage != null) {
                _registerFormKey.currentState?.save();
              }
              bool result = await _authService.signUp(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectedImage!, uid: _authService.user!.uid);
                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                          uid: _authService.user!.uid,
                          name: name,
                          pfpURL: pfpURL));
                  _alertService.showToast(
                      text: "User registered successfully", icon: Icons.check);
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed("/home");
                }
                else {
                  throw Exception("Unable to upload profile picture");
                }
              }
              else{
                throw Exception("Unable to register the user");
              }
            } catch (e) {
              print(e);
              _alertService.showToast(text: "Registration failed, try again!",icon: Icons.error);
            }
            setState(() {
              isloading = false;
            });
          },
          child: const Text(
            "Register",
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Do you have an account? "),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
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
