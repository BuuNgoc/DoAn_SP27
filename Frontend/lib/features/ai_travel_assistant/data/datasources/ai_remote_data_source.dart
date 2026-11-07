import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ai_entities.dart';

/// [FE-05] Nguồn dữ liệu AI.
abstract class AiRemoteDataSource {
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes);
  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request);
  Future<ChatMessage> chat(List<ChatMessage> history, String message);
}

/// Gọi Cloud Functions: `analyzeLandmarkImage`, `generateRagItinerary`, `aiTravelChat`.
class CloudFunctionsAiRemoteDataSource implements AiRemoteDataSource {
  CloudFunctionsAiRemoteDataSource([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> _call(String name, Map<String, dynamic> data) async {
    try {
      final result = await _functions
          .httpsCallable(name, options: HttpsCallableOptions(timeout: const Duration(seconds: 60)))
          .call<Map<String, dynamic>>(data);
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(e.message ?? 'Dịch vụ AI tạm thời gián đoạn.', code: e.code);
    }
  }

  @override
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes) async {
    final json = await _call('analyzeLandmarkImage', {'imageBase64': base64Encode(imageBytes)});
    return LandmarkRecognition(
      landmarkName: (json['landmarkName'] ?? 'Không xác định').toString(),
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      description: (json['description'] ?? '').toString(),
      destinationId: json['destinationId']?.toString(),
      relatedDestinationIds: List<String>.from(json['relatedDestinationIds'] ?? const []),
      alternatives: [
        for (final a in (json['alternatives'] as List? ?? const []))
          RecognitionCandidate(
            name: (a['name'] ?? '').toString(),
            confidence: (a['confidence'] as num? ?? 0).toDouble(),
            destinationId: a['destinationId']?.toString(),
          ),
      ],
      funFacts: List<String>.from(json['funFacts'] ?? const []),
    );
  }

  @override
  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request) async {
    final json = await _call('generateRagItinerary', request.toJson());
    return GeneratedItinerary(
      title: (json['title'] ?? 'Lịch trình của bạn').toString(),
      summary: (json['summary'] ?? '').toString(),
      tips: List<String>.from(json['tips'] ?? const []),
      sources: List<String>.from(json['sources'] ?? const []),
      stops: [
        for (final s in (json['stops'] as List? ?? const []))
          ItineraryStop(
            time: (s['time'] ?? '').toString(),
            title: (s['title'] ?? '').toString(),
            description: (s['description'] ?? '').toString(),
            durationMinutes: (s['durationMinutes'] as num? ?? 60).toInt(),
            kind: StopKind.values.firstWhere((k) => k.name == s['kind'], orElse: () => StopKind.sightseeing),
            estimatedCost: (s['estimatedCost'] as num? ?? 0).toInt(),
            destinationId: s['destinationId']?.toString(),
            travelNote: s['travelNote']?.toString(),
          ),
      ],
    );
  }

  @override
  Future<ChatMessage> chat(List<ChatMessage> history, String message) async {
    final json = await _call('aiTravelChat', {
      'message': message,
      'history': [
        for (final m in history.take(20)) {'role': m.role.name, 'text': m.text},
      ],
    });
    return ChatMessage(
      role: ChatRole.assistant,
      text: (json['reply'] ?? '').toString(),
      createdAt: DateTime.now(),
      sources: List<String>.from(json['sources'] ?? const []),
      suggestions: List<String>.from(json['suggestions'] ?? const []),
    );
  }
}

