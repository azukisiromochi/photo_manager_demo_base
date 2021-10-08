import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Manager Demo',
      home: Material(
        child: Center(
          child: Builder(builder: (context) {
            return RaisedButton(
              // make the function async
              onPressed: () async {
                // ### Add the next 2 lines ###
                final permitted = await PhotoManager.requestPermission();
                if (!permitted) return;
                // ######
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Gallery()),
                );
              },
              child: Text('Open Gallery'),
            );
          }),
        ),
      ),
    );
  }
}

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {

  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gallery'),
        ),
        body: Center(
          // Modify this line as follows
          child: Text('There are ${assets.length} assets'),
        )
    );
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }
}
