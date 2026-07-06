import 'package:web/web.dart' as web;

/// Sets a DOM attribute automation tools can wait on after the first frame.
void markSelloWebReady() {
  web.document.documentElement?.setAttribute('data-sello-ready', 'true');
}