/// Mô phỏng phản hồi AI/RAG cho bản demo chạy không cần backend.
class MockAiRemoteDataSource implements AiRemoteDataSource {
  static const _landmarks = [
    LandmarkRecognition(
      landmarkName: 'Động Huyền Không',
      confidence: 0.94,
      destinationId: 'dong_huyen_khong',
      description:
          'Hang động lớn nhất trên núi Thủy Sơn, nổi tiếng với những cột nắng chiếu xuyên qua khe đá. '
          'Trong động có tượng Phật Thích Ca và nhiều bia ký Ma nhai thời Nguyễn.',
      relatedDestinationIds: ['ngu_hanh_son', 'chua_linh_ung_non_nuoc', 'dong_am_phu'],
      alternatives: [
        RecognitionCandidate(name: 'Động Âm Phủ', confidence: 0.04, destinationId: 'dong_am_phu'),
        RecognitionCandidate(name: 'Động Tàng Chơn', confidence: 0.02),
      ],
      funFacts: [
        'Ánh nắng đẹp nhất trong động thường vào khoảng 9 – 11 giờ sáng.',
        'Vách động lưu giữ nhiều bia ký thuộc hệ thống Ma nhai được UNESCO ghi danh.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Chùa Linh Ứng Non Nước',
      confidence: 0.88,
      destinationId: 'chua_linh_ung_non_nuoc',
      description:
          'Ngôi chùa cổ trên núi Thủy Sơn, từng được vua Minh Mạng ban biển ngạch. '
          'Từ sân chùa có thể phóng tầm mắt ra biển Non Nước.',
      relatedDestinationIds: ['ngu_hanh_son', 'chua_tam_thai', 'dong_huyen_khong'],
      alternatives: [
        RecognitionCandidate(name: 'Chùa Tam Thai', confidence: 0.09, destinationId: 'chua_tam_thai'),
      ],
      funFacts: ['Chùa còn được gọi là “Ứng Chơn”, gắn với nhiều sự tích linh ứng của dân gian xứ Quảng.'],
    ),
    LandmarkRecognition(
      landmarkName: 'Làng đá mỹ nghệ Non Nước',
      confidence: 0.81,
      destinationId: 'lang_da_non_nuoc',
      description:
          'Làng nghề điêu khắc đá truyền thống hơn 400 năm tuổi dưới chân Ngũ Hành Sơn, '
          'nổi tiếng với tượng Phật, linh vật và đồ lưu niệm bằng đá cẩm thạch.',
      relatedDestinationIds: ['ngu_hanh_son', 'bai_bien_non_nuoc'],
      alternatives: [RecognitionCandidate(name: 'Xưởng điêu khắc đá tư nhân', confidence: 0.12)],
      funFacts: ['Làng đá Non Nước được công nhận là Di sản văn hóa phi vật thể quốc gia.'],
    ),
    LandmarkRecognition(
      landmarkName: 'Bãi biển Sơn Thủy',
      confidence: 0.76,
      destinationId: 'bai_bien_son_thuy',
      description: 'Bãi biển có cát trắng mịn, sóng êm, cứu hộ thường trực và nhiều hoạt động thể thao biển.',
      relatedDestinationIds: ['bai_bien_non_nuoc', 'pho_an_thuong'],
      alternatives: [
        RecognitionCandidate(name: 'Bãi biển Non Nước', confidence: 0.15, destinationId: 'bai_bien_non_nuoc'),
        RecognitionCandidate(name: 'Bãi biển Mỹ Khê', confidence: 0.07),
      ],
      funFacts: ['Nên tắm biển trong khung giờ có cứu hộ: 05:00 – 18:00.'],
    ),
    LandmarkRecognition(
      landmarkName: 'Có thể là: Danh thắng Ngũ Hành Sơn',
      confidence: 0.52,
      destinationId: 'ngu_hanh_son',
      description:
          'Ảnh có đặc điểm núi đá vôi và cây xanh tương tự quần thể Ngũ Hành Sơn, '
          'nhưng góc chụp chưa đủ rõ để khẳng định chính xác.',
      relatedDestinationIds: ['dong_huyen_khong', 'chua_linh_ung_non_nuoc'],
      alternatives: [
        RecognitionCandidate(name: 'Núi Thủy Sơn', confidence: 0.28, destinationId: 'ngu_hanh_son'),
        RecognitionCandidate(name: 'Bán đảo Sơn Trà', confidence: 0.12),
      ],
      funFacts: ['Hãy chụp lại ở nơi đủ sáng, lấy trọn chủ thể để kết quả chính xác hơn.'],
    ),
  ];

  @override
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    final hash = imageBytes.isEmpty ? 0 : imageBytes.length + imageBytes[imageBytes.length ~/ 2];
    return _landmarks[hash % _landmarks.length];
  }

