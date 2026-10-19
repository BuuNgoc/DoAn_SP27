import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// [FE-01] Screen: Authentication (Register, Login, Reset/Change Password, Profile)
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'FE-01: Auth',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.travel_explore, size: 64, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                'Authentication (Register, Login, Reset/Change Password, Profile)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Mô-đun đang trong quá trình kết nối dữ liệu Firestore.'),
            ],
          ),
        ),
      ),
    );
  }
}
