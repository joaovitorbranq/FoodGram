import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodlab/model/food.dart';
import 'package:foodlab/notifier/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodlab/model/user.dart';
import 'package:foodlab/notifier/food_notifier.dart';
import 'package:foodlab/screens/detail_food_page.dart';
import 'package:foodlab/screens/login_signup_page.dart';
import 'package:foodlab/screens/navigation_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

dynamic transition(context) => showDialog(
    context: context,
    builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator())));

//USER PART
login(User user, AuthNotifier authNotifier, BuildContext context) async {
  transition(context);
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error));

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;
    if (firebaseUser != null) {
      print("Log In: $firebaseUser");
      authNotifier.setUser(firebaseUser);
      await getUserDetails(authNotifier);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return NavigationBarPage(selectedIndex: 0);
        }),
      );
    }
  }
}

signUp(User user, AuthNotifier authNotifier, BuildContext context) async {
  bool userDataUploaded = false;
  transition(context);
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
          email: user.email.trim(), password: user.password)
      .catchError((error) => print(error));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.displayName;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);
      await firebaseUser.reload();

      print("Sign Up: $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

      authNotifier.setUser(currentUser);

      uploadUserData(user, userDataUploaded);

      await getUserDetails(authNotifier);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return NavigationBarPage(
            selectedIndex: 0,
          );
        }),
      );
    }
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  authNotifier.setUser(null);
  print('log out');
  Navigator.push(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return LoginPage();
    }),
  );
}

initializeCurrentUser(AuthNotifier authNotifier, BuildContext context) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
    await getUserDetails(authNotifier);
  }
}

uploadFoodAndImages(Food food, File localFile, BuildContext context) async {
  if (localFile != null) {
    print('uploading img file');

    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();
    transition(context);

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('images/$uuid$fileExtension');

    StorageUploadTask task = firebaseStorageRef.putFile(localFile);

    StorageTaskSnapshot taskSnapshot = await task.onComplete;

    String url = await taskSnapshot.ref.getDownloadURL();
    print('dw url $url');
    _uploadFood(food, context, imageUrl: url);
  } else {
    print('skipping img upload');
    _uploadFood(food, context);
  }
}

uploadProfilePic(File localFile, User user) async {
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  CollectionReference userRef = Firestore.instance.collection('users');

  if (localFile != null) {
    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();

    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('profilePictures/$uuid$fileExtension');

    StorageUploadTask task = firebaseStorageRef.putFile(localFile);

    StorageTaskSnapshot taskSnapshot = await task.onComplete;

    String profilePicUrl = await taskSnapshot.ref.getDownloadURL();
    print('dw url of profile img $profilePicUrl');

    try {
      user.profilePic = profilePicUrl;
      print(user.profilePic);
      await userRef.document(currentUser.uid).setData(
          {'profilePic': user.profilePic},
          merge: true).catchError((e) => print(e));
    } catch (e) {
      print(e);
    }
  } else {
    print('skipping profilepic upload');
  }
}

_uploadFood(Food food, BuildContext context, {String imageUrl}) async {
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  CollectionReference foodRef = Firestore.instance.collection('foods');
  bool complete = true;
  if (imageUrl != null) {
    print(imageUrl);
    try {
      food.img = imageUrl;
      print(food.img);
    } catch (e) {
      print(e);
    }

    food.createdAt = Timestamp.now();
    food.userUuidOfPost = currentUser.uid;
    await foodRef
        .add(food.toMap())
        .catchError((e) => print(e))
        .then((value) => complete = true);

    print('uploaded food successfully');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return NavigationBarPage(
            selectedIndex: 0,
          );
        },
      ),
    );
  }
  return complete;
}

uploadUserData(User user, bool userdataUpload) async {
  bool userDataUploadVar = userdataUpload;
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

  CollectionReference userRef = Firestore.instance.collection('users');
  user.uuid = currentUser.uid;
  if (userDataUploadVar != true) {
    await userRef
        .document(currentUser.uid)
        .setData(user.toMap())
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
  } else {
    print('already uploaded user data');
  }
  print('user data uploaded successfully');
}

getUserDetails(AuthNotifier authNotifier) async {
  await Firestore.instance
      .collection('users')
      .document(authNotifier.user.uid)
      .get()
      .catchError((e) => print(e))
      .then((value) => authNotifier.setUserDetails(User.fromMap(value.data)));
}

getAnotherUserDetails(AuthNotifier authNotifier, String uid) async {
  await Firestore.instance
      .collection('users')
      .document(uid)
      .get()
      .catchError((e) => print(e))
      .then((value) => authNotifier.setUserDetails(User.fromMap(value.data)));
}

