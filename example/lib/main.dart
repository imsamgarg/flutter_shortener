import 'package:flutter/material.dart';
import 'package:flutter_shortener/flutter_shortener.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Short Links'),
        ),
        body: Center(
          child: Container(
            child: TextButton(
              child: Text('Generate Short Links'),
              onPressed: () async {
                try {
                  final shortener = BitLyShortener(
                    accessToken: "YOUR_ACCESS_TOKEN",
                  );
                  final linkData = await shortener.generateShortLink(
                      longUrl: 'http://www.google.com');
                  print(linkData.link);
                } on BitLyException catch (e) {
                  print(e);
                } on Exception catch (e) {
                  print(e);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
