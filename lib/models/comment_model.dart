import 'package:flutter/material.dart';

class CommentModel{
  final String userName;
  final String image;
  final String comment;
  final String commentTime;

  CommentModel({
    @required this.userName,
    @required this.image,
    @required this.comment,
    @required this.commentTime,
  });
}