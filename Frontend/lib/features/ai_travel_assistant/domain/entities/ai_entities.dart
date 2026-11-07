import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Ngưỡng độ tin cậy: dưới mức này kết quả chỉ mang tính gợi ý (LI-02).
const double kLowConfidenceThreshold = 0.6;

/// [FE-05] Kết quả nhận diện địa danh từ ảnh.
class LandmarkRecognition extends Equatable {
  const LandmarkRecognition({
    required this.landmarkName,
    required this.confidence,
    required this.description,
    this.destinationId,
    this.relatedDestinationIds = const [],
    this.alternatives = const [],
    this.funFacts = const [],
  });

  final String landmarkName;

  /// 0.0 – 1.0
  final double confidence;
  final String description;
  final String? destinationId;
  final List<String> relatedDestinationIds;
  final List<RecognitionCandidate> alternatives;
  final List<String> funFacts;

  int get confidencePercent => (confidence * 100).round();
  bool get isLowConfidence => confidence < kLowConfidenceThreshold;
  bool get isRecognized => destinationId != null;

  @override
  List<Object?> get props => [landmarkName, confidence, destinationId];
}

class RecognitionCandidate extends Equatable {
  const RecognitionCandidate({required this.name, required this.confidence, this.destinationId});

  final String name;
  final double confidence;
  final String? destinationId;

  @override
  List<Object?> get props => [name, confidence];
}

enum TravelBudget {
  economy('Tiết kiệm', 'Dưới 500.000đ'),
  standard('Vừa phải', '500.000 – 1.500.000đ'),
  premium('Thoải mái', 'Trên 1.500.000đ');

  const TravelBudget(this.label, this.range);
  final String label;
  final String range;
}

enum TravelTransport {
  walking('Đi bộ', Icons.directions_walk_rounded),
  bicycle('Xe đạp', Icons.pedal_bike_rounded),
  motorbike('Xe máy', Icons.two_wheeler_rounded),
  car('Ô tô / Taxi', Icons.local_taxi_rounded);

  const TravelTransport(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Các sở thích để RAG/AI cá nhân hóa lịch trình.
const List<String> kTravelInterests = [
  'Tâm linh & Chùa chiền',
  'Hang động & Leo núi',
  'Làng nghề đá mỹ nghệ',
  'Biển & Thể thao nước',
  'Ẩm thực địa phương',
  'Cuộc sống về đêm',
  'Chụp ảnh check-in',
  'Lịch sử & Văn hóa',
];

/// [FE-05] Yêu cầu sinh lịch trình thông minh.
class ItineraryRequest extends Equatable {
  const ItineraryRequest({
    required this.freeHours,
    required this.startTime,
    required this.budget,
    required this.transport,
    required this.interests,
    this.groupSize = 2,
    this.note = '',
  });

  final int freeHours;
  final TimeOfDay startTime;
  final TravelBudget budget;
  final TravelTransport transport;
  final Set<String> interests;
  final int groupSize;
  final String note;

  Map<String, dynamic> toJson() => {
        'freeHours': freeHours,
        'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'budget': budget.name,
        'transport': transport.name,
        'interests': interests.toList(),
        'groupSize': groupSize,
        'note': note,
        'area': 'ngu_hanh_son',
      };

  @override
  List<Object?> get props => [freeHours, startTime, budget, transport, interests, groupSize, note];
}

enum StopKind {
  sightseeing(Icons.landscape_rounded),
  food(Icons.restaurant_rounded),
  experience(Icons.handyman_rounded),
  beach(Icons.beach_access_rounded),
  rest(Icons.local_cafe_rounded);

  const StopKind(this.icon);
  final IconData icon;
}

/// Một chặng trong lịch trình (hiển thị dạng Timeline).
class ItineraryStop extends Equatable {
  const ItineraryStop({
    required this.time,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.kind,
    this.estimatedCost = 0,
    this.destinationId,
    this.travelNote,
  });

  final String time;
  final String title;
  final String description;
  final int durationMinutes;
  final StopKind kind;
  final int estimatedCost;
  final String? destinationId;
  final String? travelNote;

  @override
  List<Object?> get props => [time, title];
}

class GeneratedItinerary extends Equatable {
  const GeneratedItinerary({
    required this.title,
    required this.summary,
    required this.stops,
    required this.tips,
    required this.sources,
  });

  final String title;
  final String summary;
  final List<ItineraryStop> stops;
  final List<String> tips;

  /// Nguồn tri thức RAG đã truy xuất (minh bạch nguồn tham khảo).
  final List<String> sources;

  int get totalCost => stops.fold(0, (sum, s) => sum + s.estimatedCost);
  int get totalMinutes => stops.fold(0, (sum, s) => sum + s.durationMinutes);

  @override
  List<Object?> get props => [title, stops];
}

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.role,
    required this.text,
    required this.createdAt,
    this.sources = const [],
    this.suggestions = const [],
  });

  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final List<String> sources;
  final List<String> suggestions;

  bool get isUser => role == ChatRole.user;

  @override
  List<Object?> get props => [role, text, createdAt];
}
