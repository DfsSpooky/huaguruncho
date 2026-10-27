import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../domain/scene_model.dart';
import '../domain/hotspot_model.dart';

class WebView360Viewer extends StatefulWidget {
  final SceneModel scene;
  final Function(HotspotModel hotspot) onHotspotClick;

  const WebView360Viewer({
    super.key,
    required this.scene,
    required this.onHotspotClick,
  });

  @override
  State<WebView360Viewer> createState() => _WebView360ViewerState();
}

class _WebView360ViewerState extends State<WebView360Viewer> {
  late final WebViewController _controller;
  bool _isWebViewReady = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant WebView360Viewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.uuid != widget.scene.uuid && _isWebViewReady) {
      _loadCurrentScene();
    }
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
            setState(() {
              _isWebViewReady = true;
            });
            _loadCurrentScene();
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

  Future<void> _loadCurrentScene() async {
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

    // 2. Si hay asset local embebido
    if (imageSource.isEmpty && widget.scene.panoramaAsset != null) {
      try {
        final byteData = await rootBundle.load(widget.scene.panoramaAsset!);
        final bytes = byteData.buffer.asUint8List();
        final base64String = base64Encode(bytes);
        imageSource = 'data:image/jpeg;base64,$base64String';
      } catch (_) {}
    }

    // 3. Si hay URL remota
    if (imageSource.isEmpty && widget.scene.panoramaImageUrl != null) {
      imageSource = widget.scene.panoramaImageUrl!;
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

    final hotspotsJson = json.encode(widget.scene.hotspots.map((h) => h.toJson()).toList());

    final jsCommand = "if (window.loadPanorama) { window.loadPanorama('$imageSource', $hotspotsJson); }";
    _controller.runJavaScript(jsCommand);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
