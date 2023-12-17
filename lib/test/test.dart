import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../configs/constants/constants.dart';

class Test extends StatefulWidget {
  final String uid;
  final String subCode;
  final String proUid;
  final String url;
  final String testCode;
  final String subjectCode;
  final String name;
  final String photoUrl;

  Test(
      {required this.uid,
      required this.testCode,
      required this.subCode,
        required this.subjectCode,
        required this.name,
        required this.photoUrl,
        required this.proUid,
      required this.url,
      });

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  bool ready = false;
  late String type;
  late String question;
  late List optionsList;
  late Timer _timer;
  String timer = '';
  int count = 0;
  Map dataFinal = {};
  Map mcq = {};
  Map fill = {};
  Map tf = {};
  Map mcqImg = {};
  Map fillImg = {};
  Map tfImg = {};
late  List<String> answersList;

  late List<String> userAnwersList ;
  Map sortedByValueMap = {};
  @override
  void initState() {




    readExcel().then((value) {
      bool trigger1 = false;
       print(value.length);
      for (int i = 0; i < value.length / 2; i++) {
        if (("${value.values.elementAt(i)}" == "MCQs" || trigger1) &&
            i < value.length / 2 &&
            "${value.values.elementAt(i)}" != "Fill up the Blanks" &&
            "${value.values.elementAt(i)}" != "True/False") {
          trigger1 = true;
          for (int j = 0; j < 6; j++) {
            if ("${value.values.elementAt(i)}" != "Fill up the Blanks" &&
                "${value.values.elementAt(i)}" != "True/False") {
              if ("${value.values.elementAt(i)}" != "null")
                mcq.addEntries({
                  value.keys.elementAt(i): value.values.elementAt(i)
                }.entries);
              mcqImg.addEntries({
                value.keys.elementAt(i):
                    value.values.elementAt(i + (value.length ~/ 2))
              }.entries);
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
              if ("${value.values.elementAt(i)}" != "null")
                fill.addEntries({
                  value.keys.elementAt(i): value.values.elementAt(i)
                }.entries);
              if ("${value.values.elementAt(i)}" != "null")
                fillImg.addEntries({
                  value.keys.elementAt(i):
                      value.values.elementAt(i + (value.length ~/ 2))
                }.entries);
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
        if ((value.values.elementAt(i).toString() == "True/False" ||
                trigger1) &&
            value.values.elementAt(i).toString() != "MCQs" &&
            "${value.values.elementAt(i)}" != "Fill up the Blanks" &&
            i < value.length / 2) {
          trigger1 = true;
          for (int j = 0; j < 2; j++) {
            if ("${value.values.elementAt(i)}" != "Fill up the Blanks" &&
                value.values.elementAt(i).toString() != "MCQs") {
              if ("${value.values.elementAt(i)}" != "null")
                tf.addEntries({
                  value.keys.elementAt(i): value.values.elementAt(i)
                }.entries);
              tfImg.addEntries({
                value.keys.elementAt(i):
                    value.values.elementAt(i + (value.length ~/ 2))
              }.entries);
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
        tempMcq.add(value);
      });
      tf.forEach((key, value) {
        tempTF.add(value);
      });
      fill.forEach((key, value) {
        tempFill.add(value);
      });
      mcqImg.forEach((key, value) {
        tempMcqImage.add(value);
      });
      tfImg.forEach((key, value) {
        tempTFImage.add(value);
      });
      fillImg.forEach((key, value) {
        tempFillImage.add(value);
      });
      for(int i =1; i<mcq.length;i++){
        finalMcq.addEntries({tempMcq[i]:tempMcq.sublist(i+1, i+6)+tempMcqImage.sublist(i, i+6)}.entries);

        i=i+5;
      }
      print(finalMcq);
      for(int i =1; i<tf.length;i++){
        finalTF.addEntries({tempTF[i]:[tempTF.elementAt(i+1)]+["","","",""]+tempTFImage.sublist(i, i+2)}.entries);
        i++;
      }
      print(finalTF);

      for(int i =1; i<fill.length;i++){
        finalFill.addEntries({tempFill[i]:[tempFill.elementAt(i+1)]+["","","",""]+tempFillImage.sublist(i, i+2)}.entries);
        i++;
      }
      print(finalFill);

      List mcqOrder = [];
      List fillOrder = [];
      List tfOrder = [];
      for(int i =0;i<finalMcq.length;i++){
        mcqOrder.add(i);
      }
      for(int i =0;i<finalFill.length;i++){
        fillOrder.add(i);
      }
      for(int i =0;i<finalTF.length;i++){
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
        int i = sortedByValueMap.values.elementAt(0) + sortedByValueMap.values.elementAt(1) + sortedByValueMap.values.elementAt(2);

      Random random = Random();


      if(i< 20 ){
        for (int i = 0; i < sortedByValueMap.values.elementAt(0); i++) {
          tempTypeList.add(sortedByValueMap.keys.elementAt(0));


        }
        for (int i = 0; i < sortedByValueMap.values.elementAt(1); i++) {
          tempTypeList.add(sortedByValueMap.keys.elementAt(1));
        }
        for (int i = 0; i < sortedByValueMap.values.elementAt(2); i++) {
          tempTypeList.add(sortedByValueMap.keys.elementAt(2));
        }
      }
      else{
        for (int i = 0; i < sortedByValueMap.values.elementAt(0); i++) {
          tempTypeList.add(sortedByValueMap.keys.elementAt(0));


        }
        for (int i = 0; i < sortedByValueMap.values.elementAt(1); i++) {
          tempTypeList.add(sortedByValueMap.keys.elementAt(1));
        }
        for (int i = 0; i < sortedByValueMap.values.elementAt(2); i++) {
          tempTypeList.add(sortedByValueMap.keys.elementAt(2));
        }

        for(int i =tempTypeList.length; i>20;i--){
          tempTypeList.removeAt(random.nextInt(20));
        }

      }


        int m = 0;
        int n = 0;
        int o = 0;
        for(int i = 0; i<tempTypeList.length;i++){
          if(tempTypeList[i]=="MCQs"){

            dataFinal.addEntries({"MCQs $i":{finalMcq.keys.elementAt(mcqOrder[m]):finalMcq.values.elementAt(mcqOrder[m])}            }.entries);
              m++;
          }else if(tempTypeList[i]=="True/False"){
            dataFinal.addEntries({"True/False $i":{finalTF.keys.elementAt(tfOrder[n]):finalTF.values.elementAt(tfOrder[n])}}.entries);
            n++;
          } else if((tempTypeList[i]=="Fill up the blanks")){
            dataFinal.addEntries({"Fill up the blanks $i":{finalFill.keys.elementAt(fillOrder[o]):finalFill.values.elementAt(fillOrder[o])}}.entries);
            o++;
          }
        }
        type = dataFinal!.keys.toList()[0];
        tempVAl = dataFinal!.values.toList()[0];
        questionList.add(tempVAl.keys.toList()[0]) ;
        question = questionList[0].toString();

        optionsList = tempVAl.values.toList()[0];
        answersList =  List.filled(dataFinal.length, "<-!->default<-!->", growable: true);
        userAnwersList =  List.filled(dataFinal.length , "<-!->default<-!->", growable: true);
        print("here");
        setState(() {
         ready = true;
         timerMethod(timer = '1:00');

       });

    });

    // TODO: implement initState
    super.initState();
  }

  int? _value = null;
  TextEditingController textarea = TextEditingController();
  FocusNode testareafocus = FocusNode();

  Map tempVAl = {};
  List questionList = [];

  void timerMethod(String set) {
    var temp = set.split(':');

    int seconds = 60;

    int minutes = int.parse(temp[0]) - 1;
    String sec = '00';
    String min = '00';

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (time) {
        tempMethod() {
          sec = '$seconds';
          min = '$minutes';
          if (seconds <= 9) {
            sec = '0$seconds';
          }
          if (minutes <= 9) {
            min = '0$minutes';
          }

          setState(
            () {
              timer = '$min:$sec';
              if (minutes < 0) {
                time.cancel();
                timer = '00:00';
                count++;

                if (count < dataFinal.length) {
                  timerMethod(timer = '1:00');

                  type = dataFinal!.keys.toList()[count];
                  textarea.text = "";
                  testareafocus.unfocus();
                  tempVAl = dataFinal!.values.toList()[count];
                  questionList.add(tempVAl.keys.toList()[0]);
                  question = questionList.last.toString();
                  optionsList = tempVAl.values.toList()[0];
                  _value = null;
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
                            content: Text(
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
                                    int correctCount = 0;
                                    int attemptCount = 0;
                                    for (int i = 0;
                                        i < answersList.length;
                                        i++) {
                                      if (answersList[i] !=
                                          "<-!->default<-!->") {
                                        attemptCount++;
                                        if (answersList[i] ==
                                            userAnwersList[i]) {
                                          correctCount++;
                                        }
                                      }
                                    }
                                    var acc =
                                        (correctCount / attemptCount * 100)
                                            .toStringAsFixed(2);
                                    var scr = (correctCount / 10 * 100)
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

                                            iTemp = double.parse(
                                                temp1["Score"].toString());
                                          }
                                          double jTemp =
                                              double.parse(scr.toString());

                                          finalScore = iTemp + jTemp;
                                    }).then((_) {
                                      FirebaseDatabase.instance
                                          .ref(
                                              "overAllScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                          .set({"Score":finalScore,"Name":widget.name,"photoURL":widget.photoUrl });
                                    }).then((_) {
                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        FirebaseDatabase.instance
                                            .ref(
                                            "individualScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                            .get()
                                            .then((value) {


                                          double iTemp = 0.0;
                                          if (value.exists) {
                                            Map temp1 = {};
                                            temp1.addAll(value.value as Map);

                                            iTemp = double.parse(
                                                temp1["Score"].toString());
                                          }
                                          double jTemp =
                                              double.parse(scr.toString());

                                          finalScore = iTemp + jTemp;
                                        });
                                      });
                                    }).then((_) {
                                      FirebaseDatabase.instance
                                          .ref(
                                          "individualScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                          .set({"Score":finalScore,"Name":widget.name,"photoURL":widget.photoUrl });
                                    }).then(
                                      (_) {
                                        FirebaseFirestore.instance
                                            .collection('StudentsDetails')
                                            .doc(widget.uid).get().then((valueStud) {
                                          Map tempMap = valueStud.data() as Map;
                                          if (tempMap["CompletedQuiz"] != null) {

                                            Map tempMap1 = tempMap["CompletedQuiz"] as Map;
                                            List tempList1 = List.empty(growable: true);
                                            tempList1=tempMap1.values.elementAt(0).toList();
                                            tempList1.add(widget.testCode);

                                            FirebaseFirestore.instance
                                                .collection('StudentsDetails')
                                                .doc(widget.uid).update(
                                                {
                                                  "CompletedQuiz."+widget.subjectCode: tempList1
                                                });

                                          } else {

                                            FirebaseFirestore.instance
                                                .collection('StudentsDetails')
                                                .doc(widget.uid).update(
                                                {"CompletedQuiz."+widget.subjectCode: [widget.testCode]
                                                });
                                          }
                                        }).then((_){
                                          Navigator.of(context).pushNamedAndRemoveUntil(
                                            RoutesConstants.launchPadScreenRoute,
                                                (Route<dynamic> route) => false,
                                          );
                                        });
                                      },
                                    );
                                  }),
                            ]);
                      });
                }
              }
            },
          );
        }

        seconds--;

        if (seconds == 00) {
          minutes--;
          seconds = 59;

          tempMethod();
        } else if (seconds < 60) {
          tempMethod();
        }
      },
    );
  }
  _images(url) {


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 70 / 100,
          child: Image.network(url,
              scale: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Text(
              timer,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
        title: const Text(PageTitleConstants.dashboardScreenTitle),
        automaticallyImplyLeading: true,
      ),
      body: ready
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
                            child: Text("Submit")),
                      ),
                    ]),
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

  _answerWidget() {
    List<String> choiceList = ["True", "False"];
    if (type == "MCQs ${count}") {
      return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          optionsList[index].toString(),
                          maxLines: 1000,
                        ),
                      ),
                      selected: _value == index,
                      selectedColor: Color.fromRGBO(212, 212, 230, 1.0),
                      onSelected: (bool selected) {
                        setState(() {
                          _value = selected ? index : null;
                          userAnwersList[count] = index.toString();

                          answersList[count] = (optionsList[4].toInt()-1).toString();
                        });
                      },
                    ),
                    (!optionsList[6+index].toString().contains("(If any)"))?_images(optionsList[6+index].toString())

                    :SizedBox.shrink(),
                  ],
                ),
              );
            },
          ).toList(),
        ),
      );
    } else if (type == "True/False ${count}")
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
                onSelected: (bool selected) {
                  setState(() {
                    _value = selected ? index : null;
                    userAnwersList[count] = index.toString();
                    answersList[count] = (optionsList[0]-1.0).toInt().toString();
                  });
                },
              ),
            );
          },
        ).toList(),
      );
    else if (type == "Fill up the blanks ${count}")
      return SizedBox(
        width: MediaQuery.of(context).size.width * 70 / 100,
        child: TextField(
          autofocus: false,
          controller: textarea,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          focusNode: testareafocus,
          onTapOutside: (_) {
            testareafocus.unfocus();
          },
          onChanged: (e) {
            setState(() {
              userAnwersList[count] = e.toString();
              answersList[count] = optionsList[0].toString();
            });
          },
          decoration: InputDecoration(
              label: Text("Answer"),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.redAccent))),
        ),
      );
    else
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 80 / 100,
          child: Image.asset(FileConstants.logo),
        ),
      );
  }

  _questionWidget() {
    if (count < dataFinal.length) {
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
                      "Question No. " +
                          (count + 1).toString() +
                          "\n" +
                          question,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1000,
                    )),
              ),
              (!optionsList[5].toString().contains("(If any)"))?_images(optionsList[5].toString())

                          :SizedBox.shrink(),
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

  @override
  void dispose() {
    _timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  onpressed() {
      setState(() {
        count++;
        _timer.cancel();

        if (count < dataFinal.length) {
          timerMethod(timer = '1:00');

          type = dataFinal!.keys.toList()[count];
          textarea.text = "";
          testareafocus.unfocus();
          tempVAl = dataFinal!.values.toList()[count];
          questionList.add(tempVAl.keys.toList()[0])  ;
          question = questionList.last.toString();
          optionsList = tempVAl.values.toList()[0];
          _value = null;
        } else {
          double finalScore = 0;
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
                    content: Text(
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
                            int correctCount = 0;
                            int attemptCount = 0;
                            for (int i = 0; i < answersList.length; i++) {
                              if (answersList[i] != "<-!->default<-!->") {
                                attemptCount++;
                                if (answersList[i].toString() == userAnwersList[i].trim().toString()) {
                                  correctCount++;
                                }
                              }
                            }
                            var acc = (correctCount / attemptCount * 100)
                                .toStringAsFixed(2);
                            var scr =
                                (correctCount / 10 * 100).toStringAsFixed(2);

                              FirebaseDatabase.instance
                                  .ref(
                                      "overAllScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                  .get()
                                  .then((value) {
                                double iTemp = 0.0;
                                if (value.exists) {
                                  Map temp1 = {};
                                  temp1.addAll(value.value as Map);
                                  iTemp = double.parse(temp1["Score"].toString());
                                }
                                double jTemp = double.parse(scr.toString());
                                finalScore = iTemp + jTemp;
                              }).then((_) {
                                FirebaseDatabase.instance
                                    .ref(
                                        "overAllScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                    .set({"Score":finalScore,"Name":widget.name,"photoURL":widget.photoUrl });
                              }).then((_) {
                                Future.delayed(const Duration(seconds: 3), () {
                                  FirebaseDatabase.instance
                                      .ref(
                                          "individualScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
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
                                  });
                                });
                              }).then((_) {

                                FirebaseDatabase.instance
                                    .ref(
                                    "individualScore/${widget.proUid}/${widget.subjectCode}/${widget.uid}")
                                    .set({"Score":finalScore,"Name":widget.name,"photoURL":widget.photoUrl });
                              }).then(
                                (_) {
                                  FirebaseFirestore.instance
                                      .collection('StudentsDetails')
                                      .doc(widget.uid).get().then((valueStud) {
                                    print(valueStud.data());
                                    Map tempMap = valueStud.data() as Map;
                                    if (tempMap["CompletedQuiz"] != null) {

                                      Map tempMap1 = tempMap["CompletedQuiz"] as Map;
                                      List tempList1 = List.empty(growable: true);
                                      tempList1=tempMap1[widget.subjectCode].toList();
                                      tempList1.add(widget.testCode);

                                      FirebaseFirestore.instance
                                          .collection('StudentsDetails')
                                          .doc(widget.uid).update(
                                          {
                                            "CompletedQuiz."+widget.subjectCode: tempList1
                                          });

                                    }
                                    else {

                                      FirebaseFirestore.instance
                                          .collection('StudentsDetails')
                                          .doc(widget.uid).update(
                                          {"CompletedQuiz.${widget.subjectCode}": [widget.testCode]
                                          });
                           }
                                  }).then((_){
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      RoutesConstants.launchPadScreenRoute,
                                          (Route<dynamic> route) => false,
                                    );
                                  });


                                },
                              );

                          }),
                    ]);
              });
        }
      });

  }

  readExcel() async {
    Map data = {};

    //  type = data.keys.toList()[0];
    //  tempVAl = data.values.toList()[0];
    //   questionList = tempVAl.keys.toList()[0];
    //   question = questionList[0];
    //   optionsList = tempVAl.values.toList()[0];
    final String firebaseExcelLink = widget.url;
  print("read");
    final response = await http.get(Uri.parse(firebaseExcelLink));
    List rowdetail0 = [];
    List rowdetail1 = [];
    List rowdetail2 = [];

    if (response.statusCode == 200) {
      // Parse the Excel file
      final Uint8List bytes = response.bodyBytes ;
      final excel = Excel.decodeBytes(bytes).tables;
      for (var table in excel.keys ) {
        for (var row in excel[table]!.rows) {
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
print("read");
    return data;
  }
}
