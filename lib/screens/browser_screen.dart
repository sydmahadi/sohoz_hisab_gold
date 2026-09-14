import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;

  final TextEditingController _urlController =
      TextEditingController(text: 'https://www.google.com/');

  bool _isLoading = true;
  int _progress = 0;

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
              _progress = 0;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;

            setState(() {
              _progress = progress;
            });
          },
          onPageFinished: (url) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
              _progress = 100;
              _urlController.text = url;
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
        Uri.parse('https://www.google.com/'),
      );
  }

  void _openUrl() {
    String url = _urlController.text.trim();

    if (url.isEmpty) {
      return;
    }

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);

    if (uri == null || uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক ওয়েব ঠিকানা লিখুন'),
        ),
      );
      return;
    }

    _controller.loadRequest(uri);
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _handleBack();

        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('ব্রাউজার'),
          actions: [
            IconButton(
              onPressed: () {
                _controller.reload();
              },
              tooltip: 'রিফ্রেশ',
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                10,
                8,
                10,
                8,
              ),
              color: AppTheme.backgroundSecondary,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (await _controller.canGoBack()) {
                        _controller.goBack();
                      }
                    },
                    tooltip: 'পেছনে',
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.goldLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await _controller.canGoForward()) {
                        _controller.goForward();
                      }
                    },
                    tooltip: 'সামনে',
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.goldLight,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) {
                        _openUrl();
                      },
                      decoration: const InputDecoration(
                        hintText: 'ওয়েব ঠিকানা লিখুন',
                        prefixIcon: Icon(
                          Icons.language_rounded,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _openUrl,
                    tooltip: 'যান',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(
                      Icons.search_rounded,
                    ),
                  ),
                ],
              ),
            ),

            if (_isLoading)
              LinearProgressIndicator(
                value: _progress == 0
                    ? null
                    : _progress / 100,
                backgroundColor: AppTheme.cardColor,
                color: AppTheme.gold,
                minHeight: 2,
              ),

            Expanded(
              child: WebViewWidget(
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
