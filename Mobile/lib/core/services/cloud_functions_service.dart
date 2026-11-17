import 'package:cloud_functions/cloud_functions.dart';

/// Wrapper to invoke Cloud Functions for sensitive operations (LI-07)
class CloudFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<HttpsCallableResult<T>> callFunction<T>(String functionName, [dynamic parameters]) async {
    final callable = _functions.httpsCallable(functionName);
    return await callable.call<T>(parameters);
  }
}
