import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String text;
  String userUuidOfPost; 
  String userProfilePic;
  final DateTime commentedAt;
  //List<Like> likes;

  /*
  bool isLikedBy(User user) {
    return likes.any((like) => like.user.name == user.name);
  }

  void toggleLikeFor(User user) {
    if (isLikedBy(user)) {
      likes.removeWhere((like) => like.user.name == user.name);
    } else {
      likes.add(Like(user: user));
    }
  }


   */
  Comment({
    this.text,
    this.commentedAt,
    //this.likes,
    this.userUuidOfPost,
    this.userProfilePic,
  });
}

/*
class Like {
  final User user;

  Like({@required this.user});
}
*/

class Food {
  String name;
  String img;
  String caption;
  String userUuidOfPost;
  Timestamp createdAt;
  List<Comment> comments = List<Comment>();
  int qtdLike;
  String documentID;

  //User details
  String userName;
  String profilePictureOfUser;

  Food();

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
      'comments' : comments,
    };
  }
}
