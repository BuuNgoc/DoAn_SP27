import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_images.dart';
import '../../domain/entities/vr360_audio_entities.dart';
import '../models/vr360_audio_models.dart';

/// [FE-03] Nguồn dữ liệu VR360 & Audio Guide.
abstract class Vr360AudioRemoteDataSource {
  Future<List<Vr360SceneModel>> fetchScenes(String destinationId);
  Future<AudioGuideModel?> fetchAudioGuide(String destinationId);
}

/// Dữ liệu mẫu: ảnh toàn cảnh trong assets + bài thuyết minh 4 ngôn ngữ.
class MockVr360AudioRemoteDataSource implements Vr360AudioRemoteDataSource {
  @override
  Future<List<Vr360SceneModel>> fetchScenes(String destinationId) async {
    await simulateLatency(const Duration(milliseconds: 300));
    return _scenes.where((s) => s.destinationId == destinationId).toList();
  }

  @override
  Future<AudioGuideModel?> fetchAudioGuide(String destinationId) async {
    await simulateLatency(const Duration(milliseconds: 250));
    for (final g in _guides) {
      if (g.destinationId == destinationId) return g;
    }
    return null;
  }

  static const _huyenKhongHotspots = [
    Vr360Hotspot(
      id: 'hk_buddha',
      label: 'Tượng Phật Thích Ca',
      description: 'Pho tượng Phật bằng đá đặt trên bệ thờ chính giữa lòng động, là trung tâm tâm linh của động Huyền Không.',
      latitude: 2,
      longitude: 42,
    ),
    Vr360Hotspot(
      id: 'hk_skylight',
      label: 'Giếng trời tự nhiên',
      description: 'Khe hở trên vòm động đón ánh nắng tạo thành cột sáng huyền ảo, đẹp nhất khoảng 9 – 11 giờ sáng.',
      latitude: 55,
      longitude: -67,
    ),
    Vr360Hotspot(
      id: 'hk_inscription',
      label: 'Bia ký Ma nhai',
      description: 'Văn bia chữ Hán – Nôm khắc trực tiếp lên vách đá, thuộc hệ thống Ma nhai được UNESCO ghi danh.',
      latitude: 5,
      longitude: -164,
    ),
    Vr360Hotspot(
      id: 'hk_to_lookout',
      label: 'Lên Vọng Giang Đài',
      description: 'Theo bậc đá đi lên để ngắm toàn cảnh thành phố và sông Hàn từ trên cao.',
      latitude: -20,
      longitude: 134,
      targetSceneId: 'nhs_lookout',
    ),
  ];

