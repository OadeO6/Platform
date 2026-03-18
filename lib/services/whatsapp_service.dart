import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/validators.dart';

/// Handles WhatsApp contact linking for Platform.
class WhatsAppService {
  /// Builds and launches a WhatsApp chat URL for a listing.
  Future<void> contactSeller({
    required String phone,
    required String itemTitle,
    required String itemId,
  }) async {
    // Validate and normalise the number first
    final normalised = Validators.normaliseWhatsApp(phone);
    if (normalised == null || normalised.isEmpty) {
      throw const NetworkException(
        'This seller\'s WhatsApp number is invalid. They may need to update their profile.',
      );
    }

    try {
      final url = _buildUrl(
        normalisedPhone: normalised,
        itemTitle: itemTitle,
        itemId: itemId,
      );
      await _launch(url);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Could not open WhatsApp: $e');
    }
  }

  /// Builds the wa.me URL with a prefilled message.
  /// [normalisedPhone] must be in E.164 format (e.g. +2348012345678).
  String _buildUrl({
    required String normalisedPhone,
    required String itemTitle,
    required String itemId,
  }) {
    // wa.me expects digits only (no +)
    final digits = normalisedPhone.replaceAll('+', '');

    final message = AppConstants.whatsappMessageTemplate
        .replaceAll('{title}', itemTitle)
        .replaceAll('{id}', itemId);

    final encodedMessage = Uri.encodeComponent(message);
    return '${AppConstants.whatsappBaseUrl}$digits?text=$encodedMessage';
  }

  Future<void> _launch(String urlString) async {
    final uri = Uri.parse(urlString);
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      throw const NetworkException(
        'Could not open WhatsApp. Make sure it is installed.',
      );
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw const NetworkException(
        'Could not open WhatsApp. Make sure it is installed.',
      );
    }
  }
}
