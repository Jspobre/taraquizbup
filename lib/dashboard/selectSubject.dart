import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taraquizbup/configs/constants/constants.dart';
import 'package:taraquizbup/dashboard/gameRoom.dart';

class SelectSubject extends StatefulWidget {
  final Map data;
  final String uid;
  final bool isSubject;

  SelectSubject(
      {required this.data, required this.uid, required this.isSubject});

  @override
  _SelectSubjectState createState() => _SelectSubjectState();
}

class _SelectSubjectState extends State<SelectSubject> {
  TextEditingController profNameController = TextEditingController();
  TextEditingController profPasswordController = TextEditingController();

  TextEditingController profCodeController = TextEditingController();
  String timeStamp = '';
  List name = [];
  List photoURL = [];
  List uid = [];
  String uidStr = '';
  String nameStr = '';
  String photoStr = '';
  String proUid = "";
  String subjectCode = "";
  String testCode = "";
  String subCode = "";
  String url = "";
  String password = "";

  List questions =  List.empty(growable: true);
  List options = List.empty(growable: true);
  List type = List.empty(growable: true);
  int count = 0;
  Map dataFinal = {};
  Map mcq = {};
  Map fill = {};
  Map tf = {};
  Map mcqImg = {};
  Map fillImg = {};
  Map tfImg = {};
  Map sortedByValueMap = {};

