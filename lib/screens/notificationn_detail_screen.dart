import 'dart:io';
import 'dart:typed_data';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
class NotificationnDetailScreen extends StatelessWidget {

  static const routeName = '/notificationn-detail';

  bool isDownloadingImage = false;
  @override
  Widget build(BuildContext context) {
    final notificationnId =
    ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedNotificationn = Provider.of<Notifications>(
      context,
      listen: false,
    ).findById(notificationnId);
    return Scaffold(
      // appBar: AppBar
      // (
      //   title: Text('Notification Detail', ),],
      // ),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: loadedNotificationn.imageUrl.isNotEmpty&&loadedNotificationn.imageUrl!=null?300:0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedNotificationn.title),
              background: Hero(
                tag: loadedNotificationn.id,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      width: double.infinity,
                      child: loadedNotificationn.imageUrl.isNotEmpty&&loadedNotificationn.imageUrl!=null?
                      Image.network(
                        loadedNotificationn.imageUrl,
                        fit: BoxFit.cover,
                      ):SizedBox(),
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState){
                            return GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: isDownloadingImage?CircularProgressIndicator():
                                Icon(
                                  Icons.download_sharp,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onTap: () async {
                                try {
                                  setState((){
                                    isDownloadingImage = true;
                                  });
                                  await downloadImage(loadedNotificationn.imageUrl);
                                  setState((){
                                    isDownloadingImage = false;
                                  });
                                  Fluttertoast.showToast(msg: 'Image downloaded');
                                } on PlatformException catch (error) {
                                  setState((){
                                    isDownloadingImage = false;
                                  });
                                  Fluttertoast.showToast(msg: 'Image failed to download');
                                  print(error);
                                }
                              },
                            );
                          },
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedNotificationn.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> downloadImage(String imageUrl) async {
    try {
      final http.Response r = await http.get(
        Uri.parse(imageUrl),
      );
      final Uint8List imageBytesData = r.bodyBytes;
      String dir = (await getApplicationDocumentsDirectory()).path;
      print("Directory---> ${await getApplicationDocumentsDirectory()}");
      File file = File("$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg");
      await file.writeAsBytes(imageBytesData);
      GallerySaver.saveImage(file.path,albumName: "Noticeboard");
    } catch (e) {
      print(e);
    }
  }
}