import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String text;
  String userUuidOfPost;
  String userProfilePic;
  final DateTime commentedAt;

  Comment({
    this.text,
    this.commentedAt,
    this.userUuidOfPost,
    this.userProfilePic,
  });
}

/*class Like {
  String userUuidOfPost;
  String postReference;
}*/

class Food {
  String name;
  String img;
  String caption;
  String userUuidOfPost;
  Timestamp createdAt;
  List<dynamic> comments = List<dynamic>();
  int qtdLike;
  String documentID;

  //User details
  String userName;
  String profilePictureOfUser;

  Food(
      {this.name,
      this.img,
      this.caption,
      this.userUuidOfPost,
      this.createdAt,
      this.comments,
      this.qtdLike,
      this.documentID,
      this.userName,
      this.profilePictureOfUser});

  Food.fromMap(Map<String, dynamic> data) {
    //print(data);
    name = data['name'];
    img = data['img'];
    caption = data['caption'];
    createdAt = data['createdAt'];
    userUuidOfPost = data['userUuidOfPost'];
    documentID = data['documentID'];
    comments = data['comments'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'img': img,
      'caption': caption,
      'createdAt': createdAt,
      'userUuidOfPost': userUuidOfPost,
      'documentID': documentID,
      'comments': comments,
    };
  }
}
