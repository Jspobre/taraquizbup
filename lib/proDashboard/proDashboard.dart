import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:taraquizbup/proDashboard/proCommonPage.dart';
import 'package:taraquizbup/proDashboard/testPreparation.dart';

import '../configs/constants/constants.dart';
import 'model/prodashboard_model.dart';

class ProDashboard extends StatefulWidget {
  @override
  _ProDashboardState createState() => _ProDashboardState();
}

class _ProDashboardState extends State<ProDashboard> {
  final ProDashboardModel proDashboardModel = ProDashboardModel();
  bool ready = false;
  bool hasSubjects = false;

  String fileURL = "";
  var ref = FirebaseDatabase.instance.ref();
  int? selectedIndex;
  Map tempMap = {};
  Map tempMap2 = {};

  List<Map> subjects = List.empty(growable: true);
  List<String> subjectsCode = List.empty(growable: true);
  List<Map> students = List.empty(growable: true);
  List<String> studentSubjectCode = List.empty(growable: true);
  Map studentsDetails = {};

  List<Map> testDetailsCode = List.empty(growable: true);
  List<String> testList = List.empty(growable: true);

  @override
  void initState() {
    Hive.openBox('taraQuizAppData').then((value) {
      proDashboardModel.uid =
          value.get("uid") ?? AppConstants.defaultStringConstant;
      proDashboardModel.dName =
          value.get("dName") ?? AppConstants.defaultStringConstant;
      proDashboardModel.eMailId =
          value.get("eMail") ?? AppConstants.defaultStringConstant;
      proDashboardModel.mobileNumber =
          value.get("mobile") ?? AppConstants.defaultStringConstant;
      proDashboardModel.proSubjectDetails =
          value.get("subjects") ?? AppConstants.defaultMapConstant;
      proDashboardModel.profilePhotoURL = value.get("photoURL");
      if (proDashboardModel.proSubjectDetails.length == 1 &&
          proDashboardModel.proSubjectDetails.keys.first == "default") {
        FirebaseFirestore.instance
            .collection('ProfessorsDetails')
            .doc(proDashboardModel.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            tempMap = documentSnapshot.data() as Map;
            if (tempMap["Subject"] != null) {
              setState(() {
                proDashboardModel.profilePhotoURL = tempMap["photoUrl"];
                proDashboardModel.proSubjectDetails = tempMap["Subject"];
                if (tempMap["Quiz"] != null) tempMap2 = tempMap["Quiz"];
                if (tempMap["StudentsEnrolled"] != null)
                  proDashboardModel.proStudentDetails =
                      tempMap["StudentsEnrolled"];
                proDashboardModel.proSubjectDetails.forEach((key, value) {
                  if (key != "default") subjectsCode.add(key);
                  if (value != "default") subjects.add(value);
                });
                List<Map> tempList = List.empty(growable: true);
                proDashboardModel.proStudentDetails.forEach((key, value) {
                  if (key != "default") studentSubjectCode.add(key);
                  if (value != "default") tempList.add(value);
                });
                tempList.forEach((element) {
                  students.add(element);
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
        setState(() {
          hasSubjects = true;
          ready = true;
        });
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      appBar: AppBar(
        title: const Text(PageTitleConstants.dashboardScreenTitle),
        automaticallyImplyLeading: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TestPreparation(
                        title: "Add Subject",
                        name: proDashboardModel.dName,
                        dataExist: hasSubjects,
                        uid: proDashboardModel.uid,
                        subjects: proDashboardModel.proSubjectDetails,
                        subjectCode: '',
                        subTitle: "",
                      ),
                  maintainState: false),
            );
          },
        ),
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
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      shape: BoxShape.rectangle),
                  accountName: ready
                      ? Text(
                          proDashboardModel.dName,
                        )
                      : const Text("Loading...."),
                  accountEmail: ready
                      ? Text(proDashboardModel.eMailId)
                      : const Text("Loading...."),
                  currentAccountPictureSize: const Size.square(100),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: ready
                        ? NetworkImage(
                            (proDashboardModel.profilePhotoURL == "default_str")
                                ? proDashboardModel.profilePhotoURL =
                                    AppConstants.defaultURLConstant
                                : proDashboardModel.profilePhotoURL)
                        : NetworkImage(
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
                      "No Subject created yet.\nClick '+' to create a Subject."),
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
            AppButtonsConstants.drawerProButtonsIcons[index],
            color: AppButtonsConstants.drawerProButtonsColors[index],
          ),
          title: Text(AppButtonsConstants.drawerProButtonsName[index]),
          onTap: () {
            print(proDashboardModel.profilePhotoURL);

            switch (index) {
              case 0:
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProCommonPage(
                            finalStudentListForProfs: {},
                            title: "My Profile",
                            name: proDashboardModel.dName,
                            emailId: proDashboardModel.eMailId,
                            url: proDashboardModel.profilePhotoURL,
                            uid: proDashboardModel.uid,
                            subTitle: "",
                            studentORProf: 'Professor',
                            testDetailsList: [],
                            testCodeList: [],
                            subjectName: "",
                            subjectCode: "",
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
                      builder: (context) => ProCommonPage(
                            finalStudentListForProfs: {},
                            title: "Support",
                            name: proDashboardModel.dName,
                            emailId: proDashboardModel.eMailId,
                            url: proDashboardModel.profilePhotoURL,
                            uid: proDashboardModel.uid,
                            subTitle: "",
                            studentORProf: 'Professor',
                            testDetailsList: [],
                            testCodeList: [],
                            subjectName: "",
                            studentCodeList: [],
                            studentDetailsList: {},
                            subjectCode: "",
                            finalOverAllList: [],
                            finalIndividualList: [],
                            finalGroupList: {},
                          )),
                );
                break;
              case 2:
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
              case 3:
                {
                  Navigator.of(context).pop();
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  break;
                }

              default:
                print('choose a different number!');
            }
          },
        ),
        itemCount: AppButtonsConstants.drawerProButtonsIcons.length,
      ),
    );
  }

