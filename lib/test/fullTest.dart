import 'dart:async';
import 'dart:math';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mixins/mixins.dart';

class SharedPrefsModel {
  bool appTestValid;

  bool dbCreated;
  String pageTitle;
  bool contact;
  String firstName;

  String lastName;

  String emailId;
  String batch;

  String cat01;




  List<String> currentTestQuestionList = [
    'Not answered',
    'Not answered',
    'Not answered',
    'Not answered',
    'Not answered',
    'Not answered',
    'Not answered',
    'Not answered',
    'Not answered',
  ];

  bool dummy;
  String dummyString;
  List<String> section;
  String test;
  bool initDB;
  int dummyInt;
  SharedPrefsModel({
    this.appTestValid = false,
    this.initDB = false,
    this.dummyInt = 0,
    this.dummyString = 'Dummy',
    this.pageTitle = 'PageTitle',
    this.emailId = 'EmailID',
    this.contact = false,
    this.dbCreated = false,
    this.cat01 =  'Incomplete',

    this.firstName = 'FirstName',
    this.lastName = 'LastName',
    this.batch = 'CAT22_GN',


    this.dummy = false,
    this.section = SharedPrefrenceConstants.tempSec,
    this.test = 'Test',
  });
}

class PracticeTestConstants {
  static const String divider = '<---!!!--->';
  static const String picDivider = '-^-';

  static const List<String> practiceSetDefault01 = [
    'Practice Test 01',
    'Incomplete',
    '60:00 (minutes:seconds)',
    'Marks per MCQ - 1 marks',
    '60'
  ];


}
class SharedPrefrenceConstants {


  static const tempSec = ['Section', 'Section', 'Section'];
}

class FullTest extends StatefulWidget {
  final String uid;
  final String url;

  static TransformationController cnt = TransformationController();
  static TransformationController cnt1 = TransformationController();

  const FullTest({
    Key? key, required this.uid, required this.url,

  }) : super(key: key);

  @override
  FullTestPageState createState() => FullTestPageState();
}

enum Option { a, b, c, d, notAnswered }

class FullTestPageState extends State<FullTest> {

  Map tempVAl = {};
  List questionList = [];
  bool ready = false;
  late String type;
  Option? options;
  List temp = [''];
  List temp2 = [''];
  List temp3 = [''];
  String timer = '';
  String answer = '';
  final Snippet snippet = Snippet();
  int color = 0;
  late Timer _timer;
  late String total;

  late String question;
  late List optionsList;
  Map dataFinal = {};
  Map mcq = {};
  Map fill = {};
  Map tf = {};
  Map mcqImg = {};
  Map fillImg = {};
  Map tfImg = {};
  List<TransformationController> controller =
  List.filled(10, FullTest.cnt, growable: true);
  List<TransformationController> controller1 =
  List.filled(10, FullTest.cnt1, growable: true);
  late TextEditingController txtController;
  late int count;
  late List<String> currentQAAns;
  late List<String> currentREAns;
  late List<String> currentCOMAns;
  late List<String> currentAns;
  Map sortedByValueMap = {};

