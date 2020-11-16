import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:intl/intl.dart';
import 'package:foodlab/model/food.dart';
import 'package:foodlab/api/food_api.dart';
import 'package:foodlab/widget/custom_raised_button.dart';

class FoodDetailPage extends StatelessWidget {
  final String imgUrl;
  final String imageName;
  final String imageCaption;
  final String userName;
  final String foodUrl;
  final String documentID;
  final DateTime createdTimeOfPost;
  List<Comment> comments;
  String text_comment;

  FoodDetailPage({
    @required this.imgUrl,
    @required this.imageName,
    @required this.imageCaption,
    this.userName,
    this.createdTimeOfPost,
    this.comments,
    this.foodUrl,
    this.documentID,
    this.text_comment
  });

  _save(context) async {
    //uploadFoodAndImages(food, _imageFile, context);
    uploadComment(documentID, text_comment, context);
    return;
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    imageName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    imageCaption,
                    style: TextStyle(
                      fontSize: 14,
                    ),
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
                  comments != null
                      ? Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,                          
                          children: <Widget>[
                            for(var item in comments ) 
                            Row(
                              children: <Widget>[
                                item.userProfilePic !=
                                        null
                                    ? CircleAvatar(
                                        radius: 24.0,
                                        backgroundImage: NetworkImage(
                                            item.userProfilePic
                                            ),
                                        backgroundColor: Colors.transparent,
                                      )
                                    : CircleAvatar(
                                        radius: 24.0,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.red[500],
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    margin: EdgeInsets.only(bottom: 10.0),
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
                      SizedBox(height: 0),
                  Container(
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
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.red[500])),
                        filled: true,
                        contentPadding:
                        EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                        labelText: 'Add a new comment',
                      ),
                      //onTap: _save(context),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                          _save(context);                 
                      },
                      child: CustomRaisedButton(
                        buttonText: 'Post',
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
