library fixpanel;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';

class FixPanel {
  FixPanel(String token, String env) {
    _token = token;
    _env = env;
    _deviceInfo = {};
    _getDeviceInfo();
  }

  // connection parameters
  static const String scheme = 'https';
  static const String host = 'api.mixpanel.com';

  // variables
  String _token;
  String _env;
  Map<String, dynamic> _deviceInfo;

  // methods
  Future<void> _getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      _deviceInfo = {
        'environment': _env,
        '\$android_os': 'Android',
        '\$android_os_version': info.version.release ?? 'UNKNOWN',
        '\$android_manufacturer': info.manufacturer ?? 'UNKNOWN',
        '\$android_brand': info.brand ?? 'UNKNOWN',
        '\$android_model': info.model ?? 'UNKNOWN',
        '\$android_app_version': packageInfo.version,
        '\$android_app_version_code': packageInfo.buildNumber,
      };
    } else if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      _deviceInfo = {
        'environment': _env,
        '\$ios_app_version': packageInfo.version,
        '\$ios_app_release': packageInfo.buildNumber,
        '\$ios_device_model': info.model,
        '\$ios_version': info.systemVersion,
      };
    }
  }

  track(String eventName, Map properties) {
    properties['token'] = _token;
    send('/track', {'event': eventName, 'properties': properties});
  }

  send(String endpoint, Map data) async {
    data['token'] = _token;
    http.Response response = await http
        .get(Uri(scheme: scheme, host: host, path: endpoint, queryParameters: {
      'data': base64Url.encode(utf8.encode(json.encode(data))),
    }));
    debugPrint('statusCode: ${response.statusCode}; body: ${response.body}');
  }
}
