import 'package:web/web.dart' as web;

const _domProbeId = 'sello-search-empty-dom';

/// Injects screen-reader-only text inside `<flutter-view>` so headless browsers
/// can assert Arabic empty-state copy (CanvasKit does not surface label text).
void syncSearchEmptyStateDom(String? message) {
  final flutterView = web.document.querySelector('flutter-view');
  if (flutterView == null) return;

  final existing = web.document.getElementById(_domProbeId);
  if (message == null || message.isEmpty) {
    existing?.remove();
    return;
  }

  final el = existing ?? web.document.createElement('div');
  if (existing == null) {
    el.id = _domProbeId;
    el.setAttribute(
      'aria-hidden',
      'true',
    );
    el.setAttribute(
      'style',
      'position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;'
      'clip:rect(0,0,0,0);white-space:pre-wrap;border:0;',
    );
    flutterView.appendChild(el);
  }
  el.textContent = message;
}
