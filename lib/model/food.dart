import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  String name;
  String img;
  String caption;
  String userUuidOfPost;
  Timestamp createdAt;
  int qtdLike;
  String documentID;

  //User details
  String userName;
  String profilePictureOfUser;

  Food();

  Food.fromMap(Map<String, dynamic> data) {
    print(data);
    name = data['name'];
    img = data['img'];
    caption = data['caption'];
    createdAt = data['createdAt'];
    userUuidOfPost = data['userUuidOfPost'];
    documentID = data['documentID'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'img': img,
      'caption': caption,
      'createdAt': createdAt,
      'userUuidOfPost': userUuidOfPost,
      'documentID': documentID
    };
  }
}
