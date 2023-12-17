import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:taraquizbup/configs/constants/constants.dart';
import 'package:taraquizbup/dashboard/commonPage.dart';
import 'package:taraquizbup/dashboard/model/dashboard_model.dart';
import 'package:taraquizbup/dashboard/selectSubject.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardModel dashboardModel = DashboardModel();
  bool ready = false;
  bool hasSubjects = false;
  Map tempMap = {};
  Map tempMap2 = {};
  Map individualAllScore = {};
  Map groupAllScore = {};
  Map completedQuiz = {};
  Map overAllScore = {};
  Map proMap = {};
  List<Map> subjects = List.empty(growable: true);
  List<String> subjectsCode = List.empty(growable: true);

  Map finalMap = Map();

  List<Map> students = List.empty(growable: true);
  List<String> studentSubjectCode = List.empty(growable: true);
  Map studentsDetails = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Hive.openBox('taraQuizAppData').then((ref) {
      dashboardModel.uid = ref.get("uid");
      dashboardModel.dName = ref.get("dName");
      dashboardModel.eMailId = ref.get("eMail");
      dashboardModel.mobileNumber = ref.get('mobile');
      dashboardModel.rToken = ref.get('rToken');
      dashboardModel.isDash = ref.get('isSignedIn');
      dashboardModel.signInMethod = ref.get('signedInMethod');
      dashboardModel.profilePhotoURL = ref.get('photoURL');
      dashboardModel.subjectDetails =
          ref.get('subjects') ?? AppConstants.defaultMapConstant;
    }).whenComplete(() {
      if (dashboardModel.subjectDetails.length == 1 &&
          dashboardModel.subjectDetails.keys.first == "default") {
        FirebaseFirestore.instance
            .collection('StudentsDetails')
            .doc(dashboardModel.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          final databaseReference = FirebaseDatabase.instance.ref();
          await databaseReference
              .child("forStudents/profrssorsList")
              .get()
              .then((proValue) {
            if (proValue.exists) {
              proMap.addAll(proValue.value as Map);
            }
          });

          if (documentSnapshot.exists) {
            tempMap = documentSnapshot.data() as Map;
            if (tempMap["CompletedQuiz"] != null) {
              completedQuiz = tempMap["CompletedQuiz"];
                print(completedQuiz);
            }
            if (tempMap["Subject"] != null) {
Future.delayed(Duration(milliseconds: 1000));
              setState(() {
                dashboardModel.profilePhotoURL = tempMap["photoUrl"];
                dashboardModel.subjectDetails = tempMap["Subject"];
                dashboardModel.subjectDetails.forEach((key, value) {
                  if (key != "default") subjectsCode.add(key);
                  if (value != "default") subjects.add(value);
                });
                if (subjects.isNotEmpty) {
                  hasSubjects = true;
                  ready = true;
                } else {
                  ready = true;

                  hasSubjects;
                }
              });
            } else {
              setState(() {
                hasSubjects;
                ready = true;
              });
            }
          }
        });
      } else {

        hasSubjects;
        ready = true;
      }
    });
  }

  Widget _body() {
    if (dashboardModel.profilePhotoURL == "default_str")
      dashboardModel.profilePhotoURL = AppConstants.defaultURLConstant;
    return Container(
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
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 8 / 100),
        child: ListView.builder(
            itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 10 / 100,
                      right: MediaQuery.of(context).size.width * 10 / 100,
                      bottom: MediaQuery.of(context).size.height * 1.5 / 100,
                      top: MediaQuery.of(context).size.height * 1.5 / 100),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        subjects[index]["Name"],
                        maxLines: 3,
                      ),
                      subtitle: Text(
                        "Subject Code: ${subjectsCode[index]}\nProfessor's Name: ${subjects[index]["ProfName"]}\n",
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      onTap: () {
                        List<Map> finalList = List.empty(growable: true);
                        List<String> finalTestCodeList = List.empty(growable: true);

                        final databaseReference = FirebaseDatabase.instance.ref();
                        List finalOverListList = List.empty(growable: true);
                        print(subjects[index]["ProfUID"]);
                        print(subjectsCode[index]);
                        databaseReference.child("overAllScore/${subjects[index]["ProfUID"]}/${subjectsCode[index]}").get().then((value) {
                          print(value.exists);
                          if(value.exists){

                        Map temp = Map();
                        List tempKey = List.empty(growable: true);
                        List tempValue = List.empty(growable: true);
                        Map tempFinalScore = Map();
                        Map tempFinalName = Map();

                        Map tempFinalPhoto = Map();

                        temp = value.value as Map;
                        temp.forEach((key, value) {
                          tempKey.add(key);
                          tempValue.add(value);
                        });
                       print(tempKey.length);
                        for (int i = 0; i < tempKey.length; i++) {
                          tempFinalScore.addEntries({i: tempValue[i]["Score"]}.entries);
                          tempFinalName.addEntries({i: tempValue[i]["Name"]}.entries);
                          tempFinalPhoto.addEntries({i: tempValue[i]["photoURL"]}.entries);
                        }
                        Map sortedByValueMap = Map.fromEntries(
                            tempFinalScore.entries.toList()
                              ..sort((e1, e2) => e1.value.compareTo(e2.value)));

                        List tempKey1 = List.empty(growable: true);
                        List tempValue1 = List.empty(growable: true);
                        sortedByValueMap.forEach((key, value) {
                          tempKey1.add(key);
                          tempValue1.add(value);
                        });
                        for (int i = tempKey1.length - 1; i >= 0; i--) {
                          finalOverListList.add({
                            "Score": tempValue1[i],
                            "Name": tempFinalName[tempKey1[i]],
                            "photoURL": tempFinalPhoto[tempKey1[i]]
                          });
                        }

                      }


                      print(finalOverListList);


                        }) ;
                        print(finalOverListList);
                        List finalIndividualList = List.empty(growable: true);
                        databaseReference.child("individualScore/${subjects[index]["ProfUID"]}/${subjectsCode[index]}").get().then((value) {
                         if(value.exists){

                           Map temp = Map();
                           List tempKey = List.empty(growable: true);
                           List tempValue = List.empty(growable: true);
                           Map tempFinalScore = Map();
                           Map tempFinalName = Map();

                           Map tempFinalPhoto = Map();

                           temp = value.value as Map;
                           temp.forEach((key, value) {
                             tempKey.add(key);
                             tempValue.add(value);
                           });

                           for (int i = 0; i < tempKey.length; i++) {
                             tempFinalScore.addEntries({i: tempValue[i]["Score"]}.entries);
                             tempFinalName.addEntries({i: tempValue[i]["Name"]}.entries);
                             tempFinalPhoto
                                 .addEntries({i: tempValue[i]["photoURL"]}.entries);
                           }
                           Map sortedByValueMap = Map.fromEntries(
                               tempFinalScore.entries.toList()
                                 ..sort((e1, e2) => e1.value.compareTo(e2.value)));

                           List tempKey1 = List.empty(growable: true);
                           List tempValue1 = List.empty(growable: true);
                           sortedByValueMap.forEach((key, value) {
                             tempKey1.add(key);
                             tempValue1.add(value);
                           });
                           for (int i = tempKey1.length - 1; i >= 0; i--) {
                             finalIndividualList.add({
                               "Score": tempValue1[i],
                               "Name": tempFinalName[tempKey1[i]],
                               "photoURL": tempFinalPhoto[tempKey1[i]]
                             });
                           }





                         }
                         print(finalIndividualList);

                        }) ;
                        print(finalIndividualList);

                        FirebaseFirestore.instance
                            .collection('ProfessorsDetails')
                            .doc(subjects[index]["ProfUID"])
                            .get()
                            .then((value) {
                              if(value.exists){
                          Map totalMap = Map();
                          Map subTotalMap = {};
                          totalMap = value.data() as Map;
                          subTotalMap
                              .addAll(totalMap["Quiz"][subjectsCode[index]]);
                          subTotalMap.values.forEach((element) {
                            finalList.add(element as Map);
                          });
                          subTotalMap.keys.forEach((element) {
                            finalTestCodeList.add(element);
                          });

                        }
                      }).whenComplete(() {
                          List temp = [];
                          if (completedQuiz[subjectsCode[index]] != null)  temp = completedQuiz[subjectsCode[index]];
                          List<String> temp2finalcode = finalTestCodeList;
                          print("temp2finalcode1");

                          List<int> indeElement = List.empty(growable: true);
                          temp.forEach((element) {
                            print(temp);
                            print(temp2finalcode);
                            print(temp2finalcode.indexOf(element.toString().split("_")[0])) ;
                           indeElement.add(temp2finalcode.indexOf(element.toString().split("_")[0])) ;
                            });
                          print("temp2finalcode4");

                          print(indeElement);
                          Future.delayed(Duration(seconds: 3));

                          for(int i = 0; i<indeElement.length;i++){
                           int ind = indeElement[i];
                           print(ind);
                           print("temp2finalcode3");

                           temp2finalcode.replaceRange(ind, ind + 1, ["Completed"]);
                           print(temp2finalcode);

                         }
                          Future.delayed(Duration(seconds: 3));
                          Map finalGroupList = {};
                           databaseReference.child("quizRoom/${subjects[index]["ProfUID"]}/${subjectsCode[index]}").get().then((value) {
                            if(value.exists){
    finalGroupList = value.value as Map;


    print(finalGroupList);
    print("temp2finalcode0");

                          }}) ;

                          Future.delayed(Duration(seconds: 3),(){
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => CommonPage(
                                     completedQuiz: temp2finalcode,
                                     title: "Subject Tests",
                                     name: '${subjects[index]["ProfName"]}',
                                     emailId: '',
                                     url: "",
                                     uid: dashboardModel.uid,
                                     subTitle: "",
                                     stdName: dashboardModel.dName,
                                     stdPhoto: dashboardModel.profilePhotoURL,
                                     subjectCode: subjectsCode[index],
                                     subjectName: "${subjects[index]["Name"]}",
                                     testCodeList: finalTestCodeList,
                                     studentORProf: '',
                                     testDetailsList: finalList,
                                     studentCodeList: [],
                                     studentDetailsList: {},
                                     finalOverAllList: finalOverListList,
                                     finalIndividualList: finalIndividualList,
                                     finalGroupList: finalGroupList,
                                   )),
                             );

                           });
                        });
                      },
                    ),
                  ),
                ),
            itemCount: subjects.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => SelectSubject(
                        data: proMap,
                        uid: dashboardModel.uid,
                    isSubject: true,
                      ),
                  maintainState: true,
                  fullscreenDialog: false),
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text(PageTitleConstants.dashboardScreenTitle),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            SizedBox(
              height: 265,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    shape: BoxShape.rectangle), //BoxDecoration
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      shape: BoxShape.rectangle),
                  accountName:
                      ready && (dashboardModel.profilePhotoURL != "default_str")
                          ? Text(
                              dashboardModel.dName,
                            )
                          : const Text("Loading...."),
                  accountEmail:
                      ready && (dashboardModel.profilePhotoURL != "default_str")
                          ? Text(dashboardModel.eMailId)
                          : const Text("Loading...."),
                  currentAccountPictureSize: const Size.square(100),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: ready
                        ? NetworkImage(
                            (dashboardModel.profilePhotoURL == "default_str")
                                ? dashboardModel.profilePhotoURL =
                                    AppConstants.defaultURLConstant
                                : dashboardModel.profilePhotoURL)
                        : const NetworkImage(
                            "https://source.unsplash.com/dLij9K4ObYY",
                            scale: 1),
                  ), //circleAvatar
                ), //UserAccountDrawerHeader
              ),
            ),
            _customList(), //DrawerHeader
          ],
        ),
      ),
      //Drawer
      body: ready
          ? hasSubjects
              ? _body()
              : const Center(
                  child: Text(
                      "No Subject to created yet.\nClick '+' to create a Subject."),
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



  _customList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 60 / 100,
      child: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          leading: Icon(
            AppButtonsConstants.drawerButtonsIcons[index],
            color: AppButtonsConstants.drawerButtonsColors[index],
          ),
          title: Text(AppButtonsConstants.drawerButtonsName[index]),
          onTap: () {
            switch (index) {
              case 0:
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommonPage(
                            title: "My Profile",
                            name: dashboardModel.dName,
                            emailId: dashboardModel.eMailId,
                            stdPhoto: "",
                            completedQuiz: [],
                            stdName: "",
                            url: dashboardModel.profilePhotoURL,
                            uid: dashboardModel.uid,
                            subTitle: "",
                            subjectCode: '',
                            subjectName: '',
                            testCodeList: [],
                            studentORProf: '',
                            testDetailsList: [],
                            studentCodeList: [],
                            studentDetailsList: {},
                            finalOverAllList: [],
                            finalIndividualList: [],
                            finalGroupList: {},
                          )),
                );
                break; // The switch statement must be told to exit, or it will execute every case.
              case 1:
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommonPage(
                            title: "Contact us",
                            stdPhoto: "",
                            completedQuiz: [],
                            stdName: "",
                            name: dashboardModel.dName,
                            emailId: dashboardModel.eMailId,
                            url: dashboardModel.profilePhotoURL,
                            uid: dashboardModel.uid,
                            subTitle: "",
                            subjectCode: '',
                            subjectName: '',
                            testCodeList: [],
                            studentORProf: '',
                            testDetailsList: [],
                            studentCodeList: [],
                            studentDetailsList: {},
                            finalOverAllList: [],
                            finalIndividualList: [],
                            finalGroupList: {},
                          )),
                );

                break;
              case 2:
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommonPage(
                            title: "Support",
                            name: dashboardModel.dName,
                            emailId: dashboardModel.eMailId,
                            url: dashboardModel.profilePhotoURL,
                            uid: dashboardModel.uid,
                            stdPhoto: "",
                            stdName: "",
                            subTitle: "",
                            subjectCode: '',
                            subjectName: '',
                            testCodeList: [],
                            studentORProf: '',
                            testDetailsList: [],

                            completedQuiz: [],
                            studentCodeList: [],
                            studentDetailsList: {},
                            finalOverAllList: [],
                            finalIndividualList: [],
                            finalGroupList: {},
                          )),
                );
                break;
              case 3:
                Navigator.of(context).pop();
                FirebaseAuth.instance
                    .signOut()
                    .then((_) => {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              RoutesConstants.signInScreenRoute,
                              (Route<dynamic> generateRoute) => false,
                            );
                          }),
                        })
                    .catchError(onError);
                break;
              case 4:
                {
                  Navigator.of(context).pop();
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  break;
                }

              default:
                if (kDebugMode) {
                  print('choose a different number!');
                }
            }
          },
        ),
        itemCount: AppButtonsConstants.drawerButtonsIcons.length,
      ),
    );
  }

  FutureOr<Map<dynamic, dynamic>> onError(dynamic object, dynamic stackTrace) {
    Map<dynamic, dynamic> error = {object: stackTrace};
    return error;
  }
}