  @override
  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    return _ItineraryComposer(request).compose();
  }

  @override
  Future<ChatMessage> chat(List<ChatMessage> history, String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final q = message.toLowerCase();
    String reply;
    var sources = <String>['Cẩm nang SmartTravel – Ngũ Hành Sơn'];
    var suggestions = <String>[];

    if (q.contains('vé') || q.contains('giá')) {
      reply = 'Vé tham quan núi Thủy Sơn hiện khoảng 40.000đ/người, thang máy 15.000đ/lượt (giá tham khảo). '
          'Động Huyền Không, chùa Linh Ứng đã nằm trong vé núi Thủy Sơn; riêng Động Âm Phủ có vé riêng.';
      sources = ['Ban Quản lý Danh thắng Ngũ Hành Sơn (dữ liệu mẫu)'];
      suggestions = ['Giờ mở cửa?', 'Có thang máy không?'];
    } else if (q.contains('giờ') || q.contains('mở cửa')) {
      reply = 'Danh thắng mở cửa từ 07:00 đến 17:30 hằng ngày. Bạn nên đến trước 9 giờ để tránh nắng '
          'và kịp ngắm cột nắng trong Động Huyền Không vào khoảng 9 – 11 giờ.';
      suggestions = ['Gợi ý lịch trình nửa ngày', 'Nên mặc gì khi đi chùa?'];
    } else if (q.contains('ăn') || q.contains('quán') || q.contains('ẩm thực')) {
      reply = 'Gần Ngũ Hành Sơn bạn có thể thử mì Quảng, bánh tráng cuốn thịt heo, bún chả cá. '
          'Buổi tối, khu phố An Thượng có nhiều lựa chọn ẩm thực quốc tế và quán cà phê sôi động.';
      suggestions = ['Khám phá An Thượng', 'Quán hải sản gần biển?'];
    } else if (q.contains('biển') || q.contains('tắm')) {
      reply = 'Bãi biển Sơn Thủy và Non Nước có cứu hộ từ 05:00 đến 18:00. Hãy tắm trong khu vực cắm cờ, '
          'không bơi xa khi có cờ đỏ và chú ý dòng chảy xa bờ vào buổi chiều.';
      sources = ['Thông tin an toàn bãi biển – SmartTravel'];
      suggestions = ['Hoạt động thể thao biển', 'Bãi biển nào vắng người?'];
    } else if (q.contains('đá') || q.contains('workshop') || q.contains('làng')) {
      reply = 'Làng đá mỹ nghệ Non Nước có workshop điêu khắc đá mini khoảng 90 phút, tự tay chạm khắc '
          'móc khóa hoặc tượng nhỏ cùng nghệ nhân. Bạn có thể đặt chỗ ngay trong mục Sự kiện & Workshop.';
      suggestions = ['Xem workshop', 'Mua đồ lưu niệm ở đâu?'];
    } else {
      reply = 'Mình là trợ lý du lịch SmartTravel. Mình có thể gợi ý lịch trình, giờ mở cửa, giá vé, '
          'ẩm thực và lưu ý an toàn khi tham quan Ngũ Hành Sơn. Bạn muốn tìm hiểu điều gì?';
      suggestions = ['Giá vé Ngũ Hành Sơn', 'Gợi ý món ăn', 'Lưu ý tắm biển'];
    }
    return ChatMessage(
      role: ChatRole.assistant,
      text: reply,
      createdAt: DateTime.now(),
      sources: sources,
      suggestions: suggestions,
    );
  }
}

class _Candidate {
  const _Candidate(this.stop, this.interests, {this.order = 50});
  final ItineraryStop stop;
  final Set<String> interests;
  final int order;
}

