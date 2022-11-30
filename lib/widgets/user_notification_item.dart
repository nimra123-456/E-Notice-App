import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_notificationn_screen.dart';
import '../providers/notifications.dart';

class UserNotificationnItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final Function deleteCallBack;

  UserNotificationnItem(this.id, this.title, this.imageUrl,this.deleteCallBack);


  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: imageUrl!=null && imageUrl.isNotEmpty ?
      CircleAvatar(
        backgroundImage: NetworkImage(imageUrl)
      )
          :CircleAvatar(
        child: Icon(Icons.image_not_supported_outlined),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                  this.deleteCallBack(id);
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
