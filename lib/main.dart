import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_test/video_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

const Color themeColor = Color(0xff00bc56);

void main() {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  AssetPicker.registerObserve();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeChat Asset Picker Demo',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: themeColor,
        ),
      ),
      home:  VideoCompressScreen(),
    );
  }
}
