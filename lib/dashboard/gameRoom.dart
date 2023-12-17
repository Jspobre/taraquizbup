import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:taraquizbup/dashboard/selectSubject.dart';
import 'package:taraquizbup/test/multi.dart';

import '../configs/constants/constants.dart';

class GameRoom extends StatefulWidget {
  final String uid;
  final String subCode;
  final String proUid;
  final String url;
  final String testCode;
  final String subjectCode;
  final String name;
  final String photoUrl;
  GameRoom({
    required this.uid,
    required this.testCode,
    required this.subCode,
    required this.proUid,
    required this.url,
    required this.subjectCode,
    required this.name,
    required this.photoUrl,
  });

  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  setStatus() {
    controllerHasGroup.stream.listen((hasGroupsStream) {
      hasGroups = hasGroupsStream;
      setState(() {
        hasGroups;
      });
    });

    controllerJoined.stream.listen((joinedStream) {
      joined = joinedStream;
      setState(() {
        joined;
      });
    });
  }

  List dataValues = [];
  List<int> numberOfGroupMembers = [];

  List dataKeys = List.empty(growable: true);
  List dataValues1 = [];
  late bool joined;
  late bool hasGroups;
  Map dataMap = Map();
  String timer = '';

  late StreamController<bool> controllerHasGroup;
  late StreamController<bool> controllerJoined;

  int numberOfGroups = 0;
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  void countDownStart(index) {
    var dateTimeServer = dataValues1[index]["startCountDownTime"];
    var dateTimeNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    var finalTime =
        (Duration(milliseconds: (dateTimeNow - dateTimeServer) ~/ 1));
    List finalTimeList = finalTime.toString().split(":");
    if (int.parse(finalTimeList[0]) == 0 && int.parse(finalTimeList[1]) <= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FirebaseDatabase.instance
            .ref(
                "quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${dataKeys[index]}")
            .update({
          "buzzer": {"buzzer1": "default", "buzzer2": "default"}
        }).then((_) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MultiQuiz(
                  timerEnded: dataValues1[index]["timerEnd"],
                  time:
                      "0${(2 - int.parse(finalTimeList[1])).toString()}:${(60 - double.parse(finalTimeList[2])).toStringAsFixed(0)}",
                  groupCode: dataKeys[index],
                  noGroupMembers: numberOfGroupMembers[index],
                  uid: widget.uid,
                  testCode: widget.testCode,
                  subCode: widget.subCode,
                  proUid: widget.proUid,
                  studentsPhotos: dataValues1[index]["groupMembers"],
                  subjectCode: widget.subjectCode,
                  name: widget.name,
                  photoUrl: widget.photoUrl,
                ),
              ),
              (Route<dynamic> route) => false);
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('StudentsDetails')
          .doc(widget.uid)
          .update({
        "CompletedQuiz.${widget.subjectCode}": [
          widget.testCode + "_" + "${dataKeys[index]}"
        ]
      }).then((_) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RoutesConstants.launchPadScreenRoute,
            (Route<dynamic> route) => false,
          );
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    hasGroups = false;
    joined = false;
    controllerHasGroup = StreamController<bool>();
    controllerJoined = StreamController<bool>();
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        hasGroups;
        joined;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controllerJoined.close();
    controllerHasGroup.close();
  }

