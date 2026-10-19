import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// [FE-06, FE-15, FE-16] Screen: Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
class EventsWorkshopsCraftScreen extends StatelessWidget {
  const EventsWorkshopsCraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'FE-06, FE-15, FE-16: Events Workshops Craft',
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
                'Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting',
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
