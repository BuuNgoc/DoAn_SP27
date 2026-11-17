import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_info.dart';

/// State = `true` khi có mạng. Dùng để hiển thị OfflineBannerWidget.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._networkInfo) : super(true) {
    _init();
  }

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  Future<void> _init() async {
    try {
      emit(await _networkInfo.isConnected);
      _subscription = _networkInfo.onStatusChange.listen(emit);
    } catch (_) {
      // Nền tảng không hỗ trợ kiểm tra mạng → coi như đang online.
      emit(true);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
