class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _phone = RegExp(r'^(\+84|0)\d{9,10}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập email.';
    if (!_email.hasMatch(v)) return 'Email chưa đúng định dạng.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (v.length < 6) return 'Mật khẩu cần tối thiểu 6 ký tự.';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if ((value?.trim() ?? '').isEmpty) return 'Vui lòng nhập $fieldName.';
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // không bắt buộc
    if (!_phone.hasMatch(v)) return 'Số điện thoại chưa hợp lệ.';
    return null;
  }

  static bool isValidEmail(String email) => _email.hasMatch(email.trim());
  static bool isValidPassword(String password) => password.length >= 6;
}
