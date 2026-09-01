import 'package:flutter/material.dart';

class CreateHeroScreen extends StatelessWidget {
  const CreateHeroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hero')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
          child: const Text('Continue to Dashboard'),
        ),
      ),
    );
  }
}
