import 'package:bookes/screens/login.dart';
import 'package:bookes/theme/colors.dart';
import 'package:flutter/material.dart';



class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          decoration: InputDecoration(labelText: 'search for user'),
          onFieldSubmitted: (String_) {},
        ),
      ),
      body:
          // Text('dsdsdsdsdsd'),

          Container(
        child: Row(children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              // await AuthMethods().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            child: const Text('Signout'),
          ),
        ]),
      ),
    );
  }
}
