import 'dart:html' as html show window, Window;

import '../../../sentry_flutter.dart';
import 'url_filter_event_processor.dart';
// ignore: implementation_imports
import 'package:sentry/src/utils/regex_utils.dart';

// ignore_for_file: invalid_use_of_internal_member

UrlFilterEventProcessor urlFilterEventProcessor(SentryFlutterOptions options) =>
    WebUrlFilterEventProcessor(options);

class WebUrlFilterEventProcessor implements UrlFilterEventProcessor {
  WebUrlFilterEventProcessor(
    this._options,
  );

  final html.Window _window = html.window;
  final SentryFlutterOptions _options;

  @override
  SentryEvent? apply(SentryEvent event, Hint hint) {
    final url = _window.location.toString();

    if (_options.allowUrls.isNotEmpty &&
        !isMatchingRegexPattern(url, _options.allowUrls)) {
      return null;
    }

    if (_options.denyUrls.isNotEmpty &&
        isMatchingRegexPattern(url, _options.denyUrls)) {
      return null;
    }

    return event;
  }
}