  late List<String> currentQuest;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  late double scaleCopy;
  late final FirebaseFirestore firestore;
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
      optionsList = tempVAl.values.toList()[0];
      print("here");
      setState(() {
        ready = true;
        timerMethod(timer = '1:00');

      });

    });

    // TODO: implement initState
    timerMethod(timer = '60:00');
    options= Option.notAnswered;
    firestore = FirebaseFirestore.instance;
    count = 0;
    snippet.audioPlay('assets/audio/ready.mp3');

    txtController = TextEditingController();
    List<String> Temp = List.empty(growable: true);

    //    "MCQ (with negative marking)<---!!!--->Question No. 64<---!!!---> Directions (for questions 15 to 18): Choose the best alternatives as the answer.\n\n18. Milk always contains ..........<---!!!--->Answer:<---!!!---> Option (d): Calcium<---!!!--->Options<---!!!--->Option (a): Sugar<---!!!--->Option (b): Fat<---!!!--->Option (c): Water<---!!!--->Option (d): Calcium<---!!!--->images related question<---!!!--->default<---!!!--->images related solution<---!!!--->default<---!!!--->tables related question<---!!!--->default<---!!!--->tables related solution<---!!!--->default",
    //    "Not an MCQ (No negative marking)<---!!!--->Question No. 65<---!!!---> Raja is son of Aman's father's sister. Sachin is son of Gauri, who is the mother of Gaurav and grandmother of Aman. Aryan is the father of Tanya and grandfather of Raja. Gauri is the wife of Aryan. How is Raja related to Gauri?<---!!!--->Answer:<---!!!---> Grandson<---!!!--->Options<---!!!--->Option (a): default<---!!!--->Option (b): default<---!!!--->Option (c): default<---!!!--->Option (d): default<---!!!--->images related question<---!!!--->default<---!!!--->images related solution<---!!!--->default<---!!!--->tables related question<---!!!--->default<---!!!--->tables related solution<---!!!--->default",











    currentQuest.addAll(Temp);






    temp = currentQuest[count].split(PracticeTestConstants.divider);
    temp2 = temp[11].split(PracticeTestConstants.picDivider);
    temp3 = temp[15].split(PracticeTestConstants.picDivider);


    total = PracticeTestConstants.practiceSetDefault01[4];
    currentAns = [
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
      'Not answered',
    ];




    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement initState

    _timer.cancel();
    count;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Listener(
      onPointerUp: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(

        bottomNavigationBar: BottomAppBar(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: IconButton(
                    tooltip: 'Submit Section',
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                    onPressed: () {
                      submit();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: IconButton(
                    tooltip: 'Answer',
                    color: Colors.white70,
                    icon: const Icon(Icons.question_answer_outlined),
                    onPressed: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Answer:',
                            style:
                            Theme.of(context).textTheme.headline5),
                        content: StatefulBuilder(
                          // You need this, notice the parameters below:
                            builder: (BuildContext context,
                                StateSetter setState) {
                              (currentAns[count] == 'Not answered') ?  txtController.clear() : txtController.text =currentAns[count];
                              (currentAns[count] == 'Not answered') ?  options= Option.notAnswered : options = (currentAns[count] == 'a') ? options= Option.a : (currentAns[count] == 'b') ? options= Option.b  : (currentAns[count] == 'c') ? options= Option.c : options= Option.d;

                              return answerWidget();
                            }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: IconButton(
                    tooltip: 'Previous Question',
                    icon: const Icon(Icons.arrow_back_ios_outlined),
                    color: count != 0 ? Colors.blue : null,
                    onPressed: count != 0
                        ? () {
                      setState(() {
                        previous();
                      });
                    }
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: IconButton(
                    tooltip: 'Next Question',
                    icon: const Icon(Icons.arrow_forward_ios_outlined),
                    color:
                    count <= int.parse(total) ? Colors.red : null,
                    onPressed: count < int.parse(total) - 1
                        ? () {
                      setState(() {
                        next();
                      });
                    }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          bottom:  PreferredSize(
            preferredSize: Size.fromHeight(40.0), // here the desired height

            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${count + 1}/$total  -  Time elapsed: ',
                      style: Theme.of(context).textTheme.subtitle1),
                  Text(
                    "$timer (min:sec)",
                    style: TextStyle(
                        color: (color == 0)
                            ? Colors.lightBlue
                            : color == 1
                            ? Colors.green
                            : Colors.red,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Varela Round',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          automaticallyImplyLeading: true,
          title: Text("Tara Quiz",
              style: Theme.of(context).appBarTheme.titleTextStyle),
        ),
        body: SafeArea(
          left: true,
          right: true,
          top: true,
          bottom: true,
          minimum: EdgeInsets.only(
              left: (MediaQuery.of(context).size.width * 4) / 100,
              right: (MediaQuery.of(context).size.width * 4) / 100,
              top: (MediaQuery.of(context).size.height * 1.5) / 100,
              bottom: (MediaQuery.of(context).size.height * 1.5) / 100),
          child: customWidgetsList(temp),
        ),
      ),
    );
  }

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

              if (minutes == 10 && seconds == 1) {
                snippet.audioPlay('assets/audio/test10min.mp3');
                color = 1;
              } else if (minutes == 3 && seconds == 1) {
                snippet.audioPlay('assets/audio/test03min.mp3');
                color = 2;
              } else if (minutes == 0 && seconds == 2) {
              } else if (minutes < 0) {
                time.cancel();
                timer = '00:00';
                snippet.audioPlay('assets/audio/timeup.mp3');

                WidgetsBinding.instance.addPostFrameCallback(
                      (_) => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Time Up!',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      content: const Text(
                        'Automatic Submission in Progress...\n Thank you.',
                        softWrap: true,
                        maxLines: 10,
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            _timer.cancel();

                          },
                          child: Text(
                            'Okay',
                            style: Theme.of(context).textTheme.headline6
                                ?.copyWith(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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

  ListView customWidgetsList(temp) {

    if ((temp[0] == 'MCQ (with negative marking)') &&
        (temp[11] == 'default') &&
        (temp[15] == 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              temp[5],
              style: Theme.of(context).textTheme.subtitle1,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              temp[6],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              temp[7],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Text(
              temp[8],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Text(
            temp[9],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 1000,
          ),
        ],
      );
    } else if ((temp[0] == 'MCQ (with negative marking)') &&
        (temp[11] != 'default') &&
        (temp[15] == 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Column(
            children: customPic(temp2),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(temp[5],
                style: Theme.of(context).textTheme.headline6, maxLines: 3),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[6],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[7],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[8],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[9],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
        ],
      );
    } else if ((temp[0] == 'MCQ (with negative marking)') &&
        (temp[11] == 'default') &&
        (temp[15] != 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Column(
            children: customTable(temp3),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[5],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[6],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[7],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[8],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[9],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
        ],
      );
    } else if ((temp[0] == 'MCQ (with negative marking)') &&
        (temp[11] != 'default') &&
        (temp[15] != 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Column(
            children: customPic(temp2),
          ),
          Column(
            children: customTable(temp3),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[5],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[6],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[7],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[8],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              temp[9],
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 1000,
            ),
          ),
        ],
      );
    } else if ((temp[0] != 'MCQ (with negative marking)') &&
        (temp[11] == 'default') &&
        (temp[15] == 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(temp[0],
                style: Theme.of(context).textTheme.headline6, maxLines: 3),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
        ],
      );
    } else if ((temp[0] != 'MCQ (with negative marking)') &&
        (temp[11] != 'default') &&
        (temp[15] == 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Column(
            children: customPic(temp2),
          ),
        ],
      );
    } else if ((temp[0] != 'MCQ (with negative marking)') &&
        (temp[11] == 'default') &&
        (temp[15] != 'default')) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Column(
            children: customTable(temp3),
          ),
        ],
      );
    } else {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[0],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              temp[1],
              style: Theme.of(context).textTheme.headline6,
              maxLines: 3,
            ),
          ),
          Text(
            temp[2],
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: 10000,
          ),
          Column(
            children: customPic(temp2),
          ),
          Column(
            children: customTable(temp3),
          ),
        ],
      );
    }
  }

  Future<void> navi(int i) async {

    update();

  }

  List<Center> customPic(temp) {
    List<Center> centi = List.empty(growable: true);
    centi.add(const Center(child: Padding(padding: EdgeInsets.zero)));
    for (int i = 0; i < temp.length; i++) {
      centi.add(Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
            bottom: 12.0,
          ),
          child: SizedBox(
            width: 250,
            height: 250,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 1.7,
              transformationController: controller[i],
              boundaryMargin: const EdgeInsets.all(5.0),
              onInteractionEnd: (ScaleEndDetails endDetails) {
                controller[i].value = Matrix4.identity();

                setState(() {});
              },
              child: Image.asset(temp[i]),
            ),
          ),
        ),
      ));
    }
    return centi;
  }

  List<Padding> customTable(temp) {
    List<Padding> pad = List.empty(growable: true);
    pad.add(const Padding(padding: EdgeInsets.zero));
    for (int i = 0; i < temp.length; i++) {
      controller1[i] = TransformationController();
      pad.add(
        Padding(
          padding: EdgeInsets.only(
            top: 12.0,
            bottom: 12.0,
            left: MediaQuery.of(context).size.width * 5 / 100,
            right: MediaQuery.of(context).size.width * 5 / 100,
          ),
          child: Center(
            child: SizedBox(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 1.7,
                transformationController: controller1[i],
                boundaryMargin: const EdgeInsets.all(5.0),
                onInteractionEnd: (ScaleEndDetails endDetails) {
                  controller1[i].value = Matrix4.identity();

                  setState(() {});
                },
                child: Image.asset(temp[i]),
              ),
            ),
          ),
        ),
      );
    }
    return pad;
  }

  updateDB(String answer)  {

  }

  submit() {


    WidgetsBinding.instance.addPostFrameCallback(
          (_) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Alert',
            style: Theme.of(context).textTheme.headline4,
          ),
          content: const Text(
            'You are about to Submit.\nDo you want to proceed?',
            softWrap: true,
            maxLines: 10,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'No',
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _timer.cancel();

              },
              child: Text(
                'Yes',
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );


  }

  SizedBox answerWidget() {
    if (temp[0] == 'MCQ (with negative marking)') {
      return SizedBox(
        width: MediaQuery.of(context).size.height * 80 / 100,
        height: MediaQuery.of(context).size.height * 60 / 100,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Then, the content of your dialog.
                children: [
                  RadioListTile<Option>(
                    title: Text(
                      temp[6],
                      maxLines: 1000,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    value: Option.a,
                    groupValue: options,
                    onChanged: (Option? value) {
                      setState(() {
                        options = value;
                        print(options);
                        updateDB('a');
                        Navigator.of(context).pop(true);
                      });
                    },
                  ),
                  RadioListTile<Option>(
                    title: Text(
                      temp[7],
                      maxLines: 1000,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    value: Option.b,
                    groupValue: options,
                    onChanged: (Option? value) {
                      setState(() {
                        options = value;
                        print(options);
                        updateDB('b');
                        Navigator.of(context).pop(true);
                      });
                    },
                  ),
                  RadioListTile<Option>(
                    title: Text(
                      temp[8],
                      maxLines: 1000,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    value: Option.c,
                    groupValue: options,
                    onChanged: (Option? value) {
                      setState(() {
                        options = value;
                        print(options);
                        updateDB('c');
                        Navigator.of(context).pop(true);
                      });
                    },
                  ),
                  RadioListTile<Option>(
                    title: Text(
                      temp[9],
                      maxLines: 1000,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    value: Option.d,
                    groupValue: options,
                    onChanged: (Option? value) {
                      setState(() {
                        options = value;
                        print(options);
                        updateDB('d');
                        Navigator.of(context).pop(true);
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Center(
                          child: Text(
                            'Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.red),
                          )),
                    ),
                  )
                ]),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 70 / 100,
        height: MediaQuery.of(context).size.height * 30 / 100,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                child: TextField(
                  controller: txtController,
                  autofocus: true,
                  minLines: 5,
                  maxLines: 1000,
                  expands: false,
                  keyboardType: TextInputType.text,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      txtController.text = "";
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Cancel',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      updateDB(txtController.text);
                      txtController.text = "";
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Done',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  void previous() {
    count--;
    temp = currentQuest[count].split(PracticeTestConstants.divider);
    temp2 = temp[11].split(PracticeTestConstants.picDivider);
    temp3 = temp[15].split(PracticeTestConstants.picDivider);
  }

  void next() {
    count++;
    temp = currentQuest[count].split(PracticeTestConstants.divider);
    temp2 = temp[11].split(PracticeTestConstants.picDivider);
    temp3 = temp[15].split(PracticeTestConstants.picDivider);
  }



  void update() async {

    bool isConnected;
    try {
      isConnected = await snippet.connectivityCheck();
      if(isConnected) {



      } else {
        update();
      }
    } catch (e) {
      debugPrint('error: $e');


      //  throw UnimplementedError(e.toString());
    }

  }


}