  @override
  Widget build(BuildContext context) {
    _studentsInGroup(dataValues1, int index) {
      List<Widget> studentsInGrouup = List.empty(growable: true);
      studentsInGrouup.add(
        Text(
          dataValues1[index]["title"],
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.left,
        ),
      );
      studentsInGrouup.add(
        Text(
          "Group Members: (${numberOfGroupMembers[index]}/5) (min 3/5)",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.left,
        ),
      );

      for (int i = 0; i < numberOfGroupMembers[index]; i++) {
        studentsInGrouup.add(Row(
          children: [
            SizedBox(
                width: 35,
                height: 35,
                child: Image.network(dataValues[index]["groupMembers"]
                    .values
                    .toList()[i]["photoUrl"])),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  dataValues[index]["groupMembers"].values.toList()[i]['name']),
            )
          ],
        ));
      }
      (dataValues1[index]["startCountDown"] == true)
          ? countDownStart(index)
          : (dataValues1[index]["groupMembers"].keys.contains(widget.uid)
              ? ((numberOfGroupMembers[index] >= 3) &&
                      (numberOfGroupMembers[index] <= 5))
                  ? studentsInGrouup.add(Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          controller.clear();
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    title: const Text(
                                      "Enter Password",
                                      maxLines: 7,
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Padding(
                                      padding: EdgeInsets.only(
                                        top: ((MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2) /
                                            100),
                                        left: ((MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                8) /
                                            100),
                                        right: ((MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                8) /
                                            100),
                                        bottom: ((MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2) /
                                            100),
                                      ),
                                      child: TextField(
                                        showCursor: true,
                                        textDirection: TextDirection.ltr,
                                        focusNode: focusNode,
                                        obscureText: false,
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.text,
                                        controller: controller,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.blue),
                                        onChanged: (e) {
                                          controller.text = e;
                                        },
                                        onTapOutside: (event) =>
                                            FocusScope.of(context).unfocus(),
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(focusNode);

                                          controller.text = '';
                                        },
                                      ),
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
                                            if (controller.text ==
                                                dataValues1[index]
                                                    ["password"]) {
                                              FirebaseDatabase.instance
                                                  .ref(
                                                      'quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${dataKeys[index]}')
                                                  .update({
                                                "startCountDown": true,
                                                "timerStart": true,
                                                "startCountDownTime":
                                                    ServerValue.timestamp
                                              });
                                              Navigator.pop(context);
                                            }
                                          }),
                                    ]);
                              });
                        },
                        icon: const Icon(Icons.play_circle),
                        label: const Text("Start"),
                      ),
                    ))
                  : null
              : (!joined &&
                      dataValues1[index]["startCountDown"] == false &&
                      (numberOfGroupMembers[index] < 5))
                  ? studentsInGrouup.add(Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          FirebaseDatabase.instance
                              .ref(
                                  'quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}/${dataKeys[index]}/groupMembers')
                              .update({
                            widget.uid: {
                              "name": widget.name,
                              "photoUrl": widget.photoUrl,
                              "score": 0
                            }
                          }).then((_) {
                            joined = true;
                            controllerJoined.sink.add(joined);
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Join"),
                      ),
                    ))
                  : null);

      return studentsInGrouup;
    }

    _float() {
      return (joined)
          ? SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                  createGroup();
                },
                child: const Icon(Icons.add),
              ),
            );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _float(),
      appBar: AppBar(
        title: const Text("Quiz Room"),
        automaticallyImplyLeading: true,
      ),
      body: Container(
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
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child(
                          'quizRoom/${widget.proUid}/${widget.subjectCode}/${widget.testCode}')
                      .onValue
                      .asBroadcastStream(),
                  builder: (context, dbEvent) {
                    if (dbEvent.connectionState == ConnectionState.active) {
                      if (dbEvent.data!.snapshot.exists) {
                        hasGroups = true;
                        controllerHasGroup.sink.add(hasGroups);

                        dataMap.clear();
                        dataMap = dbEvent.data?.snapshot.value as Map;
                        dataKeys.clear();
                        dataValues1.clear();
                        dataValues.clear();
                        dataMap.forEach((key, value) {
                          dataKeys.add(key); // Group Name
                          dataValues.add(value); // Student Data
                        });
                        dataKeys = Set.of(dataKeys).toList();
                        dataValues = Set.of(dataValues).toList();

                        numberOfGroups = 0;
                        numberOfGroups = dataKeys.length;

                        for (var element in dataValues) {
                          dataValues1.add(element as Map);
                        }
                        dataValues1 = Set.of(dataValues1).toList();

                        numberOfGroupMembers.clear();

                        for (int j = 0; j < dataKeys.length; j++) {
                          numberOfGroupMembers
                              .add(dataValues1[j]["groupMembers"].length);
                          if (dataValues1[j]["groupMembers"]
                              .keys
                              .contains(widget.uid)) {
                            joined = true;
                            controllerJoined.sink.add(joined);
                          }
                        }

                        return ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      _studentsInGroup(dataValues1, index),
                                ),
                              ),
                            );
                          },
                          itemCount: numberOfGroups,
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
                  }))),
    );
  }

  createGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => SelectSubject(
                data: {
                  "testCode": widget.testCode,
                  "subCode": widget.subCode,
                  "url": widget.url,
                  "name": widget.name,
                  "photo": widget.photoUrl,
                  "proUid": widget.proUid,
                  "subjectCode": widget.subjectCode
                },
                uid: widget.uid,
                isSubject: false,
              ),
          maintainState: true,
          fullscreenDialog: false),
    );
  }
}