getFoods(FoodNotifier foodNotifier) async {
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  QuerySnapshot snapshot = await Firestore.instance
      .collection('foods')
      .orderBy('createdAt', descending: true)
      .getDocuments();

  QuerySnapshot snapshotLikes = await Firestore.instance
      .collection('users')
      .document(currentUser.uid)
      .collection('likes')
      .getDocuments();

  List<Food> foodList = [];
  List<String> foodsLiked = [];
  List<int> nOfLikesList = [];
  List<bool> isLiked = [];
  List<Color> likeColor = [];
  List<String> likeRef = [];
  List<String> likeRef2 = [];

  await Future.forEach(snapshotLikes.documents, (doc) async {
    print(doc.data);
    foodsLiked.add(doc.data["foodUid"]);
    likeRef.add(doc.documentID);
  });

  await Future.forEach(snapshot.documents, (doc) async {
    Food food = Food.fromMap(doc.data);
    food.documentID = doc.documentID;
    await Firestore.instance
        .collection('users')
        .document(doc.data['userUuidOfPost'])
        .get()
        .catchError((e) => print(e))
        .then((value) {
      bool ifchecked = false;
      for (var i = 0; i < foodsLiked.length; i++) {
        if (foodsLiked[i] == food.documentID) {
          isLiked.add(true);
          likeColor.add(Colors.red);
          likeRef2.add(likeRef[i]);
          ifchecked = true;
        }
      }
      if (!ifchecked) {
        isLiked.add(false);
        likeColor.add(Colors.grey);
        likeRef2.add("");
      }
      /*
      if(foodsLiked.contains(food.documentID)){
        isLiked.add(true);
        likeColor.add(Colors.red);
        likeRef.add("temref");  
      }else{
        isLiked.add(false);
        likeColor.add(Colors.grey);
        likeRef.add("");
      }
      */

      if (doc.data["nOfLikes"] != null) {
        nOfLikesList.add(int.parse(doc.data["nOfLikes"]));
      } else {
        nOfLikesList.add(0);
      }

      food.userName = value.data['displayName'];
      food.profilePictureOfUser = value.data['profilePic'];
    }).whenComplete(() => foodList.add(food));

/*
    QuerySnapshot snapshot = await Firestore.instance
        .collection('foods')
        .document(doc.documentID)
        .collection("comments")
        .getDocuments();

    food.comments = List<Comment>();

    await Future.forEach(snapshot.documents, (doc) async {
      //print(doc.data);
      if (doc.data["text"] != null) {
        Comment comment = Comment();
        await Firestore.instance
            .collection('users')
            .document(doc.data['userUuidOfPost'])
            .get()
            .catchError((e) => print(e))
            .then((value) {
          print(value.data);
          //if (value != null){
          comment.userProfilePic = value.data['profilePic'];
          //}
        });

        comment.text = doc.data["text"];
        food.comments.add(comment);
        //print(comment);
      }
    });
    */
  });

  if (foodList.isNotEmpty) {
    foodNotifier.foodList = foodList;
    foodNotifier.isLiked = isLiked;
    foodNotifier.likeColor = likeColor;
    foodNotifier.nOfLikesList = nOfLikesList;
    foodNotifier.likeRef = likeRef2;
  }
}

// START OF BLOCK
//Added by Lucio and Branquinho
likeComment() {}

uploadComment(String foodUrl, String comment, BuildContext context) async {
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  print('Uploading comment');
  CollectionReference commentRef = Firestore.instance
      .collection('foods')
      .document('$foodUrl')
      .collection('comments');
  await commentRef
      .add({"text": comment, "userUuidOfPost": currentUser.uid}).catchError(
          (e) => print(e));

  print('Comment uploaded succesfully');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) {
        return NavigationBarPage(
          selectedIndex: 0,
        );
      },
    ),
  );
}

likePressHandler(bool likeState, BuildContext context, String likeRef,
    String foodRef, int nOfLikes, List<String> likeRefsInd, int index) async {
  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  print(likeRef);
  //If like, then delete
  if (likeState) {
    print('Deleting like');
    CollectionReference likesRef = Firestore.instance.collection('users');
    likesRef
        .document(currentUser.uid)
        .collection("likes")
        .document(likeRef)
        .delete()
        .then((value) => plusOrLess1Like(foodRef, nOfLikes - 1))
        .catchError((error) => print("failed to delete like on post: $error"));
  }
  // Else, add like
  else {
    print('Uploading like');
    CollectionReference likeRef = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('likes');
    DocumentReference docRef =
        await likeRef.add({"likedat": "", "foodUid": foodRef});
    plusOrLess1Like(foodRef, nOfLikes + 1);
    likeRefsInd[index] = docRef.documentID;
    print(docRef.documentID);

    /*.then((value) => plusOrLess1Like(foodRef, nOfLikes+1))
      .catchError(
          (e) => print(e));
        */

    print('Like added succesfully');
  }
}

plusOrLess1Like(String foodRef, nOfLikes) async {
  CollectionReference foodInstance = Firestore.instance.collection('foods');
  foodInstance.document(foodRef).updateData({"nOfLikes": "$nOfLikes"});
}
// Added by Lucio and Branquinho
// END OF BLOCK

Future<void> deleteFood(BuildContext context, {String aux}) {
  CollectionReference foodRef = Firestore.instance.collection('foods');
  foodRef
      .document(aux)
      .delete()
      .then((value) => print("Post deletado"))
      .catchError((error) => print("failed to delete user: $error"));
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) {
        return NavigationBarPage(
          selectedIndex: 0,
        );
      },
    ),
  );
}

Future<void> updateFood(BuildContext context, Edicao json,
    {String documentID}) {
  CollectionReference foodRef = Firestore.instance.collection('foods');
  foodRef
      .document(documentID)
      .setData(json.toMap())
      .then((value) => print("Post Atualizado"))
      .catchError((error) => print("failed to atualize user: $error"));
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) {
        return NavigationBarPage(
          selectedIndex: 0,
        );
      },
    ),
  );
}
