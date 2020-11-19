import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodlab/notifier/food_notifier.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:intl/intl.dart';
import 'package:foodlab/model/food.dart';
import 'package:foodlab/api/food_api.dart';
import 'package:foodlab/widget/custom_raised_button.dart';
import 'package:provider/provider.dart';

class Edicao {
  String caption;
  String name;
  Timestamp createdAt;
  String img;
  String userUuidOfPost;

  Edicao(
      this.caption, this.name, this.createdAt, this.img, this.userUuidOfPost);

  Map<String, dynamic> toMap() {
    return {
      "caption": caption,
      "name": name,
      "createdAt": createdAt,
      "img": img,
      "userUuidOfPost": userUuidOfPost
    };
  }
}

class FoodDetailPage extends StatelessWidget {
  final String imgUrl;
  final String imageName;
  final String imageCaption;
  final String userName;
  final String foodUrl;
  final String documentID;
  final DateTime createdTimeOfPost;
  String userUuidOfPost;
  List<Comment> comments;
  String text_comment;
  bool ehEdit;
  Edicao editando; // vai dar probs se ba
  int index;

  /////
  ////
  ////
  TextEditingController _caption = TextEditingController();
  TextEditingController _name = TextEditingController();

  FoodDetailPage({
    @required this.imgUrl,
    @required this.imageName,
    @required this.imageCaption,
    this.userName,
    this.createdTimeOfPost,
    this.comments,
    this.foodUrl,
    this.documentID,
    this.text_comment,
    this.ehEdit = false,
    this.index,
    this.userUuidOfPost,
  }) : editando = Edicao(
          imageCaption,
          imageName,
          Timestamp.fromDate(createdTimeOfPost),
          imgUrl,
          userUuidOfPost,
        );

  _save(context) async {
    //uploadFoodAndImages(food, _imageFile, context);
    uploadComment(documentID, text_comment, context);
    return;
  }

  Food editaAlimento({Food comida, String name, String caption}) {
    return Food(
        name: name,
        caption: caption,
        img: comida.img,
        createdAt: comida.createdAt,
        userUuidOfPost: comida.userUuidOfPost,
        documentID: comida.documentID,
        comments: comida.comments,
        userName: comida.userName,
        profilePictureOfUser: comida.profilePictureOfUser);
  }

  @override
  Widget build(BuildContext context) {
    FoodNotifier foodNotifier =
        Provider.of<FoodNotifier>(context, listen: true);
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 30, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Details',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 138, 120, 1),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ehEdit == false
                      ? Text(
                          imageName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : TextFormField(
                          autofocus: false,
                          controller: _name,
                          onChanged: (value) {
                            editando.name = value;
                          },
                          decoration: InputDecoration(
                              labelText: imageName,
                              labelStyle: TextStyle(
                                fontSize: 14,
                              )),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  ehEdit == false
                      ? Text(
                          imageCaption,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        )
                      : TextFormField(
                          autofocus: false,
                          controller: _caption,
                          onChanged: (value) => editando.caption = value,
                          decoration: InputDecoration(
                              labelText: imageCaption,
                              labelStyle: TextStyle(
                                fontSize: 14,
                              )),
                        ),
                  userName != null
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: GradientText(
                              userName,
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(255, 138, 120, 1),
                                  Color.fromRGBO(255, 63, 111, 1),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'MuseoModerno',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          '',
                        ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      DateFormat.yMMMd().add_jm().format(
                            createdTimeOfPost,
                          ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(255, 138, 120, 1),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ehEdit == false
                      ? comments != null
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  for (var item in comments)
                                    Row(
                                      children: <Widget>[
                                        item.userProfilePic != null
                                            ? CircleAvatar(
                                                radius: 24.0,
                                                backgroundImage: NetworkImage(
                                                    item.userProfilePic),
                                                backgroundColor:
                                                    Colors.transparent,
                                              )
                                            : CircleAvatar(
                                                radius: 24.0,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.red[500],
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            padding: EdgeInsets.all(10.0),
                                            margin:
                                                EdgeInsets.only(bottom: 10.0),
                                            //color: Colors.grey.shade200,
                                            child: Text(item.text),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            )
                          : //Text("No comments to display"),
                          SizedBox(height: 0)
                      : SizedBox(
                          height: 25,
                        ),
                  ehEdit == false
                      ? Container(
                          //padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: TextField(
                            onChanged: (String value) {
                              text_comment = value;
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[100],
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: Colors.red[500])),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 10.0, left: 10.0, right: 10.0),
                              labelText: 'Add a new comment',
                            ),
                            //onTap: _save(context),
                          ),
                        )
                      : SizedBox(
                          width: 0,
                        ),
                  ehEdit == false
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              _save(context);
                            },
                            child: CustomRaisedButton(
                              buttonText: 'Comentar',
                            ),
                          ),
                        )
                      : Center(
                          child: GestureDetector(
                            onTap: () {
                              print('Salvou');
                              Food _alimento = editaAlimento(
                                  comida: foodNotifier.foodList[index],
                                  name: editando.name,
                                  caption: editando.caption);
                              print(_alimento.name);
                              print(_alimento.img);
                              String documentID = _alimento.documentID;
                              updateFood(context, editando,
                                  documentID: documentID);
                              Food procurado = foodNotifier.foodList[index];
                              List<Food> aux = List<Food>();
                              foodNotifier.foodList.forEach((element) {
                                if (element == procurado)
                                  aux.add(_alimento);
                                else
                                  aux.add(element);
                              });
                              foodNotifier.setFood(aux);
                            },
                            child: CustomRaisedButton(
                              buttonText: 'Salvar',
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
