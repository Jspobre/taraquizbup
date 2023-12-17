import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taraquizbup/proDashboard/proDashboard.dart';

class DisplayQuestions extends StatefulWidget {
  final Map data;
  final String fileName;
  final String subjectCode;

  final String uid;

  final List<String> testCodeList;
  final int index;
  final List<Map> testDetailsList;
  final String path;


  const DisplayQuestions(
      {Key? key,
        required this.path,
        required this.index,
        required this.fileName,
      required this.subjectCode,
      required this.testCodeList,
      required this.testDetailsList,
      required this.uid,
      required this.data})
      : super(key: key);

  @override
  _DisplayQuestionsState createState() => _DisplayQuestionsState();
}

class _DisplayQuestionsState extends State<DisplayQuestions> {
  String finalString = "";
  bool ready =false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      List tempVal001 = List.empty(growable: true);
      widget.data.forEach((key, value) {
        tempVal001.add(value);
      });
      for (int i = 5; i < tempVal001.length; i++) {
        if (tempVal001.elementAt(i).toString() == "True/False" || tempVal001.elementAt(i).toString() == "Fill up the Blanks") break;
       finalString = "$finalString\n${tempVal001.elementAt(i)}\n";
        i++;
        finalString = "$finalString\noptions\n";
        finalString = "$finalString${tempVal001.elementAt(i)}\n";
        i++;
        finalString = "$finalString${tempVal001.elementAt(i)}\n";
        i++;
        finalString = "$finalString${tempVal001.elementAt(i)}\n";
        i++;
        finalString = "$finalString${tempVal001.elementAt(i)}\n";
        i++;
        finalString = "$finalString\nAnswers:\n";
        finalString = "$finalString${tempVal001.elementAt(i)}\n";
      }
      for (int i = 5; i < tempVal001.length; i++) {
        if (tempVal001.elementAt(i).toString() == "True/False") {
          i++;

          for(;i < tempVal001.length; i++) {
            if (tempVal001.elementAt(i).toString() == "Fill up the Blanks"){
              break;
            }
            if (tempVal001.elementAt(i).toString() == "null"){
              break;
            }

            finalString = "$finalString\n${tempVal001.elementAt(i)}\n";
            i++;
            finalString = "$finalString\nAnswers:\n";
            finalString = "$finalString${tempVal001.elementAt(i)}\n";
          }

        }
        if (tempVal001.elementAt(i).toString() == "Fill up the Blanks") {

          i++;

          for(;i < tempVal001.length; i++) {
            if (tempVal001.elementAt(i).toString() == "True/False"){
              break;
            }
            if (tempVal001.elementAt(i).toString() == "null"){
              break;
            }

            finalString = "$finalString\n${tempVal001.elementAt(i)}\n";
            i++;
            finalString = "$finalString\nAnswers:\n";
            finalString = "$finalString${tempVal001.elementAt(i)}\n";
          }
        }
        if (tempVal001.elementAt(i).toString().split("://").length > 1){
          finalString = "$finalString\nList: ";
          finalString = "$finalString${tempVal001.elementAt(i)}";          }
      }
    });
    Future.delayed(Duration(seconds: 3),(){
      setState(() {
        ready = true;
      });
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Preview"),
      ),
      body: SingleChildScrollView(
        child: ready ? Column(
          children: [
            Padding(padding: const EdgeInsets.all(8.0),child: SizedBox(child: Text(finalString, maxLines: 1000, ),),),
            Padding(padding: EdgeInsets.all(8.0), child: ElevatedButton(child: Text("Upload"), onPressed: ()
            async {
              final storageRef = FirebaseStorage.instance.ref();
              final mountainsRef = storageRef.child(widget.fileName);
              await mountainsRef.putFile(File("${widget.path}")).then((_) async {
                await mountainsRef.getDownloadURL().then((valueURL) async {
                  print(widget.testCodeList[widget.index]);
                  print(widget.testDetailsList[widget.index]);
                  print(widget.uid);

                  widget.testDetailsList[widget.index].update("excelURL", (value) => valueURL);
                  widget.testDetailsList[widget.index].update("status", (value) => "Uploaded");
                  print(widget.testDetailsList[widget.index]);

                  Future.delayed(Duration(seconds: 3),(){

                    FirebaseFirestore.instance.collection('ProfessorsDetails').doc(widget.uid).update({
                      "Quiz.${widget.subjectCode}.${widget.testCodeList[widget.index]}": widget.testDetailsList[widget.index]
                    }).then((_) {
                      Future.delayed(Duration(seconds: 3),(){

                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  title: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 60,
                                  ),
                                  content: Text(
                                    "File uploaded successfully.\nThank You.",
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text(
                                          'Okay',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            Navigator.of(context).pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) => ProDashboard(
                                                  ),
                                                  maintainState: true,
                                                  fullscreenDialog: false), (Route<dynamic> route) => false,
                                            );                                      });
                                        }),
                                  ]);
                            });
                      });
                  });

                  });
                });
              });
            },),)
          ],
        ): Align(alignment: Alignment.center, child: CircularProgressIndicator()),
      ),
    );
  }
}
