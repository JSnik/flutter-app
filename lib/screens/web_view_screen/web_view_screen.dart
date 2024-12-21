import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.url, this.bottomPadding, this.hideBackButton});

  final String url;
  final double? bottomPadding;
  final bool? hideBackButton;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = true;
  var controller = WebViewController();


  @override
  void initState() {
    controller
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          if (progress > 50 && isLoading == true) {
            setState(() {
              isLoading = false;
            });
          }
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          if (isLoading == true) {
            setState(() {
              isLoading = false;
            });
          }
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)
      );
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    controller.loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: widget.hideBackButton == null ? const BackButton(color: AppColors.white) : const SizedBox(),
      ),
      body: Column(
        children: [
          Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: controller),
                  isLoading == false ? const SizedBox.shrink() :
                  const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.red,
                      )
                  ),
                ],
              )
          ),
          widget.bottomPadding == null ? const SizedBox() : SizedBox(height: widget.bottomPadding)
        ],
      ),
    );
  }
}