/// Bộ ghép lịch trình mô phỏng quy trình RAG (truy xuất → xếp hạng → sắp xếp theo thời gian).
class _ItineraryComposer {
  _ItineraryComposer(this.request);

  final ItineraryRequest request;

  static const _pool = [
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Leo núi Thủy Sơn & Vọng Giang Đài',
        description: 'Đi thang máy hoặc leo 156 bậc đá, ngắm toàn cảnh biển Non Nước từ Vọng Giang Đài.',
        durationMinutes: 60,
        kind: StopKind.sightseeing,
        estimatedCost: 55000,
        destinationId: 'ngu_hanh_son',
      ),
      {'Hang động & Leo núi', 'Chụp ảnh check-in', 'Lịch sử & Văn hóa'},
      order: 10,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Khám phá Động Huyền Không',
        description: 'Chiêm ngưỡng cột nắng tự nhiên, tượng Phật Thích Ca và bia ký Ma nhai.',
        durationMinutes: 45,
        kind: StopKind.sightseeing,
        destinationId: 'dong_huyen_khong',
      ),
      {'Hang động & Leo núi', 'Tâm linh & Chùa chiền', 'Chụp ảnh check-in', 'Lịch sử & Văn hóa'},
      order: 20,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Viếng chùa Linh Ứng Non Nước',
        description: 'Ngôi chùa cổ trên núi, không gian thanh tịnh, nhìn ra biển Đông.',
        durationMinutes: 40,
        kind: StopKind.sightseeing,
        destinationId: 'chua_linh_ung_non_nuoc',
      ),
      {'Tâm linh & Chùa chiền', 'Lịch sử & Văn hóa'},
      order: 25,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Chùa Tam Thai & Động Âm Phủ',
        description: 'Tìm hiểu truyền thuyết cõi âm và kiến trúc chùa Tam Thai thời Minh Mạng.',
        durationMinutes: 60,
        kind: StopKind.sightseeing,
        estimatedCost: 20000,
        destinationId: 'dong_am_phu',
      ),
      {'Tâm linh & Chùa chiền', 'Hang động & Leo núi', 'Lịch sử & Văn hóa'},
      order: 30,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Workshop điêu khắc đá tại Làng đá Non Nước',
        description: 'Tự tay chạm khắc móc khóa đá cẩm thạch cùng nghệ nhân, mang sản phẩm về làm kỷ niệm.',
        durationMinutes: 90,
        kind: StopKind.experience,
        estimatedCost: 250000,
        destinationId: 'lang_da_non_nuoc',
      ),
      {'Làng nghề đá mỹ nghệ', 'Lịch sử & Văn hóa', 'Chụp ảnh check-in'},
      order: 40,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Tắm biển & chèo SUP tại Sơn Thủy',
        description: 'Thư giãn trên bãi cát trắng, thử chèo SUP hoặc kayak trong khu vực có cứu hộ.',
        durationMinutes: 90,
        kind: StopKind.beach,
        estimatedCost: 150000,
        destinationId: 'bai_bien_son_thuy',
      ),
      {'Biển & Thể thao nước', 'Chụp ảnh check-in'},
      order: 60,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Cà phê hoàng hôn bên biển Non Nước',
        description: 'Nghỉ chân với ly cà phê muối, ngắm hoàng hôn buông xuống sau dãy Ngũ Hành Sơn.',
        durationMinutes: 45,
        kind: StopKind.rest,
        estimatedCost: 50000,
        destinationId: 'bai_bien_non_nuoc',
      ),
      {'Biển & Thể thao nước', 'Chụp ảnh check-in', 'Ẩm thực địa phương'},
      order: 70,
    ),
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Dạo phố Tây An Thượng về đêm',
        description: 'Thưởng thức ẩm thực đường phố, nhạc sống và không khí quốc tế sôi động.',
        durationMinutes: 120,
        kind: StopKind.food,
        estimatedCost: 300000,
        destinationId: 'pho_an_thuong',
      ),
      {'Cuộc sống về đêm', 'Ẩm thực địa phương'},
      order: 90,
    ),
  ];

  GeneratedItinerary compose() {
    final budgetFactor = switch (request.budget) {
      TravelBudget.economy => 0.7,
      TravelBudget.standard => 1.0,
      TravelBudget.premium => 1.6,
    };
    final travelNote = switch (request.transport) {
      TravelTransport.walking => 'Đi bộ khoảng 10 – 15 phút',
      TravelTransport.bicycle => 'Đạp xe khoảng 8 phút',
      TravelTransport.motorbike => 'Xe máy khoảng 5 phút',
      TravelTransport.car => 'Taxi khoảng 5 phút',
    };

    final scored = [..._pool]..sort((a, b) {
        final sa = a.interests.intersection(request.interests).length;
        final sb = b.interests.intersection(request.interests).length;
        return sb.compareTo(sa);
      });

    final budgetMinutes = request.freeHours * 60;
    final chosen = <_Candidate>[];
    var used = 0;
    for (final c in scored) {
      if (c.interests.intersection(request.interests).isEmpty && chosen.length >= 2) continue;
      final cost = c.stop.durationMinutes + 15;
      if (used + cost > budgetMinutes) continue;
      chosen.add(c);
      used += cost;
    }
    chosen.sort((a, b) => a.order.compareTo(b.order));

    var minutes = request.startTime.hour * 60 + request.startTime.minute;
    final stops = <ItineraryStop>[];
    var mealAdded = false;
    for (var i = 0; i < chosen.length; i++) {
      final s = chosen[i].stop;
      if (!mealAdded && minutes >= 11 * 60 && minutes <= 13 * 60 && request.freeHours >= 4) {
        stops.add(ItineraryStop(
          time: _fmt(minutes),
          title: 'Ăn trưa mì Quảng & bánh tráng cuốn thịt heo',
          description: 'Quán ăn địa phương gần chân núi, hương vị đậm đà xứ Quảng.',
          durationMinutes: 45,
          kind: StopKind.food,
          estimatedCost: (60000 * budgetFactor * request.groupSize).round(),
          travelNote: travelNote,
        ));
        minutes += 60;
        mealAdded = true;
      }
      stops.add(ItineraryStop(
        time: _fmt(minutes),
        title: s.title,
        description: s.description,
        durationMinutes: s.durationMinutes,
        kind: s.kind,
        estimatedCost: (s.estimatedCost * budgetFactor * request.groupSize).round(),
        destinationId: s.destinationId,
        travelNote: i == 0 ? null : travelNote,
      ));
      minutes += s.durationMinutes + 15;
    }

    final interestsText = request.interests.take(3).join(', ').toLowerCase();
    return GeneratedItinerary(
      title: 'Lịch trình ${request.freeHours} giờ khám phá Ngũ Hành Sơn',
      summary: 'Lịch trình được cá nhân hóa theo sở thích $interestsText, ngân sách '
          '${request.budget.label.toLowerCase()} cho ${request.groupSize} người, di chuyển bằng '
          '${request.transport.label.toLowerCase()}.',
      stops: stops,
      tips: [
        'Mang giày đế bám và nước uống khi leo núi Thủy Sơn.',
        'Ăn mặc kín đáo khi vào chùa và hang động có thờ tự.',
        if (request.interests.contains('Biển & Thể thao nước'))
          'Chỉ tắm biển trong khu vực có cờ và cứu hộ (05:00 – 18:00).',
        'Quét mã QR tại các điểm check-in để tích điểm đổi quà lưu niệm.',
      ],
      sources: const [
        'Cơ sở tri thức điểm đến SmartTravel (destinations)',
        'Lịch sự kiện & workshop Ngũ Hành Sơn (events_workshops)',
        'Đánh giá du khách đã kiểm duyệt (reviews)',
      ],
    );
  }

  String _fmt(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

/// Bộ chọn nguồn dữ liệu theo cấu hình.
AiRemoteDataSource createAiRemoteDataSource() =>
    AppConfig.useMockBackend ? MockAiRemoteDataSource() : CloudFunctionsAiRemoteDataSource();