  static const _scenes = <Vr360SceneModel>[
    Vr360SceneModel(
      id: 'nhs_lookout',
      destinationId: 'ngu_hanh_son',
      title: 'Vọng Giang Đài',
      subtitle: 'Đỉnh núi Thủy Sơn',
      panoramaImage: AppImages.vongGiangPanorama,
      initialLongitude: 60,
      hotspots: [
        Vr360Hotspot(
          id: 'vg_sea',
          label: 'Biển Non Nước',
          description: 'Dải bờ biển dài hàng chục ki-lô-mét nối liền Sơn Thủy, Non Nước và Mỹ Khê.',
          latitude: 12,
          longitude: 121,
        ),
        Vr360Hotspot(
          id: 'vg_city',
          label: 'Thành phố Đà Nẵng',
          description: 'Từ đây có thể nhìn thấy sông Hàn và các cây cầu của thành phố về phía bắc.',
          latitude: 18,
          longitude: -101,
        ),
        Vr360Hotspot(
          id: 'vg_to_cave',
          label: 'Xuống động Huyền Không',
          description: 'Đi theo lối bậc đá phía sau để vào động Huyền Không.',
          latitude: -40,
          longitude: -67,
          targetSceneId: 'nhs_cave',
        ),
      ],
    ),
    Vr360SceneModel(
      id: 'nhs_cave',
      destinationId: 'ngu_hanh_son',
      title: 'Động Huyền Không',
      subtitle: 'Lòng động chính',
      panoramaImage: AppImages.huyenKhongPanorama,
      initialLongitude: 30,
      hotspots: _huyenKhongHotspots,
    ),
    Vr360SceneModel(
      id: 'hk_main',
      destinationId: 'dong_huyen_khong',
      title: 'Lòng động chính',
      subtitle: 'Động Huyền Không',
      panoramaImage: AppImages.huyenKhongPanorama,
      initialLongitude: 30,
      hotspots: [
        Vr360Hotspot(
          id: 'hk_buddha',
          label: 'Tượng Phật Thích Ca',
          description: 'Pho tượng Phật bằng đá đặt trên bệ thờ chính giữa lòng động.',
          latitude: 2,
          longitude: 42,
        ),
        Vr360Hotspot(
          id: 'hk_skylight',
          label: 'Giếng trời tự nhiên',
          description: 'Ánh nắng xuyên qua khe đá tạo nên những cột sáng huyền ảo.',
          latitude: 55,
          longitude: -67,
        ),
        Vr360Hotspot(
          id: 'hk_inscription',
          label: 'Bia ký Ma nhai',
          description: 'Văn bia chữ Hán – Nôm khắc trên vách đá từ thời Nguyễn.',
          latitude: 5,
          longitude: -164,
        ),
      ],
    ),
    Vr360SceneModel(
      id: 'lu_courtyard',
      destinationId: 'chua_linh_ung_non_nuoc',
      title: 'Sân chùa Linh Ứng',
      subtitle: 'Tượng Quan Thế Âm Bồ Tát',
      panoramaImage: AppImages.linhUngPanorama,
      hotspots: [
        Vr360Hotspot(
          id: 'lu_statue',
          label: 'Tượng Quan Âm đá trắng',
          description: 'Tượng Quan Thế Âm Bồ Tát hướng ra biển, như che chở cho ngư dân vùng Non Nước.',
          latitude: 22,
          longitude: -2,
        ),
        Vr360Hotspot(
          id: 'lu_gate',
          label: 'Cổng tam quan',
          description: 'Cổng chùa mang phong cách kiến trúc truyền thống với mái ngói cong và hoa văn rồng.',
          latitude: -8,
          longitude: 58,
        ),
        Vr360Hotspot(
          id: 'lu_hall',
          label: 'Chính điện',
          description: 'Nơi thờ Phật, vui lòng giữ trật tự và ăn mặc lịch sự khi vào bên trong.',
          latitude: 10,
          longitude: -141,
        ),
      ],
    ),
    Vr360SceneModel(
      id: 'nn_street',
      destinationId: 'lang_da_non_nuoc',
      title: 'Phố chế tác đá',
      subtitle: 'Làng đá mỹ nghệ Non Nước',
      panoramaImage: AppImages.nonNuocPanorama,
      hotspots: [
        Vr360Hotspot(
          id: 'nn_lions',
          label: 'Sư tử đá',
          description: 'Linh vật trấn trạch phổ biến, được chế tác từ đá cẩm thạch trắng và xám.',
          latitude: -22,
          longitude: -57,
        ),
        Vr360Hotspot(
          id: 'nn_artisans',
          label: 'Nghệ nhân đang chế tác',
          description: 'Quan sát các công đoạn đục thô, tạo hình và mài bóng ngay tại xưởng.',
          latitude: -24,
          longitude: 82,
        ),
        Vr360Hotspot(
          id: 'nn_mountain',
          label: 'Núi Thủy Sơn',
          description: 'Ngọn núi lớn nhất của Ngũ Hành Sơn nằm ngay sau làng nghề.',
          latitude: 45,
          longitude: 89,
        ),
      ],
    ),
    Vr360SceneModel(
      id: 'st_beach',
      destinationId: 'bai_bien_son_thuy',
      title: 'Bãi tắm Sơn Thủy',
      subtitle: 'Khu vực có cứu hộ',
      panoramaImage: AppImages.sonThuyPanorama,
      hotspots: [
        Vr360Hotspot(
          id: 'st_tower',
          label: 'Chòi cứu hộ',
          description: 'Nhân viên cứu hộ trực từ 05:00 đến 18:00. Chỉ tắm trong khu vực có cờ và phao báo.',
          latitude: 14,
          longitude: -125,
        ),
        Vr360Hotspot(
          id: 'st_boats',
          label: 'Thúng chai',
          description: 'Thuyền thúng truyền thống của ngư dân, có thể trải nghiệm chèo thúng cùng hướng dẫn viên.',
          latitude: -18,
          longitude: -67,
        ),
        Vr360Hotspot(
          id: 'st_mountain',
          label: 'Ngũ Hành Sơn',
          description: 'Quần thể núi đá vôi nhìn từ bờ biển.',
          latitude: 12,
          longitude: 55,
        ),
      ],
    ),
  ];

