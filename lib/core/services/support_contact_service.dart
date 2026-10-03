import 'package:url_launcher/url_launcher.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri url, LaunchMode mode);

class SupportContactService {
  static const _supportPhone = '5519991707830';
  final ExternalUrlLauncher _launch;

  const SupportContactService({ExternalUrlLauncher? launch})
    : _launch = launch ?? _launchExternal;

  Future<bool> contactOrder(int orderId) {
    if (orderId <= 0) {
      throw ArgumentError.value(orderId, 'orderId', 'Must be positive.');
    }
    final uri = Uri.https('wa.me', '/$_supportPhone', {
      'text': 'Olá, preciso de ajuda com o pedido #$orderId na SaveMed.',
    });
    return _launch(uri, LaunchMode.externalApplication);
  }

  static Future<bool> _launchExternal(Uri uri, LaunchMode mode) =>
      launchUrl(uri, mode: mode);
}
