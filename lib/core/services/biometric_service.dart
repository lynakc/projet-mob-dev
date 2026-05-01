import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) return false;

      // Check if any biometrics are enrolled
      final enrolled = await auth.getAvailableBiometrics();
      if (enrolled.isEmpty) return false;  // ← add this

      return await auth.authenticate(
        localizedReason: 'Scan your fingerprint to enter',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }

  }
}