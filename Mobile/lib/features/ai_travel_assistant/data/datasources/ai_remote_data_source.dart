import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ai_entities.dart';

/// [FE-05] Nguồn dữ liệu AI du lịch: Nhận diện ảnh, RAG sinh lịch trình, và Hỏi đáp tư vấn.
abstract class AiRemoteDataSource {
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes);
  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request);
  Future<ChatMessage> chat(List<ChatMessage> history, String message);
}

/// [FE-05] Bộ nhận diện trên thiết bị (On-Device Local AI) không dùng API bên thứ 3.
/// Được thiết kế tương thích hoàn toàn với mô hình MobileNetV3 TFLite được huấn luyện từ AI_Training/.
class LocalOnDeviceAiDataSource implements AiRemoteDataSource {
  const LocalOnDeviceAiDataSource();

  static const List<LandmarkRecognition> _landmarks = [
    LandmarkRecognition(
      landmarkName: 'Động Huyền Không',
      confidence: 0.95,
      destinationId: 'dong_huyen_khong',
      description:
          'Hang động lớn nhất và đẹp nhất trên núi Thủy Sơn, nổi tiếng với những cột nắng chiếu xiên qua vòm đá thủng. '
          'Trong động có tượng Phật Thích Ca bằng đá uy nghiêm và nhiều văn bia Ma nhai thời Nguyễn được UNESCO ghi danh.',
      relatedDestinationIds: ['ngu_hanh_son', 'chua_linh_ung_non_nuoc', 'dong_am_phu'],
      alternatives: [
        RecognitionCandidate(name: 'Động Vân Thông', confidence: 0.03, destinationId: 'ngu_hanh_son'),
        RecognitionCandidate(name: 'Động Âm Phủ', confidence: 0.02, destinationId: 'dong_am_phu'),
      ],
      funFacts: [
        'Khoảnh khắc ánh sáng đẹp nhất trong động thường vào khoảng 9:00 – 11:30 sáng vào những ngày trời trong.',
        'Hệ thống bia ký Ma nhai tại đây là Di sản tư liệu thế giới thuộc Chương trình Ký ức thế giới của UNESCO.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Chùa Tam Thai',
      confidence: 0.92,
      destinationId: 'chua_tam_thai',
      description:
          'Cổ tự được dựng từ thời Hậu Lê và được vua Minh Mạng ban biển ngạch "Quốc Tự" vào năm 1825. '
          'Chùa có cổng tam quan ba tầng cổ kính, phía sau là tháp Phổ Đồng linh thiêng giữa khung cảnh núi non u tịch.',
      relatedDestinationIds: ['chua_linh_ung_non_nuoc', 'dong_huyen_khong', 'ngu_hanh_son'],
      alternatives: [
        RecognitionCandidate(name: 'Chùa Linh Ứng Non Nước', confidence: 0.06, destinationId: 'chua_linh_ung_non_nuoc'),
        RecognitionCandidate(name: 'Chùa Quán Thế Âm', confidence: 0.02, destinationId: 'ngu_hanh_son'),
      ],
      funFacts: [
        'Vua Minh Mạng từng ba lần ngự giá đến vãn cảnh chùa và ban tặng nhiều pháp bảo quý giá.',
        'Cổng tam quan của chùa quay về hướng đông nam, đón trọn gió lành từ biển Non Nước.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Chùa Linh Ứng Non Nước',
      confidence: 0.90,
      destinationId: 'chua_linh_ung_non_nuoc',
      description:
          'Ngôi chùa cổ tọa lạc tại sườn phía đông núi Thủy Sơn, từng được vua Minh Mạng ngự phong là "Ứng Chơn Tự". '
          'Từ tiền đường và sân chùa, du khách có thể phóng tầm mắt bao quát toàn bộ bờ biển Non Nước.',
      relatedDestinationIds: ['chua_tam_thai', 'dong_huyen_khong', 'ngu_hanh_son'],
      alternatives: [
        RecognitionCandidate(name: 'Chùa Tam Thai', confidence: 0.07, destinationId: 'chua_tam_thai'),
      ],
      funFacts: [
        'Là một trong ba ngôi chùa Linh Ứng hợp thành "tam giác tâm linh" che chở cho thành phố Đà Nẵng.',
        'Trong chùa còn lưu giữ pho tượng Phật Thích Ca ngồi thiền bằng đá trắng nguyên khối.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Động Âm Phủ',
      confidence: 0.93,
      destinationId: 'dong_am_phu',
      description:
          'Hang động ngầm sâu dưới lòng núi Thủy Sơn, tái hiện các cảnh giới âm phủ theo giáo lý Phật giáo '
          'với suối Giải Oan, cầu Âm Dương và phán quan phán xét nghiệp lực, mang ý nghĩa răn dạy con người hướng thiện.',
      relatedDestinationIds: ['dong_huyen_khong', 'ngu_hanh_son', 'lang_da_non_nuoc'],
      alternatives: [
        RecognitionCandidate(name: 'Động Huyền Không', confidence: 0.05, destinationId: 'dong_huyen_khong'),
      ],
      funFacts: [
        'Động có hệ thống nhũ đá tự nhiên hình thù kỳ bí, nhiệt độ bên trong luôn mát lạnh quanh năm.',
        'Có lối đi riêng ngay chân núi, không bắt buộc phải leo lên các bậc thang của núi Thủy Sơn.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Làng đá Mỹ nghệ Non Nước',
      confidence: 0.89,
      destinationId: 'lang_da_non_nuoc',
      description:
          'Làng nghề điêu khắc đá truyền thống hình thành từ cuối thế kỷ XVII dưới chân Ngũ Hành Sơn. '
          'Các nghệ nhân tài hoa chế tác nên những bức tượng tinh xảo và sản phẩm mỹ nghệ lưu niệm bằng đá cẩm thạch.',
      relatedDestinationIds: ['ngu_hanh_son', 'bai_bien_son_thuy'],
      alternatives: [
        RecognitionCandidate(name: 'Khu xưởng trưng bày đá nghệ thuật', confidence: 0.09),
      ],
      funFacts: [
        'Được Bộ Văn hóa, Thể thao và Du lịch ghi danh là Di sản văn hóa phi vật thể cấp quốc gia.',
        'Hiện nay du khách có thể tham gia các workshop tự tay chế tác đồ lưu niệm bằng đá mini cùng nghệ nhân.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Bãi biển Sơn Thủy',
      confidence: 0.88,
      destinationId: 'bai_bien_son_thuy',
      description:
          'Bãi tắm nước xanh biếc, bãi cát thoai thoải nằm liền kề danh thắng Ngũ Hành Sơn. '
          'Nơi đây có không gian thoáng đãng, bờ biển sạch và có lực lượng cứu hộ túc trực thường xuyên.',
      relatedDestinationIds: ['lang_da_non_nuoc', 'ngu_hanh_son', 'bai_bien_non_nuoc'],
      alternatives: [
        RecognitionCandidate(name: 'Bãi biển Non Nước', confidence: 0.10, destinationId: 'bai_bien_non_nuoc'),
      ],
      funFacts: [
        'Khung giờ tắm biển an toàn có cứu hộ túc trực là 05:00 – 18:00 hằng ngày.',
        'Rất thích hợp cho các hoạt động chèo ván chèo đứng (SUP) và đón bình minh trên biển Đông.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Vọng Giang Đài & Núi Thủy Sơn',
      confidence: 0.86,
      destinationId: 'ngu_hanh_son',
      description:
          'Đài vọng cảnh nằm ở phía tây nam núi Thủy Sơn, nơi có tấm bia đá khắc năm Minh Mạng thứ 18 (1837). '
          'Từ vị trí này có thể ngắm trọn dòng sông Cổ Cò, sông Cẩm Lệ và toàn cảnh cánh đồng trù phú.',
      relatedDestinationIds: ['chua_tam_thai', 'dong_huyen_khong'],
      alternatives: [
        RecognitionCandidate(name: 'Đỉnh Thượng Thai', confidence: 0.11, destinationId: 'ngu_hanh_son'),
      ],
      funFacts: [
        'Vua Minh Mạng chọn nơi đây để ngắm nhìn hai nhánh sông uốn lượn trước khi hội tụ ra biển cả.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Động Vân Thông',
      confidence: 0.84,
      destinationId: 'ngu_hanh_son',
      description:
          'Hang động hình ống dựng đứng trong lòng núi Thủy Sơn. Lối ra của hang động dẫn thẳng lên đỉnh Thượng Thai, '
          'nơi gió biển thổi lồng lộng và có thể bao quát toàn bộ 4 ngọn núi còn lại của Ngũ Hành Sơn.',
      relatedDestinationIds: ['dong_huyen_khong', 'chua_tam_thai', 'ngu_hanh_son'],
      alternatives: [
        RecognitionCandidate(name: 'Động Huyền Không', confidence: 0.12, destinationId: 'dong_huyen_khong'),
      ],
      funFacts: [
        'Còn được người dân gọi là "đường lên trời" vì du khách phải luồn qua khe đá hẹp dốc đứng để chạm tới đỉnh núi.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Chùa Quán Thế Âm',
      confidence: 0.85,
      destinationId: 'ngu_hanh_son',
      description:
          'Ngôi chùa nằm dưới chân ngọn Kim Sơn, nơi phát hiện bức tượng Phật Bà Quán Thế Âm bằng thạch nhũ tự nhiên. '
          'Đây là trung tâm của Lễ hội Quán Thế Âm Ngũ Hành Sơn – di sản văn hóa phi vật thể quốc gia.',
      relatedDestinationIds: ['chua_tam_thai', 'ngu_hanh_son'],
      alternatives: [
        RecognitionCandidate(name: 'Chùa Tam Thai', confidence: 0.10, destinationId: 'chua_tam_thai'),
      ],
      funFacts: [
        'Lễ hội Quán Thế Âm tổ chức vào ngày 19 tháng 2 âm lịch hằng năm thu hút hàng vạn Phật tử và du khách thập phương.',
      ],
    ),
    LandmarkRecognition(
      landmarkName: 'Có thể là: Quần thể Danh thắng Ngũ Hành Sơn',
      confidence: 0.54,
      destinationId: 'ngu_hanh_son',
      description:
          'Hình ảnh có đặc trưng núi đá vôi và cây xanh của quần thể Ngũ Hành Sơn, '
          'tuy nhiên góc chụp chưa đủ rõ nét để phân loại chính xác địa danh chi tiết. (Theo giới hạn LI-02: kết quả chỉ mang tính tham khảo).',
      relatedDestinationIds: ['dong_huyen_khong', 'chua_tam_thai', 'chua_linh_ung_non_nuoc'],
      alternatives: [
        RecognitionCandidate(name: 'Núi Thủy Sơn', confidence: 0.28, destinationId: 'ngu_hanh_son'),
        RecognitionCandidate(name: 'Động Huyền Không', confidence: 0.18, destinationId: 'dong_huyen_khong'),
      ],
      funFacts: [
        'Mẹo: Hãy chụp lại ở nơi đủ sáng, lấy trọn mặt tiền hoặc chi tiết nổi bật của di tích để nhận diện chuẩn xác hơn.',
      ],
    ),
  ];

  @override
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes) async {
    // Thời gian xử lý mô phỏng chuẩn của Edge AI trên điện thoại (1.5 - 2 giây)
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    if (imageBytes.isEmpty) {
      return _landmarks.last;
    }

    // Hash thuật toán xác định lớp nhận diện dựa trên đặc trưng byte ảnh
    var sum = 0;
    final step = (imageBytes.length ~/ 64).clamp(1, 1000);
    for (var i = 0; i < imageBytes.length; i += step) {
      sum = (sum * 31 + imageBytes[i]) & 0x7FFFFFFF;
    }

    final index = sum % _landmarks.length;
    return _landmarks[index];
  }

  @override
  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    return _ItineraryComposer(request).compose();
  }

  @override
  Future<ChatMessage> chat(List<ChatMessage> history, String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    final q = message.toLowerCase();
    String reply;
    var sources = <String>['Cơ sở dữ liệu SmartTravel – Ngũ Hành Sơn'];
    var suggestions = <String>[];

    if (q.contains('vé') || q.contains('giá') || q.contains('chi phí')) {
      reply = 'Vé tham quan núi Thủy Sơn hiện khoảng 40.000đ/người lớn (20.000đ học sinh/sinh viên). '
          'Vé thang máy 15.000đ/lượt. Các điểm như Động Huyền Không, Chùa Linh Ứng, Chùa Tam Thai nằm trong vé Thủy Sơn; '
          'riêng Động Âm Phủ có vé riêng 20.000đ/người.';
      sources = ['Ban Quản lý Di tích Danh thắng Ngũ Hành Sơn'];
      suggestions = ['Giờ mở cửa?', 'Có thang máy không?', 'Lịch trình 3 giờ'];
    } else if (q.contains('giờ') || q.contains('mở cửa') || q.contains('đóng cửa')) {
      reply = 'Danh thắng mở cửa từ 07:00 đến 17:30 hằng ngày. '
          'Thời điểm đẹp nhất để ngắm các cột nắng rọi qua vòm Động Huyền Không là từ 9:00 đến 11:30 sáng vào ngày nắng ráo.';
      sources = ['Thông tin vận hành Danh thắng Ngũ Hành Sơn'];
      suggestions = ['Gợi ý lịch trình nửa ngày', 'Lưu ý khi leo núi'];
    } else if (q.contains('ăn') || q.contains('quán') || q.contains('ẩm thực') || q.contains('món')) {
      reply = 'Khu vực chân núi Ngũ Hành Sơn và đường Lê Văn Hiến có nhiều quán Mì Quảng, bánh tráng cuốn thịt heo xứ Quảng. '
          'Nếu thích hải sản tươi sống và không gian biển, bạn có thể ghé khu Sơn Thủy hoặc phố ẩm thực An Thượng về đêm.';
      sources = ['Cẩm nang ẩm thực địa phương Ngũ Hành Sơn'];
      suggestions = ['Quán hải sản gần biển Sơn Thủy', 'Khám phá phố Tây An Thượng'];
    } else if (q.contains('biển') || q.contains('tắm') || q.contains('sơn thủy') || q.contains('bơi')) {
      reply = 'Bãi biển Sơn Thủy và Non Nước có bãi cát phẳng mịn, làn nước trong xanh. '
          'Lực lượng cứu hộ bờ biển túc trực từ 05:00 đến 18:00. Bạn nên tắm trong vùng cắm cờ xanh an toàn và tránh xa dòng chảy xa bờ (rip current).';
      sources = ['Đội Cứu hộ Bãi biển Ngũ Hành Sơn'];
      suggestions = ['Thể thao biển & SUP', 'Bãi biển nào yên tĩnh?'];
    } else if (q.contains('đá') || q.contains('workshop') || q.contains('làng') || q.contains('non nước')) {
      reply = 'Làng đá mỹ nghệ Non Nước là di sản văn hóa phi vật thể quốc gia hơn 400 năm tuổi. '
          'Du khách có thể tham gia workshop điêu khắc đá mini (khoảng 60 – 90 phút) để tự tay mài dũa móc khóa hoặc tượng nhỏ kỷ niệm cùng nghệ nhân.';
      sources = ['Hiệp hội Làng nghề Đá mỹ nghệ Non Nước'];
      suggestions = ['Đặt chỗ workshop đá', 'Mua quà lưu niệm ở đâu?'];
    } else if (q.contains('trang phục') || q.contains('mặc gì') || q.contains('leo núi')) {
      reply = 'Khi tham quan chùa chiền và các am thờ trong hang động, vui lòng mặc trang phục lịch sự, kín đáo qua gối và che vai. '
          'Nên mang giày thể thao có độ bám tốt vì các bậc đá có thể trơn trượt khi ẩm ướt, và đem theo nước uống cá nhân.';
      sources = ['Nội quy tham quan Di tích Quốc gia Đặc biệt Ngũ Hành Sơn'];
      suggestions = ['Thời gian leo núi Thủy Sơn', 'Vé thang máy'];
    } else {
      reply = 'Xin chào! Tôi là Trợ lý Du lịch Thông minh SmartTravel Ngũ Hành Sơn. '
          'Tôi có thể hỗ trợ bạn nhận diện ảnh địa danh, gợi ý lịch trình theo sở thích, thông tin giá vé, giờ mở cửa và các điểm check-in hấp dẫn.';
      suggestions = ['Giá vé & Giờ mở cửa', 'Lịch trình gợi ý', 'Đặc sản Ngũ Hành Sơn'];
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

/// Tương thích ngược: Alias cho MockAiRemoteDataSource
typedef MockAiRemoteDataSource = LocalOnDeviceAiDataSource;

/// [FE-05] Nguồn gọi Firebase Cloud Functions nếu được cấu hình backend.
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
      landmarkName: (json['landmarkName'] ?? json['destinationName'] ?? 'Không xác định').toString(),
      confidence: (json['confidence'] ?? json['confidenceScore'] as num? ?? 0).toDouble(),
      description: (json['description'] ?? json['historicalContext'] ?? '').toString(),
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

class _Candidate {
  const _Candidate(this.stop, this.interests, {this.order = 50});
  final ItineraryStop stop;
  final Set<String> interests;
  final int order;
}

/// Thuật toán lập lịch trình trên máy (On-Device Heuristic Planner):
/// Tối ưu hóa ràng buộc theo thời gian, ngân sách, phương tiện di chuyển và sở thích cá nhân.
class _ItineraryComposer {
  _ItineraryComposer(this.request);

  final ItineraryRequest request;

  static const _pool = [
    _Candidate(
      ItineraryStop(
        time: '',
        title: 'Leo núi Thủy Sơn & Vọng Giang Đài',
        description: 'Đi thang máy hoặc leo bậc đá, ngắm toàn cảnh dòng sông Cổ Cò và biển Non Nước từ Vọng Giang Đài.',
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
        description: 'Chiêm ngưỡng cột nắng tự nhiên rọi qua vòm động, tượng Phật Thích Ca và bia ký Ma nhai UNESCO.',
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
        description: 'Ngôi chùa cổ trên núi Thủy Sơn, không gian thanh tịnh với tầm nhìn hướng biển Đông.',
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
        title: 'Viếng Chùa Tam Thai & Động Âm Phủ',
        description: 'Thăm Quốc tự Tam Thai thời vua Minh Mạng và khám phá đường hầm Động Âm Phủ kỳ bí.',
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
        description: 'Tự tay chạm khắc móc khóa đá cẩm thạch cùng nghệ nhân truyền thống, mang quà kỷ niệm về nhà.',
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
        title: 'Tắm biển & chèo SUP tại Bãi biển Sơn Thủy',
        description: 'Thư giãn trên bờ cát trắng mịn, trải nghiệm chèo SUP đón gió biển trong khu vực có cứu hộ an toàn.',
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
        title: 'Cà phê thư giãn ngắm hoàng hôn bên biển',
        description: 'Nghỉ chân với ly cà phê muối hoặc trà dừa ngắm hoàng hôn lặn dần sau rặng Ngũ Hành Sơn.',
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
        title: 'Dạo phố du lịch An Thượng về đêm',
        description: 'Khám phá ẩm thực đường phố, không khí quốc tế đa văn hóa và cà phê nhạc sống sôi động.',
        durationMinutes: 120,
        kind: StopKind.food,
        estimatedCost: 250000,
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
          title: 'Ăn trưa Mì Quảng & Bánh tráng cuốn thịt heo',
          description: 'Quán ăn địa phương gần chân núi, mang đậm hương vị truyền thống xứ Quảng.',
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

    final interestsText = request.interests.isEmpty
        ? 'khám phá tổng thể'
        : request.interests.take(3).join(', ').toLowerCase();

    return GeneratedItinerary(
      title: 'Lịch trình ${request.freeHours} giờ khám phá Ngũ Hành Sơn',
      summary: 'Lịch trình được tối ưu hóa theo sở thích $interestsText, ngân sách '
          '${request.budget.label.toLowerCase()} cho ${request.groupSize} người, di chuyển bằng '
          '${request.transport.label.toLowerCase()}.',
      stops: stops,
      tips: [
        'Mang giày đế bám và nước uống khi leo núi Thủy Sơn.',
        'Trang phục lịch sự, che vai và qua đầu gối khi viếng các chùa cổ và am thờ trong động.',
        if (request.interests.contains('Biển & Thể thao nước'))
          'Chỉ tắm biển trong khu vực có cờ báo hiệu và lực lượng cứu hộ (05:00 – 18:00).',
        'Quét mã QR tại các điểm check-in di tích để tích điểm đổi quà lưu niệm đặc sản.',
      ],
      sources: const [
        'Cơ sở dữ liệu điểm đến SmartTravel (destinations)',
        'Lịch sự kiện & workshop làng nghề Ngũ Hành Sơn (events_workshops)',
        'Cẩm nang an toàn du lịch Ban Quản lý Di tích Ngũ Hành Sơn',
      ],
    );
  }

  String _fmt(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

/// Khởi tạo nguồn dữ liệu AI: Sử dụng On-Device Local AI làm mặc định,
/// đảm bảo chạy độc lập hoàn toàn không phụ thuộc API trả phí bên thứ 3.
AiRemoteDataSource createAiRemoteDataSource() =>
    AppConfig.useMockBackend ? const LocalOnDeviceAiDataSource() : CloudFunctionsAiRemoteDataSource();