  FocusNode profNameFocusNode = FocusNode();
  FocusNode profPasswordFocusNode = FocusNode();
  FocusNode profCodeFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.isSubject);
    if (widget.isSubject) {
      widget.data.forEach((key, value) {
        name.add(value["Name"]);
        photoURL.add(value["photoURL"]);
        uid.add(key);
      });
    } else {
      nameStr = widget.data["name"];
      photoStr = widget.data["photo"];

      proUid = widget.data["proUid"];
      subjectCode = widget.data["subjectCode"];
      testCode = widget.data["testCode"];
      subCode = widget.data["subCode"];
      url = widget.data["url"];
      readExcel().then((value) {
        password = value.values.elementAt(3).toString();
        bool trigger1 = false;
        for (int i = 0; i < value.length / 2; i++) {
          if (("${value.values.elementAt(i)}" == "MCQs" || trigger1) &&
              i < value.length / 2 &&
              "${value.values.elementAt(i)}" != "Fill up the Blanks" &&
              "${value.values.elementAt(i)}" != "True/False") {
            trigger1 = true;
            for (int j = 0; j < 6; j++) {
              if ("${value.values.elementAt(i)}" != "Fill up the Blanks" &&
                  "${value.values.elementAt(i)}" != "True/False") {
                if ("${value.values.elementAt(i)}" != "null") {
                  mcq.addEntries({
                    value.keys.elementAt(i): value.values.elementAt(i)
                  }.entries);
                }
                if ("${value.values.elementAt(i)}" != "null" && (i + value.length ~/ 2) < value.length) {
                  mcqImg.addEntries({
                  value.keys.elementAt(i):
                  value.values.elementAt(i + (value.length ~/ 2))
                }.entries);
                }
                i++;
              } else {
                trigger1 = false;

                break;
              }
            }
            i--;
          }
        }
        trigger1 = false;

        for (int i = 0; i < value.length / 2; i++) {
          if (("${value.values.elementAt(i)}" == "Fill up the Blanks" ||
              trigger1) &&
              "${value.values.elementAt(i)}" != "MCQs" &&
              i < value.length / 2 &&
              "${value.values.elementAt(i)}" != "True/False") {
            trigger1 = true;
            for (int j = 0; j < 2; j++) {
              if ("${value.values.elementAt(i)}" != "MCQs" &&
                  "${value.values.elementAt(i)}" != "True/False") {
                if ("${value.values.elementAt(i)}" != "null") {
                  fill.addEntries({
                    value.keys.elementAt(i): value.values.elementAt(i)
                  }.entries);
                }
                if ("${value.values.elementAt(i)}" != "null" && (i + value.length ~/ 2) < value.length) {
                  fillImg.addEntries({
                    value.keys.elementAt(i):
                    value.values.elementAt(i + (value.length ~/ 2))
                  }.entries);
                }
                i++;
              } else {
                trigger1 = false;

                break;
              }
            }
            i--;
          }
        }
        trigger1 = false;
        for (int i = 0; i   < value.length; i++) {
          if ((value.values.elementAt(i).toString() == "True/False" ||
              trigger1) &&
              value.values.elementAt(i).toString() != "MCQs" &&
              "${value.values.elementAt(i)}" != "Fill up the Blanks" &&
              (i + value.length / 2) < value.length ) {
            trigger1 = true;
            for (int j = 0; j < 2; j++) {
              if ("${value.values.elementAt(i)}" != "Fill up the Blanks" &&
                  value.values.elementAt(i).toString() != "MCQs") {
                if ("${value.values.elementAt(i)}" != "null") {
                  tf.addEntries({
                    value.keys.elementAt(i): value.values.elementAt(i)
                  }.entries);
                }
                if ("${value.values.elementAt(i)}" != "null" && (i + value.length ~/ 2) < value.length) {
                  tfImg.addEntries({
                  value.keys.elementAt(i):
                  value.values.elementAt(i + (value.length ~/ 2))
                }.entries);
                }

                i++;
              } else {
                trigger1 = false;
                break;
              }
            }
            i--;
          }
        }
        Map finalMcq = {};
        Map finalTF = {};
        Map finalFill = {};
        List tempMcq = [];
        List tempTF = [];
        List tempFill = [];

        List tempMcqImage = [];
        List tempTFImage = [];
        List tempFillImage = [];
        mcq.forEach((key, value) {
          tempMcq.add(value.toString());
        });
        tf.forEach((key, value) {
          tempTF.add(value.toString());
        });
        fill.forEach((key, value) {
          tempFill.add(value.toString());
        });
        mcqImg.forEach((key, value) {
          tempMcqImage.add(value.toString());
        });
        tfImg.forEach((key, value) {
          tempTFImage.add(value.toString());
        });
        fillImg.forEach((key, value) {
          tempFillImage.add(value.toString());
        });
        for (int i = 1; i < mcq.length; i++) {
          finalMcq.addEntries({
            tempMcq[i]:
            tempMcq.sublist(i + 1, i + 6) + tempMcqImage.sublist(i, i + 6)
          }.entries);

          i = i + 5;
        }
        print(mcq);

        for (int i = 1; i < tf.length; i++) {
          finalTF.addEntries({
            tempTF[i]: [tempTF.elementAt(i + 1)] +
                ["default", "default", "default", "default"] +
                tempTFImage.sublist(i, i + 2)
          }.entries);
          i++;
        }

        for (int i = 1; i < fill.length; i++) {
          finalFill.addEntries({
            tempFill[i]: [tempFill.elementAt(i + 1)] +
                ["default", "default", "default", "default"]+
                tempFillImage.sublist(i, i + 2)
          }.entries);
          i++;
        }

        List mcqOrder = [];
        List fillOrder = [];
        List tfOrder = [];
        for (int i = 0; i < finalMcq.length; i++) {
          mcqOrder.add(i);
        }
        for (int i = 0; i < finalFill.length; i++) {
          fillOrder.add(i);
        }
        for (int i = 0; i < finalTF.length; i++) {
          tfOrder.add(i);
        }
        mcqOrder.shuffle();
        fillOrder.shuffle();
        tfOrder.shuffle();

        Map lengthOfVariables = {
          "MCQs": mcq.length ~/ 6,
          "True/False": tf.length ~/ 2,
          "Fill up the blanks": fill.length ~/ 2
        };
        sortedByValueMap = Map.fromEntries(lengthOfVariables.entries.toList()
          ..sort((e1, e2) => e1.value.compareTo(e2.value)));
        List tempTypeList = [];
        int i = sortedByValueMap.values.elementAt(0) +
            sortedByValueMap.values.elementAt(1) +
            sortedByValueMap.values.elementAt(2);

        Random random = Random();

        if (i < 20) {
          for (int i = 0; i < sortedByValueMap.values.elementAt(0); i++) {
            tempTypeList.add(sortedByValueMap.keys.elementAt(0));
          }
          for (int i = 0; i < sortedByValueMap.values.elementAt(1); i++) {
            tempTypeList.add(sortedByValueMap.keys.elementAt(1));
          }
          for (int i = 0; i < sortedByValueMap.values.elementAt(2); i++) {
            tempTypeList.add(sortedByValueMap.keys.elementAt(2));
          }
        } else {
          for (int i = 0; i < sortedByValueMap.values.elementAt(0); i++) {
            tempTypeList.add(sortedByValueMap.keys.elementAt(0));
          }
          for (int i = 0; i < sortedByValueMap.values.elementAt(1); i++) {
            tempTypeList.add(sortedByValueMap.keys.elementAt(1));
          }
          for (int i = 0; i < sortedByValueMap.values.elementAt(2); i++) {
            tempTypeList.add(sortedByValueMap.keys.elementAt(2));
          }

          for (int i = tempTypeList.length; i > 20; i--) {
            tempTypeList.removeAt(random.nextInt(20));
          }
        }

        int m = 0;
        int n = 0;
        int o = 0;

        for (int i = 0; i < tempTypeList.length; i++) {
          if (tempTypeList[i] == "MCQs") {
            type.add("MCQs $i");
            questions.add(finalMcq.keys.elementAt(mcqOrder[m]).toString());
            options.add(finalMcq.values.elementAt(mcqOrder[m]));
            dataFinal.addEntries({
              "MCQs $i": {
                finalMcq.keys.elementAt(mcqOrder[m]).toString():
                finalMcq.values.elementAt(mcqOrder[m])
              }
            }.entries);
            m++;
            print(questions);
            print(options);
          } else if (tempTypeList[i] == "True/False") {
            type.add("True/False $i");
            questions.add(finalTF.keys.elementAt(tfOrder[n]).toString());
            options.add(finalTF.values.elementAt(tfOrder[n]));
            dataFinal.addEntries({
              "True/False $i": {
                finalTF.keys.elementAt(tfOrder[n]).toString():
                finalTF.values.elementAt(tfOrder[n])
              }
            }.entries);
            n++;

            print(questions);
            print(options);
          } else if ((tempTypeList[i] == "Fill up the blanks")) {
            type.add("Fill up the blanks $i");
            questions.add(finalFill.keys.elementAt(fillOrder[o]).toString());
            options.add(finalFill.values.elementAt(fillOrder[o]));
            dataFinal.addEntries({
              "Fill up the blanks $i": {
                finalFill.keys.elementAt(fillOrder[o]).toString():
                finalFill.values.elementAt(fillOrder[o])
              }
            }.entries);
            o++;
          }

          print(questions);
          print(options);

        }


        print(questions);
        print(options);
      });

    }


    print(questions);
    print(options);
  }

  readExcel() async {
    Map data = {};

    //  type = data.keys.toList()[0];
    //  tempVAl = data.values.toList()[0];
    //   questionList = tempVAl.keys.toList()[0];
    //   question = questionList[0];
    //   optionsList = tempVAl.values.toList()[0];
    final String firebaseExcelLink = url;
    print("read");
    final response = await http.get(Uri.parse(firebaseExcelLink));
    List rowdetail0 = [];
    List rowdetail1 = [];
    List rowdetail2 = [];

    if (response.statusCode == 200) {
      // Parse the Excel file
      final Uint8List bytes = response.bodyBytes;
      final excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          rowdetail0.add(row[0]?.value);
          rowdetail1.add(row[1]?.value);
          rowdetail2.add(row[2]?.value);
        }
      }
    }

    for (int i = 0; i < rowdetail1.length; i++) {
      data.addEntries({i: rowdetail1[i]}.entries);
    }
    int j = 0;
    for (int i = rowdetail1.length; j < rowdetail2.length; i++) {
      data.addEntries({i: rowdetail2[j]}.entries);
      j++;
    }
    print(data);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    Widget _body() {
      return widget.isSubject
          ? Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.linearToSrgbGamma(),
            alignment: Alignment.center,
            scale: 1,
            opacity: 1,
            fit: BoxFit.fill,
            image: AssetImage(FileConstants.assetBackground),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 18.0),
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 80 / 100,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Professors Name: \*',
                      ),
                      onTap: () {
                        showSearch(
                            context: context,
                            // delegate to customize the search bar
                            delegate: CustomSearchDelegate(
                                name, photoURL, uid))
                            .then((value) {
                          profNameController.text =
                          widget.data[value]["Name"];
                          uidStr = value;
                        });
                      },
                      readOnly: true,
                      controller: profNameController,
                      focusNode: profNameFocusNode,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 18.0),
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 80 / 100,
                    child: TextField(

                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Subject code: \*',
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context)
                            .requestFocus(profCodeFocusNode);
                        profCodeController.text = '';
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context)
                            .requestFocus(profPasswordFocusNode);
                      },
                      readOnly: false,
                      controller: profCodeController,
                      focusNode: profCodeFocusNode,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 18.0),
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 80 / 100,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Password: \*',
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context)
                            .requestFocus(profPasswordFocusNode);
                        profPasswordController.text = '';
                      },
                      obscureText: true,
                      controller: profPasswordController,
                      focusNode: profPasswordFocusNode,
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Map tempMap001 = {};

                      FirebaseFirestore.instance
                          .collection('ProfessorsDetails')
                          .doc(uidStr)
                          .get()
                          .then((value) {

                        if (value.data()?["Subject"]
                        [profCodeController.text]["Password"] ==
                            profPasswordController.text) {


                          FirebaseFirestore.instance
                              .collection('StudentsDetails')
                              .doc(widget.uid)
                              .get()
                              .then((valueStud) {
                            Map tempMap = valueStud.data() as Map;
                            print(tempMap);
                            if (tempMap["Subject"] != null) {
                              Map tempMap1 = value.data()?["Subject"]
                              [profCodeController.text];
                              tempMap1.addEntries({
                                "ProfName": profNameController.text
                              }.entries);
                              tempMap1.addEntries(
                                  {"ProfUID": uidStr}.entries);

                              FirebaseFirestore.instance
                                  .collection('StudentsDetails')
                                  .doc(widget.uid)
                                  .update({
                                "Subject." + profCodeController.text:
                                tempMap1 as Map
                              }).
                              then((_) {

                                  tempMap001.addEntries({
                                        widget.uid:
                                        {
                                          tempMap["photoUrl"]:tempMap["name"]
                                        }
                                      }.entries );

                                if(value.data()?["Subject"]
                                [profCodeController.text]["StudentList"].toString() != "null") {
                                  tempMap001.addAll( value.data()?["Subject"]
                                  [profCodeController.text]["StudentList"]);

                                }
                                FirebaseFirestore.instance
                                    .collection('ProfessorsDetails')
                                    .doc(uidStr)
                                    .update({ "Subject." +profCodeController.text:
                                {
                                  "Name": value.data()?["Subject"]
                                  [profCodeController.text]
                                  ["Name"],
                                  "Password": value.data()?["Subject"]
                                  [profCodeController.text]
                                  ["Password"],
                                  "StudentList": tempMap001
                                }

                                });
                              });
                            } else {
                              Map tempMap1 = value.data()?["Subject"]
                              [profCodeController.text];
                              tempMap1.addEntries({
                                "ProfName": profNameController.text
                              }.entries);
                              tempMap1.addEntries(
                                  {"ProfUID": uidStr}.entries);

                              FirebaseFirestore.instance
                                  .collection('StudentsDetails')
                                  .doc(widget.uid)
                                  .update({
                                "Subject." + profCodeController.text:
                                tempMap1
                              })
                                  .then((_) {
                                    print( tempMap);
                                    print( tempMap["photoUrl"]);

                                    tempMap001.addEntries({
                                  widget.uid:
                                  {
                                    tempMap["photoUrl"]:tempMap["name"]

                                  }
                                }.entries );
                                print(tempMap001);
                                if(value.data()?["Subject"]
                                [profCodeController.text]["StudentList"].toString() != "null") {
                                  tempMap001.addAll( value.data()?["Subject"]
                                  [profCodeController.text]["StudentList"]);

                                }
                                FirebaseFirestore.instance
                                    .collection('ProfessorsDetails')
                                    .doc(uidStr)
                                    .update({ "Subject." +profCodeController.text:
                                          {
                                            "Name": value.data()?["Subject"]
                                            [profCodeController.text]
                                            ["Name"],
                                            "Password": value.data()?["Subject"]
                                                    [profCodeController.text]
                                                ["Password"],
                                            "StudentList": tempMap001
                                          }

                                      });
                              });
                            }
                          });
                        }
                      });
                    },
                    child: const Text("Add Subject"),
                  )),
            ],
          ),
        ),
      )
          : Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.linearToSrgbGamma(),
            alignment: Alignment.center,
            scale: 1,
            opacity: 1,
            fit: BoxFit.fill,
            image: AssetImage(FileConstants.assetBackground),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 18.0),
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 80 / 100,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Group Name: \*',
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context)
                            .requestFocus(profCodeFocusNode);
                        profCodeController.text = '';
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context)
                            .requestFocus(profPasswordFocusNode);
                      },
                      readOnly: false,
                      controller: profCodeController,
                      focusNode: profCodeFocusNode,
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isSubject) {
                        FirebaseFirestore.instance
                            .collection('ProfessorsDetails')
                            .doc(uidStr)
                            .get()
                            .then((value) {

                          if (value.data()?["Subject"]
                          [profCodeController.text]["Password"] ==
                              profPasswordController.text) {
                            FirebaseFirestore.instance
                                .collection('StudentsDetails')
                                .doc(widget.uid)
                                .get()
                                .then((valueStud) {
                              Map tempMap = valueStud.data() as Map;
                              if (tempMap["Subject"] != null) {
                                Map tempMap1 = value.data()?["Subject"]
                                [profCodeController.text];
                                tempMap1.addEntries({
                                  "ProfName": profNameController.text
                                }.entries);
                                tempMap1.addEntries(
                                    {"ProfUID": uidStr}.entries);

                                FirebaseFirestore.instance
                                    .collection('StudentsDetails')
                                    .doc(widget.uid)
                                    .update({
                                  "Subject." + profCodeController.text:
                                  tempMap1 as Map
                                });
                              } else {
                                Map tempMap = value.data()?["Subject"]
                                [profCodeController.text];
                                tempMap.addEntries({
                                  "ProfName": profNameController.text
                                }.entries);
                                tempMap.addEntries(
                                    {"ProfUID": uidStr}.entries);

                                FirebaseFirestore.instance
                                    .collection('StudentsDetails')
                                    .doc(widget.uid)
                                    .update({
                                  "Subject." + profCodeController.text:
                                  tempMap
                                });
                              }
                            });
                          }
                        });
                      } else {
                        print(questions);
                        print(options);
                        timeStamp = DateTime
                            .now()
                            .millisecondsSinceEpoch
                            .toString()
                            .substring(0, 10);

                        profCodeController.text.isNotEmpty
                            ?
                          FirebaseDatabase.instance
                              .ref(
                              "quizRoom/${proUid}/${subjectCode}/${testCode}")
                              .update({
                            timeStamp: {

                                "title": profCodeController.text
                                    .toString()
                                    .trim(),


                                "questions": questions,
                                "options":options,
                                "password":password,
                                "type":type,
                                "startCountDown": false,
                              "timerEnd": false,

                              "groupMembers" : {
                                          widget.uid: {
                                            "name": nameStr,
                                            "photoUrl": photoStr,
                                            "score": 0
                                          }
                                        },
                            }
                          }).then((_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  GameRoom(uid: widget.uid, testCode: testCode, subCode: subCode, proUid: proUid, url: photoStr, subjectCode: subjectCode, name: nameStr, photoUrl: photoStr,

                                    )),
                              );



                        }) : showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(30)),
                                  title: const Icon(
                                    Icons.back_hand,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  content: Text(
                                    "Please enter a valid Group name.",
                                    maxLines: 7,
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text(
                                          'Okay',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                              color: Colors.blue),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ]);
                            });



                    }
                    },
                    child: const Text("Add Group"),
                  )),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select subjects",
        ),
      ),
      body: _body(),
    );
  }


}

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  final List searchTerms;
  final List url;
  final List uid;

  CustomSearchDelegate(this.searchTerms, this.url, this.uid);

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, "");
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var prof in searchTerms) {
      if (prof.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(prof);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          leading:
          SizedBox(width: 30, height: 30, child: Image.network(url[index])),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          leading:
          SizedBox(width: 30, height: 30, child: Image.network(url[index])),
          onTap: () {
            close(context, uid[index]);
          },
          title: Text("$result (${uid[index].toString().substring(0, 6)})"),
        );
      },
    );
  }
}