  static const _guides = <AudioGuideModel>[
    AudioGuideModel(
      id: 'ag_ngu_hanh_son',
      destinationId: 'ngu_hanh_son',
      title: 'Tổng quan Danh thắng Ngũ Hành Sơn',
      durationSeconds: 196,
      transcripts: {
        'vi': 'Chào mừng bạn đến với Danh thắng Ngũ Hành Sơn. Quần thể gồm năm ngọn núi đá vôi mang tên Kim, Mộc, Thủy, Hỏa và Thổ, '
            'tượng trưng cho ngũ hành trong triết lý phương Đông. Thủy Sơn là ngọn núi lớn nhất, nơi bạn sẽ gặp chùa Tam Thai, '
            'chùa Linh Ứng và động Huyền Không. Hãy đi chậm, lắng nghe tiếng chuông chùa và ngắm biển Non Nước từ Vọng Giang Đài.',
        'en': 'Welcome to the Marble Mountains scenic complex. It consists of five limestone hills named Metal, Wood, Water, Fire and Earth, '
            'representing the five elements of Eastern philosophy. Thuy Son, the Water Mountain, is the largest, home to Tam Thai Pagoda, '
            'Linh Ung Pagoda and Huyen Khong Cave. Take your time, listen to the temple bells and enjoy the view of Non Nuoc beach from the lookout.',
        'ko': '오행산 명승지에 오신 것을 환영합니다. 이곳은 금, 목, 수, 화, 토의 이름을 가진 다섯 개의 석회암 산으로 이루어져 있으며, '
            '동양 철학의 오행을 상징합니다. 가장 큰 산인 투이선(수산)에는 땀타이 사원, 린응 사원, 그리고 후옌콩 동굴이 있습니다. '
            '천천히 걸으며 사찰의 종소리를 듣고 전망대에서 논누억 해변을 감상해 보세요.',
        'zh': '欢迎来到五行山名胜区。这里由金山、木山、水山、火山和土山五座石灰岩山组成，象征东方哲学中的五行。'
            '水山是其中最大的一座，山上有三台寺、灵应寺和玄空洞。请放慢脚步，聆听寺庙的钟声，并在观景台上欣赏山水海滩的美景。',
      },
    ),
    AudioGuideModel(
      id: 'ag_huyen_khong',
      destinationId: 'dong_huyen_khong',
      title: 'Bên trong động Huyền Không',
      durationSeconds: 172,
      transcripts: {
        'vi': 'Bạn đang đứng trong động Huyền Không, hang động lớn và đẹp nhất của núi Thủy Sơn. Hãy ngước nhìn lên vòm động: '
            'những khe hở tự nhiên đón ánh nắng tạo thành các cột sáng huyền ảo, đẹp nhất vào buổi sáng. Chính giữa động là tượng Phật '
            'Thích Ca bằng đá, hai bên vách còn lưu giữ nhiều bia ký Hán – Nôm thời Nguyễn.',
        'en': 'You are standing inside Huyen Khong Cave, the largest and most beautiful cave of Thuy Son mountain. Look up at the ceiling: '
            'natural openings let sunlight pour in, creating magical beams of light, best seen in the morning. At the heart of the cave sits '
            'a stone statue of Shakyamuni Buddha, while the walls still bear Han-Nom inscriptions from the Nguyen dynasty.',
        'ko': '지금 계신 곳은 투이선에서 가장 크고 아름다운 후옌콩 동굴입니다. 동굴 천장을 올려다보세요. 자연적으로 뚫린 구멍으로 '
            '햇빛이 쏟아져 신비로운 빛기둥을 만들며, 오전에 가장 아름답습니다. 동굴 중앙에는 석가모니 불상이 모셔져 있고, '
            '양쪽 벽에는 응우옌 왕조 시대의 한놈 비문이 남아 있습니다.',
        'zh': '您现在位于玄空洞，这是水山上最大、最美的岩洞。请抬头看看洞顶：天然的孔隙让阳光倾泻而下，形成梦幻般的光柱，'
            '上午时分最为壮观。洞中央供奉着一尊石雕释迦牟尼佛像，两侧石壁上仍保存着阮朝时期的汉喃碑文。',
      },
    ),
    AudioGuideModel(
      id: 'ag_linh_ung',
      destinationId: 'chua_linh_ung_non_nuoc',
      title: 'Chùa Linh Ứng Non Nước',
      durationSeconds: 148,
      transcripts: {
        'vi': 'Chùa Linh Ứng nằm trên núi Thủy Sơn, có tên cũ là Ứng Chân và được đổi tên dưới triều vua Minh Mạng. '
            'Trước sân chùa là tượng Quan Thế Âm Bồ Tát bằng đá trắng hướng ra biển, như che chở cho ngư dân vùng Non Nước. '
            'Xin giữ trật tự và ăn mặc lịch sự khi vào chính điện.',
        'en': 'Linh Ung Pagoda sits on Thuy Son mountain. Formerly known as Ung Chan, it was renamed under Emperor Minh Mang. '
            'In the courtyard stands a white stone statue of Avalokiteshvara facing the sea, as if protecting the fishermen of Non Nuoc. '
            'Please keep quiet and dress modestly when entering the main hall.',
        'ko': '린응 사원은 투이선에 자리하고 있으며, 옛 이름은 응쩐이었으나 민망 황제 시대에 지금의 이름으로 바뀌었습니다. '
            '사원 앞마당에는 바다를 향한 하얀 관세음보살 석상이 있어 논누억 어민들을 지켜 주는 듯합니다. '
            '본당에 들어갈 때는 정숙을 유지하고 단정한 복장을 갖춰 주세요.',
        'zh': '灵应寺坐落在水山上，旧称应真寺，于明命帝时期改为现名。寺前庭院中矗立着一尊面向大海的白色观世音菩萨石像，'
            '仿佛在守护山水一带的渔民。进入正殿时请保持安静，衣着得体。',
      },
    ),
    AudioGuideModel(
      id: 'ag_lang_da',
      destinationId: 'lang_da_non_nuoc',
      title: 'Làng đá mỹ nghệ Non Nước',
      durationSeconds: 210,
      transcripts: {
        'vi': 'Chào mừng bạn đến làng đá mỹ nghệ Non Nước. Nghề điêu khắc đá ở đây hình thành từ khoảng thế kỷ XVIII, gắn với tổ nghề '
            'Huỳnh Bá Quát. Mỗi tác phẩm, từ chiếc vòng nhỏ đến bức tượng cao vài mét, đều trải qua các công đoạn chọn đá, tạo phôi, '
            'đục thô, tạo hình chi tiết và đánh bóng. Bạn có thể đăng ký workshop để tự tay khắc một món quà lưu niệm.',
        'en': 'Welcome to Non Nuoc stone carving village. Stone carving here dates back to around the 18th century and is linked to the '
            "craft's founder, Huynh Ba Quat. Every piece, from a small bracelet to a statue several meters tall, goes through stone selection, "
            'rough shaping, chiseling, detailed carving and polishing. You can join a workshop to carve your own souvenir.',
        'ko': '논누억 석공예 마을에 오신 것을 환영합니다. 이곳의 석조각 공예는 18세기 무렵 시작되었으며, 공예의 시조인 후인바꽛과 '
            '깊은 관련이 있습니다. 작은 팔찌부터 몇 미터 높이의 조각상까지, 모든 작품은 돌 고르기, 초벌 다듬기, 세부 조각, '
            '연마 과정을 거칩니다. 워크숍에 참여해 직접 기념품을 조각해 보세요.',
        'zh': '欢迎来到山水石雕工艺村。这里的石雕技艺大约起源于十八世纪，与行业祖师黄伯括密切相关。每一件作品，从小手镯到数米高的雕像，'
            '都要经过选石、粗坯、细雕和抛光等工序。您可以报名参加工作坊，亲手雕刻一件纪念品。',
      },
    ),
    AudioGuideModel(
      id: 'ag_tam_thai',
      destinationId: 'chua_tam_thai',
      title: 'Quốc tự Tam Thai',
      durationSeconds: 126,
      transcripts: {
        'vi': 'Chùa Tam Thai là một quốc tự dưới triều Nguyễn, được vua Minh Mạng cho trùng tu. Qua cổng tam quan, bạn sẽ thấy chính điện '
            'thờ Phật và lầu chuông cổ. Từ chùa có lối đi đến Vọng Hải Đài – nơi ngắm biển Non Nước rất đẹp vào buổi sáng.',
        'en': 'Tam Thai Pagoda was a royal pagoda under the Nguyen dynasty and was restored by Emperor Minh Mang. Through the three-entrance '
            'gate you will see the main Buddha hall and an old bell tower. A path from the pagoda leads to Vong Hai lookout, '
            'offering a lovely morning view of Non Nuoc beach.',
      },
    ),
    AudioGuideModel(
      id: 'ag_am_phu',
      destinationId: 'dong_am_phu',
      title: 'Hành trình qua động Âm Phủ',
      durationSeconds: 140,
      transcripts: {
        'vi': 'Động Âm Phủ tái hiện quan niệm dân gian về cõi âm với cầu Âm Dương, các tượng phán xử và lối đi quanh co trong lòng núi. '
            'Cuối hành trình, khe đá dẫn lên ánh sáng tượng trưng cho con đường lên cõi thiện. Lối đi khá trơn, bạn hãy mang giày đế bám.',
        'en': 'Am Phu Cave recreates folk beliefs about the underworld with the Yin-Yang bridge, judgment statues and winding paths inside the '
            'mountain. At the end, a rock passage leads up to the light, symbolizing the road to paradise. The path can be slippery, '
            'so please wear shoes with good grip.',
      },
    ),
  ];
}

// Ghi chú: Bản Firestore đọc `destinations/{id}/vr360_contents` và `audio_guides`
// qua Vr360SceneModel.fromFirestore / AudioGuideModel.fromFirestore.
