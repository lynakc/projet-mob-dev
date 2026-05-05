import 'package:local_auth/local_auth.dart';
import 'package:android_intent_plus/android_intent.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    final canCheck = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();
    final enrolled = await auth.getAvailableBiometrics();

    return canCheck && isSupported && enrolled.isNotEmpty;
  }

  Future<bool> authenticate() async {
    try {
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

  Future<void> openSettings() async {
    final intent = AndroidIntent(action: 'android.settings.SETTINGS');
    await intent.launch();
  }
}
