import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:notification_board/providers/auth.dart';
import 'package:notification_board/providers/notificationn.dart';
import 'package:notification_board/screens/comment_screen.dart';
import 'package:notification_board/screens/notificationn_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notifications.dart';

class NotificationsGrid extends StatelessWidget {
  final bool showFavs;

  NotificationsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final notificationsData = Provider.of<Notifications>(context);
    final notifications = showFavs ? notificationsData.favoriteItems : notificationsData.items;
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return MyCustomGridView(notificationsList: notifications,);
  }
}
class MyCustomGridView extends StatefulWidget {
  final List<Notificationn> notificationsList;
  const MyCustomGridView({Key key,this.notificationsList}) : super(key: key);
  @override
  _MyCustomGridViewState createState() => _MyCustomGridViewState();
}

class _MyCustomGridViewState extends State<MyCustomGridView> {

  List<GlobalKey<State<StatefulWidget>>> containerKeyList = [];
  @override void initState() {
    containerKeyList = List.generate(widget.notificationsList.length, (index) => GlobalKey<State<StatefulWidget>>());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;
    return ListView(
      children: [
        if(MediaQuery.of(context).size.shortestSide > 600)
          for(int index=0;index<widget.notificationsList.length;index+=5)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  /// 1st
                  myCustomContainer(index, context,(width/5),((width/5)-8),containerKeyList[index]),
                  SizedBox(width: 5,),
                  /// 2nd
                  index+1<widget.notificationsList.length?
                  myCustomContainer(index+1, context,(width/5),((width/5)-8),containerKeyList[index+1])
                      :SizedBox(),
                  /// 3rd
                  SizedBox(width: 5,),
                  index+2<widget.notificationsList.length?
                  myCustomContainer(index+1, context,(width/5),((width/5)-8),containerKeyList[index+2])
                      :SizedBox(),
                  /// 4th
                  SizedBox(width: 5,),
                  index+3<widget.notificationsList.length?
                  myCustomContainer(index+1, context,(width/5),((width/5)-8),containerKeyList[index+3])
                      :SizedBox(),
                  /// 5th
                  SizedBox(width: 5,),
                  index+1<widget.notificationsList.length?
                  myCustomContainer(index+4, context,(width/5),((width/5)-8),containerKeyList[index+4])
                      :SizedBox(),
                ],
              ),
            )
        else
          for(int index=0;index<widget.notificationsList.length;index+=2)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  myCustomContainer(index, context,(width/2),((width/2)-7),containerKeyList[index]),
                  SizedBox(width: 5,),
                  index+1<widget.notificationsList.length?
                  myCustomContainer(index+1, context,(width/2),((width/2)-7),containerKeyList[index+1])
                      :SizedBox(),
                ],
              ),
            ),
      ],
    );
  }

  Offset childOffset = Offset(0, 0);
  Size childSize;
  Future openMenu(BuildContext context,containerKey,Widget child,int index) async {
    getOffset(containerKey);
    await Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              animation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child: FocusedMenuDetails(
                    itemExtent: 50,
                    menuBoxDecoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: child,
                    childOffset: childOffset,
                    childSize: childSize,
                    menuItems: [
                      FocusedMenuItem(
                          title: Text("Favourite"),
                          onPressed: (){
                            final authData = Provider.of<Auth>(context, listen: false);
                            widget.notificationsList[index].toggleFavoriteStatus(
                              authData.token,
                              authData.userId,
                              widget.notificationsList[index].id,
                            );
                            setState(() {

                            });
                          },
                          trailingIcon: Icon(
                            widget.notificationsList[index].isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:  widget.notificationsList[index].isFavorite
                                ? Theme.of(context).accentColor
                                : Colors.black,
                          )
                      ),
                      FocusedMenuItem(
                        title: Text("Comment"),
                        trailingIcon: Icon(Icons.comment,
                            color: Colors.black, size: 25.0),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Comments(
                                    notificationId: widget.notificationsList[index].id.toString(),
                                  )));
                        },
                      ),
                    ],
                    blurSize: 2,
                    menuWidth:200,
                    blurBackgroundColor:Colors.transparent,
                    animateMenu: true,
                    bottomOffsetHeight:  0,
                    menuOffset: 0,
                  ));
            },
            fullscreenDialog: true,
            opaque: false));
  }
  getOffset(containerKey){
    RenderBox renderBox = containerKey.currentContext?.findRenderObject() as RenderBox;
    Size size = renderBox?.size;
    Offset offset = renderBox?.localToGlobal(Offset.zero);
    setState(() {
      this.childOffset = Offset(offset?.dx, offset?.dy);
      childSize = size;
    });
  }

  Widget myCustomContainer(int index,context,double height,double width,GlobalKey<State<StatefulWidget>> containerKey){
    var format = new DateFormat.yMMMMd("en_us").add_jm();
    var date = format.format(DateTime.parse(widget.notificationsList[index].timestamp));
    return GestureDetector(
      key: containerKey,
      onTap: (){
        Navigator.of(context).pushNamed(
          NotificationnDetailScreen.routeName,
          arguments: widget.notificationsList[index].id,
        );
      },
      onLongPress: ()async{
        openMenu(context,containerKey,childOfGestureDetector(index, context, height, width, date),index);
      },
      child: childOfGestureDetector(index, context, height, width, date),
    );
  }
  Widget childOfGestureDetector(int index,context,double height,double width,date){
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: widget.notificationsList[index].noticetype=="Normal"?Colors.green:Colors.red,width: 2),
          borderRadius: BorderRadius.circular(12)
      ),
      child: Stack(
        // alignment: Alignment.bottomLeft,
        children: [
          widget.notificationsList[index].imageUrl!=null&&widget.notificationsList[index].imageUrl.isNotEmpty?
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl:widget.notificationsList[index].imageUrl,
                cacheManager: DefaultCacheManager(),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Container(
                      height: height,
                      width: width,
                      child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                fit:BoxFit.cover,
                height: height,
                width: width,
                useOldImageOnUrlChange: false,
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          )
              :Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black87,),
              height: height,
              width: width,
              child: Container(
                margin: EdgeInsets.only(top: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.notificationsList[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Text(
                      widget.notificationsList[index].description,
                      //maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.yellow[100],
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          widget.notificationsList[index].noticetype=="Important"?
          Positioned(
            top: 0,
            child: Container(
              height: 30,
              width: width,
              decoration:BoxDecoration(
                color: Colors.black.withOpacity(.6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ) ,
              child: Center(
                child: Text(
                  'Important',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ):SizedBox(),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 5),
              height: 30,
              width: width,
              decoration:BoxDecoration(
                color: Colors.black.withOpacity(.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ) ,
              child: Center(
                child: Text(
                  '$date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FocusedMenuDetails extends StatelessWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration menuBoxDecoration;
  final Offset childOffset;
  final double itemExtent;
  final Size childSize;
  final Widget child;
  final bool animateMenu;
  final double blurSize;
  final double menuWidth;
  final Color blurBackgroundColor;
  final double bottomOffsetHeight;
  final double menuOffset;

  const FocusedMenuDetails(
      {Key key, @required this.menuItems, @required this.child, @required this.childOffset, @required this.childSize,@required this.menuBoxDecoration, @required this.itemExtent,@required this.animateMenu,@required this.blurSize,@required this.blurBackgroundColor,@required this.menuWidth, this.bottomOffsetHeight, this.menuOffset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = menuItems.length * (itemExtent ?? 50.0);

    final maxMenuWidth = menuWidth??(size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (childOffset.dx+maxMenuWidth ) < size.width ? childOffset.dx: (childOffset.dx-maxMenuWidth+childSize.width);
    final topOffset = (childOffset.dy + menuHeight + childSize.height) < size.height - bottomOffsetHeight ? childOffset.dy + childSize.height + menuOffset : childOffset.dy - menuHeight - menuOffset;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSize??4, sigmaY: blurSize??4),
                  child: Container(
                    color: (blurBackgroundColor??Colors.black).withOpacity(0.7),
                  ),
                )),
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, dynamic value, Widget child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: Container(
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: menuBoxDecoration ??
                      BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [const BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1)]),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      padding: EdgeInsets.zero,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        FocusedMenuItem item = menuItems[index];
                        Widget listItem = GestureDetector(
                            onTap:
                                () {
                              Navigator.pop(context);
                              item.onPressed();

                            },
                            child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(bottom: 1),
                                color: item.backgroundColor ?? Colors.white,
                                height: itemExtent ?? 50.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      item.title,
                                      if (item.trailingIcon != null) ...[item.trailingIcon]
                                    ],
                                  ),
                                )));
                        if (animateMenu) {
                          return TweenAnimationBuilder(
                              builder: (context, dynamic value, child) {
                                return Transform(
                                  transform: Matrix4.rotationX(1.5708 * value),
                                  alignment: Alignment.bottomCenter,
                                  child: child,
                                );
                              },
                              tween: Tween(begin: 1.0, end: 0.0),
                              duration: Duration(milliseconds: index * 200),
                              child: listItem);
                        } else {
                          return listItem;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(top: childOffset.dy, left: childOffset.dx, child: AbsorbPointer(absorbing: true, child: Container(
                width: childSize.width,
                height: childSize.height,
                child: child))),
          ],
        ),
      ),
    );
  }
}
class FocusedMenuItem {
  Color backgroundColor;
  Widget title;
  Icon trailingIcon;
  Function onPressed;

  FocusedMenuItem(
      {this.backgroundColor,
        @required this.title,
        this.trailingIcon,
        @required this.onPressed});
}