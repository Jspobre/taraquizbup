import 'dart:async';
import 'dart:io';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../configs/constants/constants.dart';

class MultiQuiz extends StatefulWidget {
  final String uid;
  final String subCode;
  final String proUid;
  final String testCode;
  final String subjectCode;
  final String groupCode;
  final String time;
  final bool timerEnded;
  final String name;
  final int noGroupMembers;
  final String photoUrl;
  final Map studentsPhotos;

  MultiQuiz(
      {required this.uid,
      required this.time,
      required this.timerEnded,
      required this.noGroupMembers,
      required this.studentsPhotos,
      required this.testCode,
      required this.subCode,
      required this.proUid,
      required this.subjectCode,
      required this.name,
      required this.photoUrl,
      required this.groupCode});

  @override
  _MultiQuizState createState() => _MultiQuizState();
}

ValueNotifier<int> countNotifier = ValueNotifier(-1);
ValueNotifier<String> timeNotifier = ValueNotifier("");

class _MultiQuizState extends State<MultiQuiz> {
  bool ready = true;
  late bool timerEnded;

  late Timer _timer;
  ValueNotifier<bool> readyNotifier = ValueNotifier(true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 500));
    timerEnded = widget.timerEnded;
    timerMethod(timeNotifier = ValueNotifier(widget.time));
  }

  int numberOfGroupMembers = 0;
  List<String> choiceList = ["True", "False"];
  Map<dynamic, dynamic> dataMap = {};
  List<String> anwersList =
      List.filled(20, "<-!->default<-!->", growable: true);
  List<String> userAnwersList =
      List.filled(20, "<-!->default<-!->", growable: true);
  int? _value = 0;
  TextEditingController textarea = TextEditingController();
  int questionNumber = 0;
  Map<List<String>, List<String>> tempVAl = {[]: []};
  @override
  void dispose() {
    _timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  onpressed() {
    Audio.load(FileConstants.assetBuzzerAudio)
      ..play()
      ..dispose();
    if (dataMap["buzzer"]["buzzer1"] == "default" &&
        dataMap["buzzer"]["buzzer1"] == "default") {
      FirebaseDatabase.instance
          .ref(
              "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}")
          .update({
        "buzzer": {"buzzer1": widget.uid, "buzzer2": "default"}
      });
    } else if (dataMap["buzzer"]["buzzer2"] == "default" &&
        dataMap["buzzer"]["buzzer1"] != "default" &&
        dataMap["buzzer"]["buzzer1"] != widget.uid) {
      FirebaseDatabase.instance
          .ref(
              "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}")
          .update({
        "buzzer": {
          "buzzer1": dataMap["buzzer"]["buzzer1"],
          "buzzer2": widget.uid
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _questionWidget() {
      questionNumber = countNotifier.value;
      questionNumber = questionNumber + 1;
      if (countNotifier.value < 20) {
        return Padding(
          padding: EdgeInsets.only(
            left: ((MediaQuery.of(context).size.width * 5) / 100),
            top: ((MediaQuery.of(context).size.height * 5) / 100),
            bottom: ((MediaQuery.of(context).size.height * 5) / 100),
            right: ((MediaQuery.of(context).size.width * 5) / 100),
          ),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  top: true,
                  bottom: true,
                  right: true,
                  left: true,
                  minimum: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: (MediaQuery.of(context).size.width * 85 / 100),
                      child: Text(
                        "Question No. $questionNumber\n" +
                            dataMap["questions"][countNotifier.value],
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1000,
                      )),
                ),
                (!dataMap["options"][countNotifier.value][5]
                        .toString()
                        .contains("(If any)"))
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 70 / 100,
                            child: Image.network(
                                dataMap["options"][countNotifier.value][5]
                                    .toString(),
                                scale: 1)),
                      )
                    : SizedBox.shrink()
              ],
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 80 / 100,
            child: Image.asset(FileConstants.logo),
          ),
        );
      }
    }

    _answerWidget() {
      if (countNotifier.value < 20) {
        if (dataMap["type"][countNotifier.value].toString().split(" ")[0] ==
            "MCQs") {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                4,
                (int index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 8.0,
                      top: 7.0,
                    ),
                    child: Column(
                      children: [
                        RawChip(
                          showCheckmark: false,
                          label: SizedBox(
                            width: MediaQuery.of(context).size.width * 70 / 100,
                            child: Text(
                              dataMap["options"][countNotifier.value][index],
                              maxLines: 1000,
                            ),
                          ),
                          selected: _value == index,
                          selectedColor: Color.fromRGBO(212, 212, 230, 1.0),
                          onSelected: (dataMap["buzzer"]["buzzer1"] ==
                                      widget.uid ||
                                  dataMap["buzzer"]["buzzer2"] == widget.uid)
                              ? (bool selected) {
                                  selected = true;
                                  setState(() {
                                    _value = selected ? index : null;
                                    userAnwersList[countNotifier.value] =
                                        (index + 1).toString();
                                    anwersList[countNotifier.value] =
                                        dataMap["options"][countNotifier.value]
                                            [4];
                                  });
                                }
                              : null,
                        ),
                        (!dataMap["options"][countNotifier.value][6 + index]
                                .toString()
                                .contains("(If any)"))
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        70 /
                                        100,
                                    child: Image.network(
                                        dataMap["options"][countNotifier.value]
                                                [6 + index]
                                            .toString(),
                                        scale: 1)),
                              )
                            : SizedBox.shrink()
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          );
        } else if (dataMap["type"][countNotifier.value]
                .toString()
                .split(" ")[0] ==
            "True/False") {
          return Wrap(
            children: List<Widget>.generate(
              2,
              (int index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 8.0,
                    top: 7.0,
                  ),
                  child: RawChip(
                    showCheckmark: false,
                    label: Text(
                      choiceList[index],
                    ),
                    selected: _value == index,
                    selectedColor: Color.fromRGBO(212, 212, 230, 1.0),
                    onSelected: (dataMap["buzzer"]["buzzer1"] == widget.uid ||
                            dataMap["buzzer"]["buzzer2"] == widget.uid)
                        ? (bool selected) {
                            selected = true;
                            setState(() {
                              _value = selected ? index : null;
                              userAnwersList[countNotifier.value] =
                                  (index + 1).toString();
                              anwersList[countNotifier.value] =
                                  dataMap["options"][countNotifier.value][0];
                            });
                          }
                        : null,
                  ),
                );
              },
            ).toList(),
          );
        } else if (dataMap["type"][countNotifier.value]
                .toString()
                .split(" ")[0] ==
            "Fill") {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 70 / 100,
            child: TextField(
              autofocus: true,
              controller: textarea,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              enabled: (dataMap["buzzer"]["buzzer2"] == widget.uid ||
                  dataMap["buzzer"]["buzzer1"] == widget.uid),
              onChanged: (e) {
                userAnwersList[countNotifier.value] = e.toString();
                anwersList[countNotifier.value] =
                    dataMap["options"][countNotifier.value][0];
              },
              decoration: const InputDecoration(
                  label: Text("Answer"),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1, color: Colors.redAccent))),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 80 / 100,
              child: Image.asset(FileConstants.logo),
            ),
          );
        }
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 80 / 100,
            child: Image.asset(FileConstants.logo),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: ValueListenableBuilder(
              valueListenable: timeNotifier,
              builder: (BuildContext context, String value, Widget? child) {
                return Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white),
                );
              },
            ),
          ),
        ),
        title: const Text(PageTitleConstants.dashboardScreenTitle),
        automaticallyImplyLeading: true,
      ),
      body: ready
          ? timerEnded
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
                  child: StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child(
                              'quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}')
                          .onValue
                          .asBroadcastStream(),
                      builder: (context, dbEvent) {
                        if (dbEvent.connectionState == ConnectionState.active) {
                          if (dbEvent.data!.snapshot.exists) {
                            dataMap.clear();
                            dataMap = dbEvent.data?.snapshot.value as Map;
                            readyNotifier = ValueNotifier(dataMap["timerEnd"]);
                            numberOfGroupMembers =
                                dataMap["groupMembers"].length;
                            return SingleChildScrollView(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _questionWidget(),
                                    _answerWidget(),
                                    Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            onpressed();
                                          },
                                          child: Text("Buzzer")),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              8 /
                                              100,
                                          bottom: 20,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              8 /
                                              100,
                                          top: 20),
                                      child: SizedBox(
                                        height: 50,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Card(
                                              color: ((dataMap["buzzer"]
                                                                  ["buzzer1"] ==
                                                              widget.uid &&
                                                          widget.studentsPhotos
                                                                  .keys
                                                                  .elementAt(
                                                                      index) ==
                                                              dataMap["buzzer"][
                                                                  "buzzer2"]) ||
                                                      (dataMap["buzzer"]
                                                                  ["buzzer1"] ==
                                                              widget.uid &&
                                                          widget.studentsPhotos
                                                                  .keys
                                                                  .elementAt(
                                                                      index) ==
                                                              dataMap["buzzer"]
                                                                  ["buzzer1"]))
                                                  ? Colors.amber
                                                  : Colors.white,
                                              child: SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.network(widget
                                                      .studentsPhotos.values
                                                      .elementAt(
                                                          index)["photoUrl"]),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: widget.noGroupMembers,
                                        ),
                                      ),
                                    ),
                                  ]),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "No groups created yet.\nClick '+' to create.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        } else {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Loading...."),
                                )
                              ],
                            ),
                          );
                        }
                      }),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Preparing quiz please wait...."),
                      )
                    ],
                  ),
                )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Loading...."),
                  )
                ],
              ),
            ),
    );
  }

  void timerMethod(ValueNotifier<String> set) {
    var temp = set.value.split(':');
    ValueNotifier<int> seconds = ValueNotifier(60);
    int count = -1;
    ValueNotifier<int> minutes = ValueNotifier(int.parse(temp[0]) - 1);

    String sec = '00';
    String min = '00';
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (time) {
        tempMethod() {
          sec = '${seconds.value}';
          min = '${minutes.value}';

          if (seconds.value <= 9) {
            sec = '0${seconds.value}';
          }

          if (minutes.value <= 9) {
            min = '0${minutes.value}';
          }

          timeNotifier.value = '$min:$sec';
          if (minutes.value < 0) {
            time.cancel();
            timeNotifier.value = '00:00';
            if (count == -1) {
              setState(() {
                count++;

                timerEnded = true;
              });
              FirebaseDatabase.instance
                  .ref(
                      "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}")
                  .update({
                "timerEnd": true,
              });
            }
            if (countNotifier.value < 20) {
              countNotifier.value++;
            }

            if (countNotifier.value < 20) {
              FirebaseDatabase.instance
                  .ref(
                      "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}")
                  .update({
                "buzzer": {"buzzer1": "default", "buzzer2": "default"}
              }).whenComplete(() {
                setState(() {
                  timerEnded = false;
                });
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    timerEnded = true;
                  });
                }).whenComplete(() {
                  timerMethod(timeNotifier = ValueNotifier("1:00"));
                  textarea.text = "";

                  _value = null;
                });
              });
            } else {
              double finalScore = 0;
              time.cancel();
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        title: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
                        content: const Text(
                          "Thank you for taking the Quiz.",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          TextButton(
                              child: Text(
                                'Okay',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.blue),
                              ),
                              onPressed: () {
                                print(anwersList);
                                print(userAnwersList);

                                int correctCount = 0;
                                int attemptCount = 0;
                                for (int i = 0; i < anwersList.length; i++) {
                                  if (anwersList[i] != "<-!->default<-!->") {
                                    attemptCount++;
                                    if (anwersList[i] == userAnwersList[i]) {
                                      correctCount++;
                                    }
                                  }
                                }
                                var acc = (correctCount / attemptCount * 100)
                                    .toStringAsFixed(2);
                                var scr = (correctCount / 20 * 100)
                                    .toStringAsFixed(2);

                                FirebaseDatabase.instance
                                    .ref(
                                        "overAllScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                    .get()
                                    .then((value) {
                                  double iTemp = 0.0;
                                  if (value.exists) {
                                    Map temp1 = {};
                                    temp1.addAll(value.value as Map);
                                    iTemp =
                                        double.parse(temp1["Score"].toString());
                                  }
                                  double jTemp = double.parse(scr.toString());
                                  finalScore = iTemp + jTemp;
                                }).then((_) {
                                  FirebaseDatabase.instance
                                      .ref(
                                          "overAllScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                      .set({
                                    "Score": finalScore,
                                    "Name": widget.name,
                                    "photoURL": widget.photoUrl
                                  });
                                }).then(
                                  (_) {
                                    FirebaseFirestore.instance
                                        .collection('StudentsDetails')
                                        .doc(widget.uid)
                                        .get()
                                        .then((valueStud) {
                                      Map tempMap = valueStud.data() as Map;
                                      if (tempMap["CompletedQuiz"] != null) {
                                        Map tempMap1 =
                                            tempMap["CompletedQuiz"] as Map;
                                        List tempList1 =
                                            List.empty(growable: true);
                                        tempList1 = tempMap1[widget.subjectCode]
                                            .toList();
                                        tempList1.add(
                                            "${widget.testCode}_${widget.groupCode}");

                                        FirebaseFirestore.instance
                                            .collection('StudentsDetails')
                                            .doc(widget.uid)
                                            .update({
                                          "CompletedQuiz." + widget.subjectCode:
                                              tempList1
                                        });
                                      } else {
                                        FirebaseFirestore.instance
                                            .collection('StudentsDetails')
                                            .doc(widget.uid)
                                            .update({
                                          "CompletedQuiz.${widget.subjectCode}":
                                              [
                                            "${widget.testCode}" +
                                                "_" +
                                                "${widget.groupCode}"
                                          ]
                                        });
                                      }
                                    }).then((_) {
                                      FirebaseDatabase.instance
                                          .ref(
                                              "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}")
                                          .get()
                                          .then((value) {
                                        Map tempInnerMap = value.value as Map;
                                        if (kDebugMode) {
                                          print(tempInnerMap);
                                        }
                                        print("here");

                                        print(tempInnerMap["groupMembers"]);
                                        Map tempInnerMap01 = Map();
                                        tempInnerMap01.addAll(
                                            tempInnerMap["groupMembers"]
                                                as Map<dynamic, dynamic>);
                                        for (int i = 0;
                                            i < tempInnerMap01.keys.length;
                                            i++) {
                                          if (tempInnerMap01.keys
                                                  .elementAt(i) ==
                                              widget.uid) {
                                            tempInnerMap01.values
                                                .elementAt(i)["score"] = scr;
                                          }
                                        }
                                        tempInnerMap["groupMembers"] =
                                            tempInnerMap01;
                                        FirebaseDatabase.instance
                                            .ref(
                                                "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${widget.groupCode}")
                                            .update(tempInnerMap
                                                .cast<String, Object>());
                                      }).whenComplete(() {
                                        Future.delayed(
                                            const Duration(seconds: 6), () {
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            RoutesConstants
                                                .launchPadScreenRoute,
                                            (Route<dynamic> route) => false,
                                          );
                                        });
                                      });
                                    });
                                  },
                                );
                              }),
                        ]);
                  });
            }
          }
        }

        seconds.value--;

        if (seconds.value == 00) {
          minutes.value--;
          seconds.value = 59;

          tempMethod();
        } else if (seconds.value < 60) {
          tempMethod();
        }
      },
    );
  }
}
