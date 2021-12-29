import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';

import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class VideoCompressScreen extends StatefulWidget {
  @override
  _VideoCompressScreenState createState() => _VideoCompressScreenState();
}

class _VideoCompressScreenState extends State<VideoCompressScreen> {
  final List<VideoPlayerController> _controllers = [];

  List<AssetEntity> selectedAssets = [];
  List<File> files = [];

  @override
  void initState() {
    super.initState();
    VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controllers.isNotEmpty
              ? _videoList()
              : const SizedBox(
                  child: Text("No videos yet"),
                ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await _onPickImageButtonPressed();
              for (int i = 0; i < files.length; i++) {
                var controller = VideoPlayerController.file(files[i]);
                await controller.initialize();
                _controllers.add(controller);
                setState(() {});
              }
            },
            child: const Icon(Icons.video_camera_front)),
      ),
    );
  }

  Widget _videoList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.5)),
              margin: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: VideoPlayer(_controllers[index]),
                  ),
                  // Text(
                  //   byteToMb(files[index].lengthSync()),
                  //   style: const TextStyle(color: Colors.black),
                  // ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: IconButton(
                        onPressed: () {
                          if (_controllers[index].value.isPlaying) {
                            _controllers[index].pause();
                          } else {
                            _controllers[index].play();
                          }
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.red,
                        )),
                  ),
                  Positioned(
                    right: 50,
                    bottom: 10,
                    child: IconButton(
                        onPressed: () {
                          compressVideo(files[index]);
                        },
                        icon: const Icon(
                          Icons.compress,
                          color: Colors.red,
                        )),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future<void> compressVideo(File file) async {
    print("size before compression:  ${byteToMb(file.lengthSync())}");

    MediaInfo? mediaInfo = await VideoCompress.compressVideo(file.absolute.path,
        quality: VideoQuality.LowQuality, deleteOrigin: true);

    print("size after compression: ${byteToMb(mediaInfo!.filesize!)}");
    setState(() {
      file = mediaInfo.file!;
    });

    return;
  }

  Future<void> _onPickImageButtonPressed() async {
    selectedAssets = await AssetPicker.pickAssets(context,
            pickerTheme: ThemeData(),
            requestType: RequestType.video,
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

  String byteToMb(int byte) {
    var mb = byte * 0.000001;
    return "${mb.toStringAsPrecision(2)} mb";
  }

  @override
  void dispose() {
    super.dispose();
  }
}