  FutureOr<Map<dynamic, dynamic>> onError(dynamic object, dynamic stackTrace) {
    Map<dynamic, dynamic> error = {object: stackTrace};
    return error;
  }

  Future<void> deleteSubject(String proDashboardModeluid, int index) async {
    try {
      String subjectCode = subjectsCode[index];

      // Deleting the subject from ProfessorsDetails
      await FirebaseFirestore.instance
          .collection('ProfessorsDetails')
          .doc(proDashboardModeluid)
          .update({
        'Subject.$subjectCode': FieldValue.delete(),
      });

      // delete the subject from the student side
      QuerySnapshot studentSnapshot =
          await FirebaseFirestore.instance.collection('StudentsDetails').get();

      for (QueryDocumentSnapshot doc in studentSnapshot.docs) {
        Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
        if (studentData.containsKey('Subject')) {
          Map<String, dynamic> subjects =
              studentData['Subject'] as Map<String, dynamic>;
          if (subjects.containsKey(subjectCode)) {
            subjects.remove(subjectCode);

            await FirebaseFirestore.instance
                .collection('StudentsDetails')
                .doc(doc.id)
                .update({'Subject': subjects});
          }
        }
      }

      print(
          'Subject data deleted successfully from both ProfessorsDetails and StudentDetails');
    } catch (e) {
      print('Error deleting subject data: $e');
    }
  }

  Widget _body() {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Subject?'),
              content: Text('Are you sure you want to delete this subject?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    if (selectedIndex != null) {
                      await deleteSubject(
                          proDashboardModel.uid, selectedIndex!);
                      setState(() {
                        subjects.removeAt(selectedIndex!);
                        subjectsCode.removeAt(selectedIndex!);
                        selectedIndex =
                            null; // Reset selected index after deletion
                      });
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
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
            bottom: MediaQuery.of(context).size.height * 8 / 100,
          ),
          child: ListView.builder(
            itemBuilder: (context, index) => subjects.length > index
                ? Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 10 / 100,
                      right: MediaQuery.of(context).size.width * 10 / 100,
                      bottom: MediaQuery.of(context).size.height * 1.5 / 100,
                      top: MediaQuery.of(context).size.height * 1.5 / 100,
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(subjects[index]["Name"]),
                        subtitle: Text(
                          "Subject Code: ${subjectsCode[index]}\nPassword: ${subjects[index]["Password"]}\n",
                          maxLines: 3,
                        ),
                        isThreeLine: true,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          // Handle other functionalities when a subject is tapped
                          // ... (existing functionality)
                        },
                      ),
                    ),
                  )
                : SizedBox.shrink(), // Hide the subject if it doesn't exist
            itemCount: subjects.length,
          ),
        ),
      ),
    );
  }
}
