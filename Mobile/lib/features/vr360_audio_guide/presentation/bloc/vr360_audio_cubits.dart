import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/vr360_audio_entities.dart';
import '../../domain/usecases/vr360_audio_usecases.dart';

// ─────────────────────────────── VR360 ───────────────────────────────

class Vr360State extends Equatable {
  const Vr360State({
    this.status = ViewStatus.initial,
    this.scenes = const [],
    this.currentIndex = 0,
    this.selectedHotspot,
    this.gyroEnabled = false,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<Vr360Scene> scenes;
  final int currentIndex;
  final Vr360Hotspot? selectedHotspot;
  final bool gyroEnabled;
  final String? errorMessage;

  Vr360Scene? get currentScene => scenes.isEmpty ? null : scenes[currentIndex];

  Vr360State copyWith({
    ViewStatus? status,
    List<Vr360Scene>? scenes,
    int? currentIndex,
    Vr360Hotspot? selectedHotspot,
    bool clearHotspot = false,
    bool? gyroEnabled,
    String? errorMessage,
  }) {
    return Vr360State(
      status: status ?? this.status,
      scenes: scenes ?? this.scenes,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedHotspot: clearHotspot ? null : (selectedHotspot ?? this.selectedHotspot),
      gyroEnabled: gyroEnabled ?? this.gyroEnabled,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, scenes, currentIndex, selectedHotspot, gyroEnabled, errorMessage];
}

/// [FE-03] View VR360 experience, explore 360° view, view content by location.
class Vr360Cubit extends Cubit<Vr360State> {
  Vr360Cubit(this._getScenes) : super(const Vr360State());

  final GetVr360ScenesUseCase _getScenes;

  Future<void> load(String destinationId) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final scenes = await _getScenes(destinationId);
      emit(state.copyWith(status: ViewStatus.success, scenes: scenes, currentIndex: 0));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  void selectScene(int index) {
    if (index == state.currentIndex || index < 0 || index >= state.scenes.length) return;
    emit(state.copyWith(currentIndex: index, clearHotspot: true));
  }

  void tapHotspot(Vr360Hotspot hotspot) => emit(state.copyWith(selectedHotspot: hotspot));

  void dismissHotspot() => emit(state.copyWith(clearHotspot: true));

  /// Chuyển tới góc nhìn được hotspot trỏ tới (nếu có trong danh sách).
  void followHotspot(Vr360Hotspot hotspot) {
    final index = state.scenes.indexWhere((s) => s.id == hotspot.targetSceneId);
    if (index >= 0) selectScene(index);
  }

  void toggleGyro() => emit(state.copyWith(gyroEnabled: !state.gyroEnabled));
}

// ─────────────────────────────── Audio Guide ───────────────────────────────

class AudioGuideState extends Equatable {
  const AudioGuideState({
    this.status = ViewStatus.initial,
    this.guide,
    this.language = AudioLanguage.vi,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.speed = 1.0,
    this.errorMessage,
  });

  final ViewStatus status;
  final AudioGuide? guide;
  final AudioLanguage language;
  final bool isPlaying;
  final double positionSeconds;
  final double speed;
  final String? errorMessage;

  int get durationSeconds => guide?.durationSeconds ?? 0;
  double get progress => durationSeconds == 0 ? 0 : (positionSeconds / durationSeconds).clamp(0, 1);
  bool get isFinished => durationSeconds > 0 && positionSeconds >= durationSeconds;
  bool get isFallbackLanguage => guide != null && !guide!.hasLanguage(language);

  AudioGuideState copyWith({
    ViewStatus? status,
    AudioGuide? guide,
    AudioLanguage? language,
    bool? isPlaying,
    double? positionSeconds,
    double? speed,
    String? errorMessage,
  }) {
    return AudioGuideState(
      status: status ?? this.status,
      guide: guide ?? this.guide,
      language: language ?? this.language,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      speed: speed ?? this.speed,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, guide, language, isPlaying, positionSeconds, speed, errorMessage];
}

/// [FE-03] Play / Pause / Resume, chọn ngôn ngữ, xem nội dung thuyết minh.
///
/// Dữ liệu mẫu chưa có tệp âm thanh nên tiến trình phát được mô phỏng bằng
/// bộ đếm thời gian. Khi `AudioGuide.audioUrls` có URL thật từ Firebase
/// Storage, thay phần `_ticker` bằng `just_audio` (`AudioPlayer.setUrl`).
class AudioGuideCubit extends Cubit<AudioGuideState> {
  AudioGuideCubit(this._getGuide) : super(const AudioGuideState());

  final GetAudioGuideUseCase _getGuide;
  Timer? _ticker;

  static const _tick = Duration(milliseconds: 250);

  Future<void> load(String destinationId) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final guide = await _getGuide(destinationId);
      if (guide == null) {
        emit(state.copyWith(
          status: ViewStatus.failure,
          errorMessage: 'Điểm đến này chưa có bài thuyết minh.',
        ));
        return;
      }
      emit(state.copyWith(status: ViewStatus.success, guide: guide, positionSeconds: 0));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  void togglePlay() => state.isPlaying ? pause() : play();

  void play() {
    if (state.guide == null) return;
    if (state.isFinished) emit(state.copyWith(positionSeconds: 0));
    _ticker?.cancel();
    _ticker = Timer.periodic(_tick, (_) {
      final next = state.positionSeconds + _tick.inMilliseconds / 1000 * state.speed;
      if (next >= state.durationSeconds) {
        _ticker?.cancel();
        emit(state.copyWith(positionSeconds: state.durationSeconds.toDouble(), isPlaying: false));
      } else {
        emit(state.copyWith(positionSeconds: next));
      }
    });
    emit(state.copyWith(isPlaying: true));
  }

  void pause() {
    _ticker?.cancel();
    emit(state.copyWith(isPlaying: false));
  }

  void seek(double seconds) =>
      emit(state.copyWith(positionSeconds: seconds.clamp(0, state.durationSeconds.toDouble())));

  void skip(int deltaSeconds) => seek(state.positionSeconds + deltaSeconds);

  void cycleSpeed() {
    const speeds = [1.0, 1.25, 1.5, 0.75];
    final next = speeds[(speeds.indexOf(state.speed) + 1) % speeds.length];
    emit(state.copyWith(speed: next));
  }

  /// Đổi ngôn ngữ sẽ phát lại từ đầu bài.
  void changeLanguage(AudioLanguage language) {
    if (language == state.language) return;
    final wasPlaying = state.isPlaying;
    pause();
    emit(state.copyWith(language: language, positionSeconds: 0));
    if (wasPlaying) play();
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
