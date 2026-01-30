import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuranWebView extends StatefulWidget {
  const QuranWebView({super.key});

  @override
  State<QuranWebView> createState() => _QuranWebViewState();
}

class _QuranWebViewState extends State<QuranWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _scrollPosition = 0.0;
  String _currentUrl = 'https://quran.ksu.edu.sa/m.php';
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    _initializeWebView();
  }

  // Load saved URL and scroll position from CacheService
  Future<void> _loadSavedState() async {
    setState(() {
     // _currentUrl = CacheService.getData(key: 'lastUrl') ?? 'https://quran.com/ar';
     // _scrollPosition = CacheService.getData(key: 'scrollPosition') ?? 0.0;
    });
  }

  // Save current URL and scroll position to CacheService
  Future<void> _saveState(String url, double scrollPosition) async {
    await CacheService.setData(key: 'lastUrl', value: url);
    await CacheService.setData(key: 'scrollPosition', value: scrollPosition);
  }

  // Initialize WebViewController
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            // Restore scroll position after page load
            await _controller.runJavaScript(
              'window.scrollTo(0, $_scrollPosition);',
            );
            // Update canGoBack status
            _canGoBack = await _controller.canGoBack();
            setState(() {});
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            // Save new URL when navigating
            _currentUrl = request.url;
            await _saveState(request.url, _scrollPosition);
            printWithColor("Navigating to: ${request.url}");
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange url) async {
            if (url.url != null) {
              _currentUrl = url.url!;
              await _saveState(_currentUrl, _scrollPosition);
              printWithColor("URL changed to: $_currentUrl");
            }
            // Update canGoBack status
            _canGoBack = await _controller.canGoBack();
            setState(() {});
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));

    // Listen to scroll changes
    _controller.setOnScrollPositionChange((position) {
      setState(() {
        _scrollPosition = position.y;
      });
      _saveState(_currentUrl, _scrollPosition);
    });
  }

  // Handle back navigation
  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      // Update current URL and scroll position after going back
      final newUrl = await _controller.currentUrl() ?? _currentUrl;
      setState(() {
        _currentUrl = newUrl;
      });
      await _saveState(_currentUrl, _scrollPosition);
      printWithColor("Went back to: $_currentUrl");
    }else{
      printWithColor("Can't go back");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: _canGoBack ? _goBack  : () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}