/// Trạng thái tải dữ liệu dùng chung cho các Cubit.
enum ViewStatus { initial, loading, success, failure }

extension ViewStatusX on ViewStatus {
  bool get isLoading => this == ViewStatus.loading || this == ViewStatus.initial;
  bool get isFailure => this == ViewStatus.failure;
  bool get isSuccess => this == ViewStatus.success;
}
