import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetEntity> selectedAssets = [];
  List<File> files = [];
  List<File> compressedFiles = [];
  static const int IMAGE_QUALITY = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            files.isEmpty
                ? const SizedBox(
                    child: Text("No selected images found"),
                  )
                : _buildListView(files),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                    "Pick images", () async => _onPickImageButtonPressed()),
                _buildButton(
                    "Compress ", () => _onCompressImageButtonpressed()),
              ],
            ),
            const SizedBox(height: 20),
            compressedFiles.isEmpty
                ? const SizedBox(
                    child: Text("No compressed image files"),
                  )
                : _buildListView(compressedFiles),
          ],
        ),
      ),
    );
  }

  Future<void> _onPickImageButtonPressed() async {
    selectedAssets = await AssetPicker.pickAssets(
            
            context,
            pickerTheme: ThemeData(),
            textDelegate: EnglishTextDelegate(),
            selectedAssets: selectedAssets) ??
        selectedAssets;

    if (files.isNotEmpty) files.clear();

    for (int i = 0; i < selectedAssets.length; i++) {
      var singleFile = await selectedAssets[i].file;
      files.add(singleFile!);
    }

    setState(() {});
  }

  void _onCompressImageButtonpressed() {
    if (files.isNotEmpty) {
      _compressImages(files);
    } else {
      print("no files found");
    }
  }

  Widget _buildButton(String text, Function onPressed) {
    return MaterialButton(
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: () {
        onPressed();
      },
      child: Text(text),
    );
  }

  Widget _buildListView(List<File> files) {
    return Center(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            itemBuilder: (context, index) {
              String length = byteToMb(files[index].lengthSync());
              return Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _showMyDialog(files[index], compressedFiles[index]),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 2.0, color: Colors.red)),
                      margin: const EdgeInsets.only(right: 10, bottom: 5.0),
                      height: 60,
                      width: 60,
                      child: Image.file(files[index]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(length)
                ],
              );
            }),
      ),
    );
  }

  void _compressImages(List<File> files) async {
    compressedFiles.clear();
    var tempTargetPath = await getApplicationDocumentsDirectory();
    for (int i = 0; i < files.length; i++) {
      var result = await FlutterImageCompress.compressAndGetFile(
        files[i].absolute.path,
        tempTargetPath.absolute.path + "/file_$i.jpg",
        minWidth: 1080,
        quality: IMAGE_QUALITY,
      );

      compressedFiles.add(result!);
    }
    setState(() {});
  }

  String byteToMb(int byte) {
    var mb = byte * 0.000001;
    return "${mb.toStringAsPrecision(2)} mb";
  }

  Future<void> _showMyDialog(File file1, File file2) async {
    return showDialog<void>(
      context: context,

      // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(10),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Before:"),
                const SizedBox(height: 10),
                Image.file(file1),
                const Text("After: "),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Image.file(file2),
              ],
            ),
          ),
          actions: [
            MaterialButton(
                child: const Text("quit"),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
