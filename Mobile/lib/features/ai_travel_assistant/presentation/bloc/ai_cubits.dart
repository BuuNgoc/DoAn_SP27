import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/usecases/ai_usecases.dart';

// ─────────────────────────── Nhận diện ảnh ───────────────────────────

class AiScanState extends Equatable {
  const AiScanState({this.status = ViewStatus.initial, this.imageBytes, this.result, this.errorMessage});

  final ViewStatus status;
  final Uint8List? imageBytes;
  final LandmarkRecognition? result;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, imageBytes, result, errorMessage];
}

/// [FE-05] Nhận diện địa danh từ ảnh chụp/tải lên.
class AiScanCubit extends Cubit<AiScanState> {
  AiScanCubit(this._recognize) : super(const AiScanState());

  final RecognizeLandmarkUseCase _recognize;

  void setImage(Uint8List bytes) => emit(AiScanState(imageBytes: bytes));

  Future<void> analyze() async {
    final bytes = state.imageBytes;
    if (bytes == null) return;
    emit(AiScanState(status: ViewStatus.loading, imageBytes: bytes));
    try {
      final result = await _recognize(bytes);
      emit(AiScanState(status: ViewStatus.success, imageBytes: bytes, result: result));
    } catch (e) {
      emit(AiScanState(status: ViewStatus.failure, imageBytes: bytes, errorMessage: errorMessageOf(e)));
    }
  }

  void reset() => emit(const AiScanState());
}

// ─────────────────────────── Lịch trình RAG ───────────────────────────

class ItineraryState extends Equatable {
  const ItineraryState({this.status = ViewStatus.initial, this.itinerary, this.request, this.errorMessage});

  final ViewStatus status;
  final GeneratedItinerary? itinerary;
  final ItineraryRequest? request;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, itinerary, request, errorMessage];
}

class ItineraryCubit extends Cubit<ItineraryState> {
  ItineraryCubit(this._generate) : super(const ItineraryState());

  final GenerateItineraryUseCase _generate;

  Future<void> generate(ItineraryRequest request) async {
    emit(ItineraryState(status: ViewStatus.loading, request: request));
    try {
      final itinerary = await _generate(request);
      emit(ItineraryState(status: ViewStatus.success, itinerary: itinerary, request: request));
    } catch (e) {
      emit(ItineraryState(status: ViewStatus.failure, request: request, errorMessage: errorMessageOf(e)));
    }
  }

  void edit() => emit(ItineraryState(request: state.request));
}

// ─────────────────────────── Trò chuyện AI ───────────────────────────

class AiChatState extends Equatable {
  const AiChatState({this.messages = const [], this.isTyping = false, this.errorMessage});

  final List<ChatMessage> messages;
  final bool isTyping;
  final String? errorMessage;

  @override
  List<Object?> get props => [messages, isTyping, errorMessage];
}

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit(this._send)
      : super(AiChatState(messages: [
          ChatMessage(
            role: ChatRole.assistant,
            text: 'Xin chào! Mình là trợ lý du lịch SmartTravel 👋\n'
                'Bạn cần gợi ý lịch trình, giá vé, ẩm thực hay lưu ý an toàn khi tham quan Ngũ Hành Sơn?',
            createdAt: DateTime.now(),
            suggestions: const ['Giá vé Ngũ Hành Sơn', 'Gợi ý món ăn', 'Lưu ý tắm biển', 'Workshop làng đá'],
          ),
        ]));

  final SendChatMessageUseCase _send;

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.isTyping) return;
    final userMessage = ChatMessage(role: ChatRole.user, text: text.trim(), createdAt: DateTime.now());
    final history = [...state.messages, userMessage];
    emit(AiChatState(messages: history, isTyping: true));
    try {
      final reply = await _send(history, text);
      emit(AiChatState(messages: [...history, reply]));
    } catch (e) {
      emit(AiChatState(messages: history, errorMessage: errorMessageOf(e)));
    }
  }
}
