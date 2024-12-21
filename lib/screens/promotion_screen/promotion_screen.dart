// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class PromotionScreen extends StatefulWidget {
//   const PromotionScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PromotionScreen> createState() => _PromotionScreenState();
// }
//
// class _PromotionScreenState extends State<PromotionScreen> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000)
//       );
//     //controller.loadRequest(Uri.parse('$apiBaseUrl/en/news'));
//     String langCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
//     controller.loadRequest(Uri.parse('$apiBaseUrl/$langCode/izmainas-un-jaunumi/izmainas/'));
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         leading: const BackButton(color: Colors.black),
//         title:
//         // Image.asset(
//         //   'assets/images/pv_logo.png',
//         //   color: AppColors.appLogoColorGrey,
//         //   height: 50,
//         // ),
//         SvgPicture.asset(
//           'assets/images/vivi-logo.svg',
//           color: Colors.black,
//           height: 30,
//         ),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           Expanded(
//             child: WebViewWidget(controller: controller),
//           ),
//         ],
//       ),
//     );
//   }
// }