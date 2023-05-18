import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  removeCookie,
  setCookie,
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
}

class Menu extends StatefulWidget {
  const Menu({super.key, required this.controller});

  final WebViewController controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final cookieManager = WebViewCookieManager();
  final String kExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
 This is an example page used to demonstrate how to load a local file or HTML
 string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
 webview</a> plugin.
</p>

</body>
</html>
''';

  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies = await controller
        .runJavaScriptReturningResult('document.cookie') as String;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isEmpty ? "There are no cookies" : cookies),
      ),
    );
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = "There were cookies. Now, they are gone!";
    if (!hadCookies) {
      message = "There were no cookies to clear.";
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavaScript('''var date = new Date();
  date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=Sixtus; expires=" + date.toGMTString();''');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Custom cookie added.")),
    );
  }

  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(
          name: "dashFriend", value: "sixtus", domain: "flutter.dev"),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Custom cookie is set")),
    );
  }

  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavaScript(
        '''document.cookie="FirstName=Sixtus; expires=Thu, 01 Jan 1970 00:00:00 UTC"''');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Custom cookie removed.")),
    );
  }

  Future<void> _onLoadFlutterAsset(WebViewController controller) async {
    await controller.loadFlutterAsset("assets/www/index.html");
  }

  Future<void> _onLoadLocalFile(WebViewController controller) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File("$tmpDir/www/index.html");

    await Directory("$tmpDir/www").create(recursive: true);
    await indexFile.writeAsString(kExamplePage);

    return indexFile.path;
  }

  Future<void> _onLoadHtmlString(WebViewController controller) async {
    await controller.loadHtmlString(kExamplePage);
  }

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
if (req === undefined) {
  let req = new XMLHttpRequest();
}
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
          case _MenuOptions.addCookie:
            await _onAddCookie(widget.controller);
            break;
          case _MenuOptions.clearCookies:
            await _onClearCookies();
            break;
          case _MenuOptions.listCookies:
            await _onListCookies(widget.controller);
            break;
          case _MenuOptions.removeCookie:
            await _onRemoveCookie(widget.controller);
            break;
          case _MenuOptions.setCookie:
            await _onSetCookie(widget.controller);
            break;
          case _MenuOptions.loadFlutterAsset:
            await _onLoadFlutterAsset(widget.controller);
            break;
          case _MenuOptions.loadHtmlString:
            await _onLoadHtmlString(widget.controller);
            break;
          case _MenuOptions.loadLocalFile:
            await _onLoadLocalFile(widget.controller);
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
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.listCookies,
          child: Text('List Cookies'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.addCookie,
          child: Text('Add Cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.removeCookie,
          child: Text('Remove Cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.setCookie,
          child: Text('Set Cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.clearCookies,
          child: Text('Clear Cookies'),
        ),
        const PopupMenuItem(
          value: _MenuOptions.loadHtmlString,
          child: Text("Load HTML String"),
        ),
        const PopupMenuItem(
          value: _MenuOptions.loadFlutterAsset,
          child: Text("Load Flutter Asset"),
        ),
        const PopupMenuItem(
          value: _MenuOptions.loadLocalFile,
          child: Text("Load Local File"),
        ),
      ],
    );
  }
}
