// import 'package:flutter/material.dart';
// import 'package:notification_board/screens/comment_screen.dart';
// import 'package:provider/provider.dart';
// import '../screens/notificationn_detail_screen.dart';
// import '../providers/notificationn.dart';
// import '../providers/auth.dart';
//
// class NotificationnItem extends StatelessWidget {
//   String date;
//
//   NotificationnItem(this.date);
//
//   @override
//   Widget build(BuildContext context) {
//     final notificationn = Provider.of<Notificationn>(context, listen: false);
//     //final cart = Provider.of<Cart>(context, listen: false);
//     final authData = Provider.of<Auth>(context, listen: false);
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.black87,
//       ),
//       child: GestureDetector(
//     child:
//       notificationn.noticetype == 'Normal'
//           ? Column(
//               children: <Widget>[
//                 notificationn.imageUrl!=null && notificationn.imageUrl.isNotEmpty ?
//                 ClipRRect(
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10.0),
//                       topRight: Radius.circular(10.0)),
//                   child: Hero(
//                     tag: notificationn.id,
//                     child: FadeInImage(
//                       placeholder: AssetImage(
//                           'assets/images/notificationn-placeholder.png'),
//                       image: NetworkImage(notificationn.imageUrl),
//                       //fit: BoxFit.cover,
//                       //filterQuality: FilterQuality.high,
//                       width: MediaQuery.of(context).size.width,
//                       //height: MediaQuery.of(context).size.width,
//                       height: 140,
//                       fit: BoxFit.cover,
//                       //color: Colors.black45,
//                       //colorBlendMode: BlendMode.darken,
//                     ),
//                   ),
//                 ):SizedBox(),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: 40,
//                     decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                             colors: [Colors.grey[400], Color(0xff101010)],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter)),
//                   ),
//                 ),
//                 Container(
//                   //decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black87,),
//                   margin: EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(notificationn.title,
//                           style: TextStyle(
//                               color: Colors.yellow,
//                               fontSize: 20.0,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(height: 10.0),
//                       Text(
//                         notificationn.description,
//                         maxLines: 2,
//                         style: TextStyle(
//                           color: Colors.yellow[100],
//                           fontSize: 13.0,
//                         ),
//                       ),
//                       Container(
//                         width: MediaQuery.of(context).size.width,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Consumer<Notificationn>(
//                               builder: (ctx, notificationn, _) => IconButton(
//                                 icon: Icon(
//                                   notificationn.isFavorite
//                                       ? Icons.favorite
//                                       : Icons.favorite_border,
//                                 ),
//                                 color: notificationn.isFavorite
//                                     ? Theme.of(context).accentColor
//                                     : Colors.yellow[200],
//                                 onPressed: () {
//                                   notificationn.toggleFavoriteStatus(
//                                     authData.token,
//                                     authData.userId,
//                                   );
//                                 },
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.comment,
//                                   color: Colors.yellow[200], size: 25.0),
//                               onPressed: () {
//                                 Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) => Comments(
//                                                     notificationId: notificationn.id.toString(),
//                                                   )));
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.share,
//                                   color: Colors.yellow[200], size: 25.0),
//                               onPressed: () {},
//                             ),
//                             Spacer(),
//                             Text(
//                               '$date',
//                               style: TextStyle(
//                                 color: Colors.yellow[100],
//                                 fontSize: 13.0,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 5.0),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : notificationn.noticetype == 'Important'
//               ? Stack(
//                   children: [
//                     Container(
//                       margin: EdgeInsets.only(left: 15),
//                       padding: const EdgeInsets.only(left: 2,top: 2),
//                       height: 15,
//                       width: 200,
//                       color: Colors.black,
//                       child: Text(
//                         'Important',
//                         style: TextStyle(color: Colors.redAccent[700]),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10.0),
//                           border: Border.all(
//                             color: Colors.red,
//                             width: 2,
//                           )),
//                       padding: EdgeInsets.only(
//                         top: 15,
//                         bottom: 8,
//                         left: 8,
//                         right: 8,
//                       ),
//                       child: Column(
//                         children: <Widget>[
//                           notificationn.imageUrl!=null && notificationn.imageUrl.isNotEmpty ?
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.of(context).pushNamed(
//                                 NotificationnDetailScreen.routeName,
//                                 arguments: notificationn.id,
//                               );
//                             },
//                             onDoubleTap: () {},
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10.0),
//                                   topRight: Radius.circular(10.0)),
//                               child: Hero(
//                                 tag: notificationn.id,
//                                 child: FadeInImage(
//                                   placeholder: AssetImage(
//                                       'assets/images/notificationn-placeholder.png'),
//                                   image: NetworkImage(notificationn.imageUrl),
//                                   //fit: BoxFit.cover,
//                                   //filterQuality: FilterQuality.high,
//                                   width: MediaQuery.of(context).size.width,
//                                   //height: MediaQuery.of(context).size.width,
//                                   height: 140,
//                                   fit: BoxFit.cover,
//                                   //color: Colors.black45,
//                                   //colorBlendMode: BlendMode.darken,
//                                 ),
//                               ),
//                             ),
//                           ):SizedBox(),
//                           Align(
//                             alignment: Alignment.bottomCenter,
//                             child: Container(
//                               width: MediaQuery.of(context).size.width,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                       colors: [
//                                     Colors.grey[400],
//                                     Color(0xff101010)
//                                   ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter)),
//                             ),
//                           ),
//                           Container(
//                             //decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black87,),
//                             margin: EdgeInsets.symmetric(horizontal: 10.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(notificationn.title,
//                                     style: TextStyle(
//                                         color: Colors.yellow,
//                                         fontSize: 20.0,
//                                         fontWeight: FontWeight.bold)),
//                                 SizedBox(height: 10.0),
//                                 Text(
//                                   notificationn.description,
//                                   maxLines: 2,
//                                   style: TextStyle(
//                                     color: Colors.yellow[100],
//                                     fontSize: 13.0,
//                                   ),
//                                 ),
//                                 Container(
//                                   width: MediaQuery.of(context).size.width,
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       Consumer<Notificationn>(
//                                         builder: (ctx, notificationn, _) =>
//                                             IconButton(
//                                           icon: Icon(
//                                             notificationn.isFavorite
//                                                 ? Icons.favorite
//                                                 : Icons.favorite_border,
//                                           ),
//                                           color: notificationn.isFavorite
//                                               ? Theme.of(context).accentColor
//                                               : Colors.yellow[200],
//                                           onPressed: () {
//                                             notificationn.toggleFavoriteStatus(
//                                               authData.token,
//                                               authData.userId,
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       IconButton(
//                                         icon: Icon(Icons.comment,
//                                             color: Colors.yellow[200],
//                                             size: 25.0),
//                                         onPressed: () {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) => Comments(
//                                                     notificationId:
//                                                     notificationn.id.toString(),
//                                                   )));
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: Icon(Icons.share,
//                                             color: Colors.yellow[200],
//                                             size: 25.0),
//                                         onPressed: () {},
//                                       ),
//                                       Spacer(),
//                                       Text(
//                                         '$date',
//                                         style: TextStyle(
//                                           color: Colors.yellow[100],
//                                           fontSize: 13.0,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(height: 5.0),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 )
//               : Column(
//                   children: [],
//                 ),
//       onTap: () {
//         Navigator.of(context).pushNamed(
//           NotificationnDetailScreen.routeName,
//           arguments: notificationn.id,
//         );
//       },
//       )
//     );
//   }
// }
