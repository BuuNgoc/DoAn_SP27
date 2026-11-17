import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_travel_app/features/ai_travel_assistant/data/datasources/ai_remote_data_source.dart';
import 'package:smart_travel_app/features/ai_travel_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:smart_travel_app/features/ai_travel_assistant/domain/entities/ai_entities.dart';
import 'package:smart_travel_app/features/ai_travel_assistant/domain/usecases/ai_usecases.dart';

void main() {
  group('FE-05 LocalOnDeviceAiDataSource Tests (No 3rd-party API)', () {
    late LocalOnDeviceAiDataSource dataSource;

    setUp(() {
      dataSource = const LocalOnDeviceAiDataSource();
    });

    test('recognizeLandmark returns valid landmark recognition with high confidence', () async {
      final fakeImageBytes = Uint8List.fromList(List.generate(1024, (i) => i % 256));
      final result = await dataSource.recognizeLandmark(fakeImageBytes);

      expect(result.landmarkName, isNotEmpty);
      expect(result.confidence, greaterThan(0.5));
      expect(result.description, isNotEmpty);
      expect(result.destinationId, isNotNull);
      expect(result.confidencePercent, inInclusiveRange(50, 100));
    });

    test('recognizeLandmark handles empty image gracefully with fallback disclaimer', () async {
      final emptyBytes = Uint8List(0);
      final result = await dataSource.recognizeLandmark(emptyBytes);

      expect(result.landmarkName, contains('Ngũ Hành Sơn'));
      expect(result.isLowConfidence, isTrue);
      expect(result.funFacts, isNotEmpty);
    });

    test('generateItinerary creates balanced stops respecting time and interests constraints', () async {
      const request = ItineraryRequest(
        freeHours: 4,
        startTime: TimeOfDay(hour: 9, minute: 0),
        budget: TravelBudget.standard,
        transport: TravelTransport.walking,
        interests: {'Hang động & Leo núi', 'Tâm linh & Chùa chiền'},
        groupSize: 2,
      );

      final itinerary = await dataSource.generateItinerary(request);

      expect(itinerary.title, contains('4 giờ'));
      expect(itinerary.stops, isNotEmpty);
      expect(itinerary.stops.length, greaterThanOrEqualTo(2));
      expect(itinerary.tips, isNotEmpty);
      expect(itinerary.sources, isNotEmpty);
      expect(itinerary.totalCost, greaterThan(0));
    });

    test('generateItinerary scales cost according to group size and budget tier', () async {
      const ecoRequest = ItineraryRequest(
        freeHours: 3,
        startTime: TimeOfDay(hour: 8, minute: 0),
        budget: TravelBudget.economy,
        transport: TravelTransport.walking,
        interests: {'Hang động & Leo núi'},
        groupSize: 1,
      );

      const premiumRequest = ItineraryRequest(
        freeHours: 3,
        startTime: TimeOfDay(hour: 8, minute: 0),
        budget: TravelBudget.premium,
        transport: TravelTransport.car,
        interests: {'Hang động & Leo núi'},
        groupSize: 4,
      );

      final ecoItinerary = await dataSource.generateItinerary(ecoRequest);
      final premItinerary = await dataSource.generateItinerary(premiumRequest);

      expect(premItinerary.totalCost, greaterThan(ecoItinerary.totalCost));
    });

    test('chat returns accurate local responses for ticket and schedule queries', () async {
      final replyTicket = await dataSource.chat([], 'Giá vé tham quan Ngũ Hành Sơn bao nhiêu?');
      expect(replyTicket.text, contains('40.000đ'));
      expect(replyTicket.role, equals(ChatRole.assistant));
      expect(replyTicket.suggestions, isNotEmpty);

      final replyHours = await dataSource.chat([], 'Mấy giờ mở cửa và đóng cửa?');
      expect(replyHours.text, contains('07:00 đến 17:30'));
    });
  });

  group('FE-05 AiAssistantRepository & UseCases Tests', () {
    late LocalOnDeviceAiDataSource dataSource;
    late AiAssistantRepositoryImpl repository;
    late RecognizeLandmarkUseCase recognizeUseCase;
    late GenerateItineraryUseCase itineraryUseCase;

    setUp(() {
      dataSource = const LocalOnDeviceAiDataSource();
      repository = AiAssistantRepositoryImpl(dataSource);
      recognizeUseCase = RecognizeLandmarkUseCase(repository);
      itineraryUseCase = GenerateItineraryUseCase(repository);
    });

    test('RecognizeLandmarkUseCase returns LandmarkRecognition successfully', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await recognizeUseCase(fakeBytes);

      expect(result.landmarkName, isNotEmpty);
      expect(result.confidence, greaterThan(0.0));
      expect(result.destinationId, isNotNull);
    });

    test('GenerateItineraryUseCase returns GeneratedItinerary successfully', () async {
      const request = ItineraryRequest(
        freeHours: 2,
        startTime: TimeOfDay(hour: 14, minute: 0),
        budget: TravelBudget.economy,
        transport: TravelTransport.bicycle,
        interests: {'Biển & Thể thao nước'},
      );

      final result = await itineraryUseCase(request);

      expect(result.title, contains('2 giờ'));
      expect(result.stops, isNotEmpty);
    });

    test('GenerateItineraryUseCase throws ArgumentError when interests are empty', () async {
      const emptyInterestsRequest = ItineraryRequest(
        freeHours: 2,
        startTime: TimeOfDay(hour: 14, minute: 0),
        budget: TravelBudget.economy,
        transport: TravelTransport.bicycle,
        interests: {},
      );

      expect(() => itineraryUseCase(emptyInterestsRequest), throwsArgumentError);
    });
  });
}
