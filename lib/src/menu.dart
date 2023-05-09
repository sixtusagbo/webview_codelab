import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
}

class Menu extends StatefulWidget {
  const Menu({super.key, required this.controller});

  final WebViewController controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.navigationDelegate:
            await widget.controller
                .loadRequest(Uri.parse('https://youtube.com'));
            break;
          case _MenuOptions.userAgent:
            final userAgent = await widget.controller
                .runJavaScriptReturningResult('navigator.userAgent');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$userAgent'),
                ),
              );
            }
            break;
          case _MenuOptions.javascriptChannel:
            await widget.controller.runJavaScript("""
let req = new XMLHttpRequest();
req.open('GET', 'https://api.ipify.org/?format=json');
req.onload = function () {
  if (req.status === 200) {
    SnackBar.postMessage(req.responseText);
  } else {
    SnackBar.postMessage('Error: ' + req.status);
  }
};
req.send();
""");
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.navigationDelegate,
          child: Text('Go to YouTube'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.userAgent,
          child: Text('Show User-Agent'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.javascriptChannel,
          child: Text('Check IP Address'),
        ),
      ],
    );
  }
}
