import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:async';
import 'dart:ui';
import 'package:sizer/sizer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Post(),
      );
    });
  }
}

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  List<AssetEntity> assets = [];
  int postIndex = 0;
  int currentPage = 0;

  var grid;

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (grid == null) {
      grid = Expanded(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: assets.length,
          itemBuilder: (_, index) {
            return GestureDetector(
              child: AssetThumbnail(asset: assets[index]),
              onTap: () => setState(() {
                postIndex = index;
              }),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.clear_outlined,
                    color: Colors.black87,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "作品投稿",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Text(
                      "投稿",
                      style: TextStyle(
                          color: Color(0xFFFF8D89),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  onTap: () {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                )),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _Inherited(
        index: postIndex,
        child: Column(
          children: [
            MainImage(
              assets: assets,
            ),
            grid,
          ],
        ),
      ),
    );
  }

  _fetchAssets() async {
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );
    setState(() => assets = recentAssets);
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  Future<Uint8List> _futureUint8List(Future<Uint8List?> src) async {
    var completer = new Completer<Uint8List>();
    src.then((value) => completer.complete(value!));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _futureUint8List(asset.originBytes),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return CircularProgressIndicator();
        return Container(
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      },
    );
  }
}

class MainImage extends StatelessWidget {
  MainImage({
    Key? key,
    required this.assets,
  }) : super(key: key);

  final List<AssetEntity> assets;

  @override
  Widget build(BuildContext context) {
    var newIndex =
        _Inherited.of(context) == null ? 0 : _Inherited.of(context)!.index;

    return Container(
      width: 100.w,
      height: 100.w,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return AssetThumbnail(asset: assets[newIndex]);
        },
      ),
    );
  }
}

class _Inherited extends InheritedWidget {
  const _Inherited({
    Key? key,
    required this.index,
    required Widget child,
  }) : super(key: key, child: child);

  final int index;

  static _Inherited? of(BuildContext context) {
    final _Inherited? result =
        context.dependOnInheritedWidgetOfExactType<_Inherited>();
    return result;
  }

  @override
  bool updateShouldNotify(_Inherited old) => index != old.index;
}
