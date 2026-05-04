import '/core/services/biometric_service.dart';

class BiometricController {
  final BiometricService _service = BiometricService();

  bool _isAuthenticating = false;
  bool _stop = false; //  NEW

  Future<void> openSettings() async {
    await _service.openSettings();
  }

  Future<bool> canUseBiometrics() async {
    return await _service.canUseBiometrics();
  }

  void stopAuthentication() {
    _stop = true;
  }

  Future<void> authenticate({
    required Function onSuccess,
    required Function onFail,
  }) async {
    if (_isAuthenticating || _stop) return;
    _isAuthenticating = true;

    bool canUse = await canUseBiometrics();

    if (!canUse) {
      _isAuthenticating = false;
      onFail();
      return;
    }

    bool success = await _service.authenticate();

    if (_stop) return; //  stop everything

    if (success) {
      _stop = true; // STOP FUTURE RETRIES
      _isAuthenticating = false;
      onSuccess();
    } else {
      _isAuthenticating = false;

      Future.delayed(const Duration(seconds: 1), () {
        if (_stop) return; //  PREVENT RECALL
        authenticate(onSuccess: onSuccess, onFail: onFail);
      });
    }
  }
}
