import 'package:bookes/resources/auth.dart';
import 'package:bookes/responsive/mobile_screen_layout.dart';
import 'package:bookes/responsive/rsponsive_layout_screen.dart';
import 'package:bookes/responsive/web_screen_layout.dart';
import 'package:bookes/screens/signup_screen.dart';
import 'package:bookes/theme/colors.dart';
import 'package:bookes/widgets/googleSignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  List<String> _employeeUsernames = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email has been sent to $email")),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      // Handling specific errors
      if (e.code == 'invalid-email') {
        message = "The email address is not valid. Please enter a valid email.";
      } else if (e.code == 'user-not-found') {
        message = "No user found with this email address.";
      } else {
        message = "An error occurred. Please try again later.";
      }

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Catch any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred. Please try again.")),
      );
    }
  }


  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              ),
            ),
            (route) => false);

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        // showSnackBar(context, res);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
        backgroundColor: background,
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(),
                flex: 2,
              ),
              //svg image
              // SvgPicture.asset('assets/ic_instegram.svg', color: primaryColor,height:64),
              const SizedBox(height: 64),
              //test fiels input for email
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _employeeUsernames.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    _emailController.text = selection;
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      labelStyle: TextStyle(
                        color: Colors.blue, // Change this to your desired color
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Bottom border color when enabled
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.blue,
                            width:
                                2.0), // Bottom border color when focused, with thicker border
                      ),
                    ),
                    style: TextStyle(
                      color:
                          Colors.white, // Change the input text color to blue
                    ),
                    cursorColor: Colors.blue,
                    onChanged: (value) {
                      _emailController.text = value;
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        width: 330,
                        height: 60, // Adjust this width as needed
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              //old test fiels input for password
              // TextFieldInput(
              //   textEditingController: _passwordController,
              //   hintText: AppLocalizations.of(context)!.enteryourpassword,
              //   textInputType: TextInputType.text,
              //   isPass: true,
              // ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  labelStyle: TextStyle(
                    color: Colors.blue, // Change this to your desired color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Bottom border color when enabled
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width:
                            2.0), // Bottom border color when focused, with thicker border
                  ),
                ),
                style: TextStyle(
                  color: Colors.white, // Change the input text color to blue
                ),
                cursorColor: Colors.blue,
              ),
              const SizedBox(height: 10),
              GestureDetector(
             onTap: ()async {
                  String email = _emailController.text; // Replace with the user's email
          await resetPassword(context,email);
    // Show a confirmation message to the user
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset email has been sent to $email")),
    );
             },
                //authProvider.isLoading ? null :
                child: Container(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      AppLocalizations.of(context)!.forgotpassword,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              InkWell(
                onTap: 
                //authProvider.isLoading ? null : 
                loginUser,
                child: Container(
                  child:
                  //  authProvider.isLoading
                  //     ? const Center(
                  //         child: CircularProgressIndicator(
                  //           color: primaryColor,
                  //         ),
                  //       )
                  //     :
                       Text(
                          AppLocalizations.of(context)!.login,
                          style: TextStyle(
                            color: Colors
                                .white, // Change the input text color to blue
                          ),
                        ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: blueColor),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.or,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              GoogleSignInButton(
                onSignInSuccess: (String token) {
                  // Handle successful sign-in
                  print('Successfully signed in with Google. JWT: ');
                  // TODO: Store the token securely and navigate to the home screen
                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(builder: (context) => GamesScreen()),
                  // );
                },
                onSignInError: (String error) {
                  // Handle sign-in error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                },
              ),

              const SizedBox(height: 12),
              Flexible(
                child: Container(),
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      AppLocalizations.of(context)!.donthaveanaccount,
                      style: TextStyle(
                        color:
                            Colors.white, // Change the input text color to blue
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    ),
                    child: Container(
                      child: Text(
                        AppLocalizations.of(context)!.signup,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                ],
              )
              //transition to sign up
            ],
          ),
        )));
  }
}
