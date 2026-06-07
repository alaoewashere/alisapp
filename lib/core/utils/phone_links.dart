import 'package:url_launcher/url_launcher.dart';

/// Normalizes Iraqi phone to wa.me format: 964XXXXXXXXX (no +).
String normalizeIraqPhoneForWhatsApp(String? phone) {
  if (phone == null || phone.trim().isEmpty) return '';
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('964')) {
    // already international
  } else if (digits.startsWith('0')) {
    digits = '964${digits.substring(1)}';
  } else {
    digits = '964$digits';
  }
  return digits;
}

Uri whatsAppUri(String? phone, {String? message}) {
  final normalized = normalizeIraqPhoneForWhatsApp(phone);
  final buffer = StringBuffer('https://wa.me/$normalized');
  if (message != null && message.isNotEmpty) {
    buffer.write('?text=${Uri.encodeComponent(message)}');
  }
  return Uri.parse(buffer.toString());
}

Uri telUri(String? phone) {
  final normalized = normalizeIraqPhoneForWhatsApp(phone);
  if (normalized.isEmpty) return Uri.parse('tel:');
  return Uri.parse('tel:+$normalized');
}

Future<bool> launchExternalUri(Uri uri) async {
  try {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // iOS may return false without LSApplicationQueriesSchemes — attempt anyway.
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<bool> launchWhatsApp(String? phone, {String? message}) async {
  if (phone == null || phone.trim().isEmpty) return false;
  return launchExternalUri(whatsAppUri(phone, message: message));
}

Future<bool> launchPhoneCall(String? phone) async {
  if (phone == null || phone.trim().isEmpty) return false;
  return launchExternalUri(telUri(phone));
}
