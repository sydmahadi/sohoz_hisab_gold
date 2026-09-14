import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;

            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://nebuquar621995.blogspot.com/p/import-urlhttpsfonts_02133745547.html',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('তথ্য দেখুন'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'রিফ্রেশ',
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),

          if (_isLoading)
            Container(
              color: AppTheme.background.withOpacity(0.75),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
