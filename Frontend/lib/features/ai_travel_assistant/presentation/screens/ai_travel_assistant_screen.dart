import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// [FE-05 & RAG] Screen: AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
class AiTravelAssistantScreen extends StatelessWidget {
  const AiTravelAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'FE-05 & RAG: Ai Travel Assistant',
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
                'AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)',
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
