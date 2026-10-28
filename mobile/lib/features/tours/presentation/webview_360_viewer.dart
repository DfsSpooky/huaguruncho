import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../domain/scene_model.dart';
import '../domain/hotspot_model.dart';

class WebView360Viewer extends StatefulWidget {
  final SceneModel scene;
  final double? overrideYaw;
  final double? overridePitch;
  final Function(HotspotModel hotspot) onHotspotClick;

  const WebView360Viewer({
    super.key,
    required this.scene,
    this.overrideYaw,
    this.overridePitch,
    required this.onHotspotClick,
  });

  @override
  State<WebView360Viewer> createState() => WebView360ViewerState();
}

class WebView360ViewerState extends State<WebView360Viewer> {
  static final Map<String, String> _panoramaDataUriCache = {};

  late final WebViewController _controller;
  bool _isWebViewReady = false;
  bool _isLoadingScene = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant WebView360Viewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.scene.uuid != widget.scene.uuid ||
            oldWidget.scene.hotspots.length != widget.scene.hotspots.length ||
            oldWidget.scene.panoramaImageUrl != widget.scene.panoramaImageUrl ||
            oldWidget.scene.initialYaw != widget.scene.initialYaw ||
            oldWidget.scene.initialPitch != widget.scene.initialPitch) &&
        _isWebViewReady) {
      _loadCurrentScene();
    }
  }

  void lookAt(double yaw, double pitch) {
    if (!_isWebViewReady) return;
    _controller.runJavaScript('if (window.lookAt) { window.lookAt($yaw, $pitch); }');
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B1D2E))
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!_isWebViewReady) {
              _isWebViewReady = true;
              _loadCurrentScene();
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/web/viewer_360.html');
  }

  void _handleJavaScriptMessage(String rawJson) {
    try {
      final data = json.decode(rawJson) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'ready') {
        _isWebViewReady = true;
        _loadCurrentScene();
      } else if (type == 'hotspot_click') {
        final hotspotJson = data['hotspot'] as Map<String, dynamic>;
        final hotspot = HotspotModel.fromJson(hotspotJson);
        widget.onHotspotClick(hotspot);
      }
    } catch (e) {
      debugPrint('Error en mensaje de JavaScriptBridge: $e');
    }
  }

  Future<String?> _fetchRemotePanoramaAsDataUri(String url) async {
    if (_panoramaDataUriCache.containsKey(url)) {
      return _panoramaDataUriCache[url];
    }
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        if (bytes.isNotEmpty) {
          final b64 = base64Encode(bytes);
          final dataUri = 'data:image/jpeg;base64,$b64';
          if (_panoramaDataUriCache.length > 6) {
            _panoramaDataUriCache.remove(_panoramaDataUriCache.keys.first);
          }
          _panoramaDataUriCache[url] = dataUri;
          return dataUri;
        }
      }
    } catch (e) {
      debugPrint('Aviso descargando panorama remoto en Dart: $e');
    }
    return null;
  }

  Future<void> _loadCurrentScene() async {
    if (_isLoadingScene) return;
    _isLoadingScene = true;

    try {
      String imageSource = '';

      // 1. Si hay archivo local descargado
      if (widget.scene.panoramaLocalPath != null && widget.scene.panoramaLocalPath!.isNotEmpty) {
        final file = File(widget.scene.panoramaLocalPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          imageSource = 'data:image/jpeg;base64,$base64String';
        }
      }

      // 2. Si hay URL remota del Studio Backend (Descargar en Dart para evitar restricciones CORS de WebGL)
      if (imageSource.isEmpty &&
          widget.scene.panoramaImageUrl != null &&
          widget.scene.panoramaImageUrl!.isNotEmpty) {
        final remoteDataUri = await _fetchRemotePanoramaAsDataUri(widget.scene.panoramaImageUrl!);
        imageSource = remoteDataUri ?? widget.scene.panoramaImageUrl!;
      }

      // 3. Si hay asset local embebido
      if (imageSource.isEmpty && widget.scene.panoramaAsset != null) {
        try {
          final byteData = await rootBundle.load(widget.scene.panoramaAsset!);
          final bytes = byteData.buffer.asUint8List();
          final base64String = base64Encode(bytes);
          imageSource = 'data:image/jpeg;base64,$base64String';
        } catch (_) {}
      }

      // Fallback a demo asset si está vacío
      if (imageSource.isEmpty) {
        try {
          final byteData = await rootBundle.load('assets/panoramas/scene_huachon_plaza.jpg');
          final bytes = byteData.buffer.asUint8List();
          final base64String = base64Encode(bytes);
          imageSource = 'data:image/jpeg;base64,$base64String';
        } catch (_) {}
      }

      if (!mounted) return;

      final startYaw = widget.overrideYaw ?? widget.scene.initialYaw;
      final startPitch = widget.overridePitch ?? widget.scene.initialPitch;

      final encodedImg = json.encode(imageSource);
      final hotspotsJson = json.encode(widget.scene.hotspots.map((h) => h.toJson()).toList());

      final jsCommand =
          'if (window.loadPanorama) { window.loadPanorama($encodedImg, $hotspotsJson, $startYaw, $startPitch); }';
      await _controller.runJavaScript(jsCommand);
    } finally {
      _isLoadingScene = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
