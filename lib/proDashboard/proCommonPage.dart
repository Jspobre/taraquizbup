import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailjet/mailjet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taraquizbup/proDashboard/testPreparation.dart';

import '../configs/constants/constants.dart';
import '../helpers/email.dart';
import '../widgets/custom_dialog.dart';
import 'displayQuestions.dart';

class ProCommonPage extends StatefulWidget {
  final String title;
  final String subTitle;
  final String name;
  final String emailId;
  final String subjectCode;
  final String subjectName;

  final String studentORProf;
  late String url;
  final String uid;

  final List<String> testCodeList;
  final List finalOverAllList;
  final List finalIndividualList;
  final Map finalGroupList;

  final List<Map> testDetailsList;
  final List<String> studentCodeList;

  final Map studentDetailsList;
  final Map finalStudentListForProfs;

  ProCommonPage(
      {Key? key,
      required this.title,
      required this.finalStudentListForProfs,
      required this.subTitle,
      required this.name,
      required this.emailId,
      required this.subjectCode,
      required this.subjectName,
      required this.testCodeList,
      required this.url,
      required this.studentORProf,
      required this.testDetailsList,
      required this.uid,
      required this.studentCodeList,
      required this.studentDetailsList,
      required this.finalOverAllList,
      required this.finalIndividualList,
      required this.finalGroupList})
      : super(key: key);

  @override
  State<ProCommonPage> createState() => _ProCommonPageState();
}

class _ProCommonPageState extends State<ProCommonPage> {
  bool ready = true;

  final TextEditingController controllerSubject = TextEditingController();

  final TextEditingController controllerQuery = TextEditingController();

  int _selectedIndex = 0;

  String path = '';

  final FocusNode focusNodeSubject = FocusNode();

  final FocusNode focusNodeQuery = FocusNode();

  bool timer = false;
  late String url = '';
  Map data = {};

  CustomDialog customDialog = CustomDialog();

  //? for scores list toget ===========
  String scoresMode = 'Individual';

  // ? ================================

  @override
  Widget build(BuildContext context) {
    // ? FOR SCORES LIST DATA===============================
    List<Map<String, dynamic>> newFinalIndividualList =
        List.from(widget.finalIndividualList);

    newFinalIndividualList.forEach((individual) {
      String fullName = individual['Name'] as String;
      List<String> nameParts = fullName.split(' ');

      // Ensure there are at least two parts (first name and last name)
      if (nameParts.length >= 2) {
        String lastName = nameParts[1]; // Last name
        String firstName = nameParts[0]; // First name

        // Modify 'name' property to be in 'Last Name, First Name' format
        individual['Name'] = '$lastName, $firstName';
      }
    });

    newFinalIndividualList.sort((a, b) {
      final String nameA = (a['Name'] as String).toLowerCase();
      final String nameB = (b['Name'] as String).toLowerCase();
      return nameA.compareTo(nameB);
    });

    print(widget.subjectCode);
    // ? ==================================================

    Widget _body(String title) {
      return (title == "Support")
          ?
          //Support
          Container(
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
                  top: 10,
                  bottom: 10,
                  left: (MediaQuery.of(context).size.width * 4) / 100,
                  right: (MediaQuery.of(context).size.width * 4) / 100,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 90 / 100,
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 1.0, right: 1.0),
                        child: TextFormField(
                          onChanged: (value) {
                            controllerSubject.text = value;
                          },
                          focusNode: focusNodeSubject,
                          controller: controllerSubject,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelText: 'Subject',
                          ),
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black),
                        ),
                      ),
                      //===> Query Text Input starts from here <===
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 1.0, right: 1.0),
                        child: TextFormField(
                          onChanged: (value) {
                            controllerQuery.text = value;
                          },
                          focusNode: focusNodeQuery,
                          controller: controllerQuery,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelText: 'Your Query',
                          ),
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black),
                          maxLines: 6,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 1.0, right: 1.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Mail mail = Mail();
                            mail.sendEmail(
                                context,
                                title,
                                widget.name,
                                widget.emailId,
                                controllerSubject.text,
                                controllerQuery.text);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 65.0),
                            child: Text(
                              "Submit",
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: ((MediaQuery.of(context).size.height * 4) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 4) / 100),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Back',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          :
          // Profile.....
          Container(
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
                  top: 10,
                  bottom: 10,
                  left: (MediaQuery.of(context).size.width * 4) / 100,
                  right: (MediaQuery.of(context).size.width * 4) / 100,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 90 / 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: ((MediaQuery.of(context).size.height * 4) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 4) / 100),
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundImage: ready
                              ? NetworkImage((widget.url == "default_str")
                                  ? url = AppConstants.defaultURLConstant
                                  : widget.url)
                              : NetworkImage(
                                  "https://source.unsplash.com/dLij9K4ObYY",
                                  scale: 1),
                        ),
                      ),
                      Text(
                        "Name: ${widget.name}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        "email id: ${widget.emailId}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: ((MediaQuery.of(context).size.height * 4) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 4) / 100),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Back',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
    }

    Widget widgetSelect(int index) {
      switch (index) {
        case 0:
          return widget.testCodeList.isNotEmpty
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          widget.subTitle,
                          maxLines: 4,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.blue),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          child: StatefulBuilder(builder: (context, setState) {
                            return ListView.builder(
                                itemBuilder: (context, index) {
                                  String fileName =
                                      "${widget.testDetailsList[index]["excelURL"]}";
                                  fileName = fileName.split(".xls")[0];

                                  fileName = fileName.trim().split(
                                      "https://firebasestorage.googleapis.com/v0/b/tara-quiz-bup.appspot.com/o/")[1];

                                  fileName = fileName + ".xls";
                                  String fileToDownload = '/${fileName}';
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                1.5 /
                                                100,
                                        top:
                                            MediaQuery.of(context).size.height *
                                                1.5 /
                                                100),
                                    child: Card(
                                      child: ListTile(
                                        leading:
                                            "${widget.testDetailsList[index]["Type"]}" ==
                                                    "20_min_single"
                                                ? const Icon(
                                                    Icons.person,
                                                    color: Colors.blue,
                                                  )
                                                : "${widget.testDetailsList[index]["Type"]}" ==
                                                        "60_min_single"
                                                    ? const Icon(
                                                        Icons.person,
                                                        color: Colors.orange,
                                                      )
                                                    : const Icon(
                                                        Icons.people,
                                                        color: Colors.green,
                                                      ),
                                        title: Text(widget
                                            .testDetailsList[index]["Title"]),
                                        subtitle: Column(
                                          children: [
                                            "${widget.testDetailsList[index]["Type"]}" ==
                                                    "20_min_single"
                                                ? Text(
                                                    "Type:  20 Minutes Quiz\nStatus: ${widget.testDetailsList[index]["status"]}\n")
                                                : "${widget.testDetailsList[index]["Type"]}" ==
                                                        "60_min_single"
                                                    ? Text(
                                                        "Type:  60 Minutes Quiz\nStatus: ${widget.testDetailsList[index]["status"]}\n")
                                                    : Text(
                                                        "Type:  Multiplayer\nStatus: ${widget.testDetailsList[index]["status"]}\n"),
                                            "${widget.testDetailsList[index]["status"]}" ==
                                                    "Not Uploaded"
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons.attach_email),
                                                        onPressed: () async {
                                                          final storageRef =
                                                              FirebaseStorage
                                                                  .instance
                                                                  .ref();
                                                          final islandRef =
                                                              storageRef.child(
                                                                  fileToDownload);
                                                          //First you get the documents folder location on the device...
                                                          Directory appDocDir =
                                                              await getApplicationDocumentsDirectory();
                                                          //Here you'll specify the file it should be saved as
                                                          File downloadToFile =
                                                              File(
                                                                  '${appDocDir.path}/${fileName}');
                                                          final downloadTask =
                                                              islandRef.writeToFile(
                                                                  downloadToFile);
                                                          downloadTask
                                                              .snapshotEvents
                                                              .listen(
                                                                  (taskSnapshot) async {
                                                            switch (taskSnapshot
                                                                .state) {
                                                              case TaskState
                                                                    .running:
                                                                print(
                                                                    "Running");
                                                                break;
                                                              case TaskState
                                                                    .paused:
                                                                print("Paused");
                                                                break;
                                                              case TaskState
                                                                    .success:
                                                                MailJet
                                                                    mailJet =
                                                                    MailJet(
                                                                  apiKey:
                                                                      apiKey,
                                                                  secretKey:
                                                                      secretKey,
                                                                );
                                                                await mailJet
                                                                    .sendEmail(
                                                                  subject: widget
                                                                              .testDetailsList[
                                                                          index]
                                                                      ["Title"],
                                                                  sender:
                                                                      Sender(
                                                                    email:
                                                                        myContactEmail,
                                                                    name:
                                                                        "Tara Quiz",
                                                                  ),
                                                                  reciepients: [
                                                                    Recipient(
                                                                      email:
                                                                          mySupportReceiverEmail,
                                                                      name:
                                                                          "Tara Quiz",
                                                                    ),
                                                                  ],
                                                                  htmlEmail:
                                                                      widget
                                                                          .title,
                                                                  Attachments: [
                                                                    downloadToFile
                                                                  ],
                                                                )
                                                                    .whenComplete(
                                                                        () {
                                                                  showDialog(
                                                                      barrierDismissible:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                                            title: const Icon(
                                                                              Icons.check_circle,
                                                                              color: Colors.green,
                                                                              size: 60,
                                                                            ),
                                                                            content: Text(
                                                                              "File format successfully mailed.\n Please fill the details and upload.",
                                                                              maxLines: 7,
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            actions: <Widget>[
                                                                              TextButton(
                                                                                  child: Text(
                                                                                    'Okay',
                                                                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                  }),
                                                                            ]);
                                                                      });
                                                                });
                                                                break;
                                                              case TaskState
                                                                    .canceled:
                                                                print(
                                                                    "Canceled");
                                                                break;
                                                              case TaskState
                                                                    .error:
                                                                print("error");
                                                                break;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.upload_file),
                                                        onPressed: () async {
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                                  allowMultiple:
                                                                      false)
                                                              .then(
                                                                  (value) async {
                                                            if (value != null) {
                                                              path = value.files
                                                                  .single.path!;

                                                              //  type = data.keys.toList()[0];
                                                              //  tempVAl = data.values.toList()[0];
                                                              //   questionList = tempVAl.keys.toList()[0];
                                                              //   question = questionList[0];
                                                              //   optionsList = tempVAl.values.toList()[0];

                                                              List rowdetail0 =
                                                                  [];
                                                              List rowdetail1 =
                                                                  [];
                                                              List rowdetail2 =
                                                                  [];
                                                              var bytes = File(
                                                                      path)
                                                                  .readAsBytesSync();
                                                              // Parse the Excel file
                                                              final excel =
                                                                  Excel.decodeBytes(
                                                                          bytes)
                                                                      .tables;
                                                              for (var table
                                                                  in excel
                                                                      .keys) {
                                                                for (var row
                                                                    in excel[
                                                                            table]!
                                                                        .rows) {
                                                                  rowdetail0
                                                                      .add(row[
                                                                              0]
                                                                          ?.value);
                                                                  rowdetail1
                                                                      .add(row[
                                                                              1]
                                                                          ?.value);
                                                                  rowdetail2
                                                                      .add(row[
                                                                              2]
                                                                          ?.value);
                                                                }
                                                              }

                                                              for (int i = 0;
                                                                  i <
                                                                      rowdetail1
                                                                          .length;
                                                                  i++) {
                                                                data.addEntries(
                                                                    {
                                                                  i: rowdetail1[
                                                                      i]
                                                                }.entries);
                                                              }
                                                              int j = 0;
                                                              for (int i =
                                                                      rowdetail1
                                                                          .length;
                                                                  j <
                                                                      rowdetail2
                                                                          .length;
                                                                  i++) {
                                                                data.addEntries(
                                                                    {
                                                                  i: rowdetail2[
                                                                      j]
                                                                }.entries);
                                                                j++;
                                                              }
                                                            }
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DisplayQuestions(
                                                                            fileName:
                                                                                fileName,
                                                                            index:
                                                                                index,
                                                                            path:
                                                                                path,
                                                                            data:
                                                                                data,
                                                                            subjectCode:
                                                                                widget.subjectCode,
                                                                            testCodeList:
                                                                                widget.testCodeList,
                                                                            testDetailsList:
                                                                                widget.testDetailsList,
                                                                            uid:
                                                                                widget.uid,
                                                                          ),
                                                                  maintainState:
                                                                      false),
                                                            );
                                                          });
                                                        },
                                                      )
                                                    ],
                                                  )
                                                : SizedBox.shrink()
                                          ],
                                        ),
                                        isThreeLine: true,
                                        onTap: () {},
                                      ),
                                    ),
                                  );
                                },
                                itemCount: widget.testCodeList.length);
                          }),
                        ),
                      ),
                    ],
                  ))
              : const Center(
                  child: Text(
                      "No Test created yet.\nClick \"\+\" to create a Test."),
                );

        case 1:
          {
            return widget.finalStudentListForProfs.isNotEmpty
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
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: (MediaQuery.of(context).size.width * 4) / 100,
                        right: (MediaQuery.of(context).size.width * 4) / 100,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "Students Enrolled",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.blue),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  // TODO ADD UNENroLL STUDENTS
                                  return Card(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1.5 /
                                              100,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1.5 /
                                              100),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Image.network(widget
                                                  .finalStudentListForProfs.keys
                                                  .elementAt(index)),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.finalStudentListForProfs
                                                  .values
                                                  .elementAt(index)
                                                  .toString(),
                                              maxLines: 2,
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                handleDelete(index);
                                                String key = widget
                                                    .finalStudentListForProfs
                                                    .keys
                                                    .elementAt(index);

                                                setState(() {
                                                  widget
                                                      .finalStudentListForProfs
                                                      .remove(key);
                                                });
                                              },
                                              icon: Icon(Icons.person_remove))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount:
                                    widget.finalStudentListForProfs.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text("No Students enrolled yet."),
                  );
          }
        case 2:
          {
            return widget.finalOverAllList.isNotEmpty
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
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: (MediaQuery.of(context).size.width * 4) / 100,
                        right: (MediaQuery.of(context).size.width * 4) / 100,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "Overall Ranking",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.blue),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1.5 /
                                              100,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1.5 /
                                              100),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: Image.network(
                                                widget.finalOverAllList[index]
                                                    ["photoURL"]),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "${widget.finalOverAllList[index]["Name"].toString().trim().split(" ").join("\n   ")}" +
                                                  "\n\nScore: ${widget.finalOverAllList[index]["Score"]}" +
                                                  "\nRanking: ${index + 1}",
                                              maxLines: 7,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: widget.finalOverAllList.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                : const Center(
                    child: Text("No data available yet."),
                  );
          }
        case 3:
          return widget.finalIndividualList.isEmpty
              ? const Center(
                  child: Text("No data available yet."),
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: (MediaQuery.of(context).size.width * 4) / 100,
                      right: (MediaQuery.of(context).size.width * 4) / 100,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Individual Ranking",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                1.5 /
                                                100,
                                        top:
                                            MediaQuery.of(context).size.height *
                                                1.5 /
                                                100),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: Image.network(
                                              widget.finalIndividualList[index]
                                                  ["photoURL"]),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "${widget.finalIndividualList[index]["Name"].toString().trim().split(" ").join("\n   ")}" +
                                                "\n\nScore: ${widget.finalIndividualList[index]["Score"]}" +
                                                "\nRanking: ${index + 1}",
                                            maxLines: 7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: widget.finalIndividualList.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));

        case 4:
          return widget.finalGroupList.isEmpty
              ? const Center(
                  child: Text("No data available yet."),
                )
              : widget.finalGroupList.keys
                      .any((element) => widget.testCodeList.contains(element))
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
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: (MediaQuery.of(context).size.width * 4) / 100,
                          right: (MediaQuery.of(context).size.width * 4) / 100,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                "Group Ranking",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.blue),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: customList(),
                              ),
                            ),
                          ],
                        ),
                      ))
                  : const Center(
                      child: Text("No data available yet."),
                    );
        // ! ADDED SCORES LIST
        case 5:
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
                  top: 10,
                  bottom: 10,
                  left: (MediaQuery.of(context).size.width * 4) / 100,
                  right: (MediaQuery.of(context).size.width * 4) / 100,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "Scores",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.blue),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  scoresMode = "Individual";
                                });
                                print(scoresMode);
                              },
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: SizedBox(
                                  child: Text(
                                    "Single",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: scoresMode == "Individual"
                                            ? FontWeight.w900
                                            : FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  scoresMode = "Multiplayer";
                                });
                                print(scoresMode);
                              },
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: SizedBox(
                                  child: Text(
                                    "Multi",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: scoresMode == "Multiplayer"
                                            ? FontWeight.w900
                                            : FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (newFinalIndividualList.isNotEmpty &&
                        scoresMode ==
                            'Individual') //? Display this container if individual is selected
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('Name'),
                                ),
                                Expanded(
                                  child: Text('Score'),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            for (final indiv in newFinalIndividualList)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child:
                                            Text(indiv['Name'] ?? "Loading..."),
                                      ),
                                      Expanded(
                                        child: Text(indiv['Score'].toString() ??
                                            "Loading..."),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    widget.finalGroupList.isNotEmpty &&
                            scoresMode == "Multiplayer"
                        ? widget.finalGroupList.keys.any((element) =>
                                widget.testCodeList.contains(element))
                            ? Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child:
                                    customList2(), //copied and modified vinay's code
                              )
                            : const Center(
                                child: Text("No data available yet."),
                              )
                        : const SizedBox(),
                  ],
                ),
              ));

        default:
          return const SizedBox.shrink();
      }
    }

    return (widget.title == "My Profile" || widget.title == "Support")
        ? Scaffold(
            backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Text(widget.title),
              automaticallyImplyLeading: true,
            ),
            body: _body(widget.title),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text("Tara Quiz"),
              centerTitle: true,
              actions: [
                IconButton(
                    iconSize: 35,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TestPreparation(
                                  title: "Add Test",
                                  name: widget.name,
                                  dataExist: false,
                                  subjects: {},
                                  uid: widget.uid,
                                  subjectCode: widget.subjectCode,
                                  subTitle: widget.subTitle,
                                ),
                            maintainState: false),
                      );
                    },
                    icon: const Icon(Icons.add_box))
              ],
            ),
            body: StatefulBuilder(builder: (context, setState) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // create a navigation rail

                  NavigationRail(
                    useIndicator: true,
                    elevation: 1.5,
                    minWidth: 70,
                    minExtendedWidth: 100,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    extended: false,
                    labelType: NavigationRailLabelType.selected,
                    backgroundColor: Colors.black87,
                    destinations: <NavigationRailDestination>[
                      // navigation destinations
                      NavigationRailDestination(
                        icon: Icon(Icons.quiz, color: Colors.lightBlue),
                        selectedIcon: Icon(
                          Icons.quiz,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'Quiz',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.orange),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.class_, color: Colors.lightBlue),
                        selectedIcon: Icon(
                          Icons.class_,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'Students',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.orange),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.assessment, color: Colors.lightBlue),
                        selectedIcon: Icon(
                          Icons.assessment,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'OverAll',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.orange),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.emoji_people, color: Colors.lightBlue),
                        selectedIcon: Icon(
                          Icons.emoji_people,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'Individual',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.orange),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.group, color: Colors.lightBlue),
                        selectedIcon: Icon(
                          Icons.group,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'Multiplayer',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.orange),
                        ),
                      ),
                      // ! ADD AN ICON HERE FOR SCORES LIST
                      if (widget.studentORProf == "Professor")
                        NavigationRailDestination(
                          icon: Icon(
                            Icons.list_alt_rounded,
                            color: Colors.lightBlue,
                          ),
                          selectedIcon: const Icon(
                            Icons.list_alt_rounded,
                            color: Colors.blue,
                          ),
                          label: Text(
                            "Scores",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.orange),
                          ),
                        ),
                    ],
                    selectedIconTheme: IconThemeData(color: Colors.white),
                    unselectedIconTheme: IconThemeData(color: Colors.black),
                    selectedLabelTextStyle: TextStyle(color: Colors.white),
                  ),

                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: widgetSelect(_selectedIndex),
                  )
                ],
              );
            }),
          );
  }

  customList() {
    List expectedList = widget.finalGroupList.keys
        .toSet()
        .intersection(widget.testCodeList.toSet())
        .toList();
    List expectedListIndex = List.empty(growable: true);
    for (int i = 0; i < widget.testCodeList.length; i++) {
      for (int j = 0; j < widget.finalGroupList.keys.length; j++) {
        if (widget.testCodeList.elementAt(i) ==
            widget.finalGroupList.keys.elementAt(j)) {
          expectedListIndex.add(i);
        }
      }
    }

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 1.5 / 100,
                top: MediaQuery.of(context).size.height * 1.5 / 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: _secondList(index, expectedListIndex),
            ),
          ),
        );
      },
      itemCount: expectedList.length,
    );
  }

  _secondList(int index, List listTemp) {
    Map tempMap004 = {};
    List tempMap005 = [];
    Map tempMap006 = {};
    List tempMap007 = [];
    int count = 0;

    List<Widget> widgeList = List.empty(growable: true);
    tempMap004.addAll(widget.finalGroupList.values.elementAt(index));
    tempMap004.forEach((key, value) {
      tempMap005.add(value);
    });
    tempMap006.addAll(tempMap005.elementAt(0)["groupMembers"]);
    tempMap006.forEach((key, value) {
      tempMap007.add(value);
    });
    if (count == 0) {
      widgeList.add(
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            widget.testDetailsList[listTemp.elementAt(index)]["Title"],
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
          ),
        ),
      );
    }
    for (int i = 0; i < tempMap007.length; i++) {
      widgeList.add(Row(children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Image.network(tempMap007.elementAt(i)["photoUrl"]),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tempMap007.elementAt(i)["name"],
            maxLines: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 2.0,
            right: 2.0,
            top: 8.0,
            bottom: 8.0,
          ),
          child: Text(
            tempMap007.elementAt(i)["score"].toString(),
            maxLines: 1,
          ),
        ),
      ]));
    }
    return widgeList;
  }

  Future<void> handleDelete(int index) async {
    try {
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('StudentsDetails')
          .where('name',
              isEqualTo: widget.finalStudentListForProfs.values
                  .elementAt(index)
                  .toString())
          .get();

      if (studentQuery.docs.isNotEmpty) {
        // ! ================UPDATE STUDENT DETAIL=================
        String studentDocId = studentQuery.docs.first.id;
        var studentData =
            studentQuery.docs.first.data() as Map<String, dynamic>;

        Map<String, dynamic> studentSubject = studentData['Subject'];
        Map<String, dynamic> studentCompletedQuiz =
            studentData['CompletedQuiz'];

        studentSubject.remove(widget.subjectCode);

        if (studentCompletedQuiz[widget.subjectCode] != null) {
          studentCompletedQuiz.remove(widget.subjectCode);
        }

        var studentRef = FirebaseFirestore.instance
            .collection('StudentsDetails')
            .doc(studentDocId);
        await studentRef.update({
          'CompletedQuiz': studentCompletedQuiz,
          'Subject': studentSubject,
        }).whenComplete(() => print('removed subject in student details'));

        // !======================================================

        // ! =============UPDATE PROF DATA=================
        DocumentSnapshot profQuery = await FirebaseFirestore.instance
            .collection('ProfessorsDetails')
            .doc(widget.uid)
            .get();

        if (profQuery.exists) {
          var profData = profQuery.data() as Map<String, dynamic>;

          Map<String, dynamic> profSubject =
              profData['Subject'][widget.subjectCode]['StudentList'];

          profSubject.remove(studentDocId);

          var profRef = FirebaseFirestore.instance
              .collection('ProfessorsDetails')
              .doc(widget.uid);

          profRef.update({
            'Subject.${widget.subjectCode}.StudentList': profSubject,
          }).whenComplete(() => print("removed student in subject"));
        }

        // !==========================================
      } else {
        print("Student not found");
      }
    } catch (e) {
      print('error deleting/unenrolling student: $e');
    }
  }

  // TODO MODIFY SECOND LIST TO PRODUCE A LIST INSTEAD
  customList2() {
    List expectedList = widget.finalGroupList.keys
        .toSet()
        .intersection(widget.testCodeList.toSet())
        .toList();
    List expectedListIndex = List.empty(growable: true);
    for (int i = 0; i < widget.testCodeList.length; i++) {
      for (int j = 0; j < widget.finalGroupList.keys.length; j++) {
        if (widget.testCodeList.elementAt(i) ==
            widget.finalGroupList.keys.elementAt(j)) {
          expectedListIndex.add(i);
        }
      }
    }

    return Column(
      children: expectedList.asMap().entries.map((entry) {
        int index = entry.key;
        return Column(
          children: _thirdList(index, expectedListIndex),
        );
      }).toList(),
    );
  }

  _thirdList(int index, List listTemp) {
    Map tempMap004 = {};
    List tempMap005 = [];
    Map tempMap006 = {};
    List tempMap007 = [];
    int count = 0;

    List<Widget> widgeList = List.empty(growable: true);
    tempMap004.addAll(widget.finalGroupList.values.elementAt(index));
    tempMap004.forEach((key, value) {
      tempMap005.add(value);
    });
    tempMap006.addAll(tempMap005.elementAt(0)["groupMembers"]);
    tempMap006.forEach((key, value) {
      tempMap007.add(value);
    });

    // Split the names, rearrange, and sort alphabetically
    tempMap007.sort((a, b) {
      var nameA = a['name'].split(' ');
      var nameB = b['name'].split(' ');

      var rearrangedA = rearrangeName(nameA);
      var rearrangedB = rearrangeName(nameB);

      print(rearrangedA);
      print(rearrangedB);

      return rearrangedA.compareTo(rearrangedB);
    });

    if (count == 0) {
      widgeList.add(
        // Padding(
        //   padding: const EdgeInsets.only(top: 10),
        // child:
        Text(
          'Quiz: ${widget.testDetailsList[listTemp.elementAt(index)]["Title"]}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
        ),
        // ),
      );
    }
    for (int i = 0; i < tempMap007.length; i++) {
      var nameParts = tempMap007.elementAt(i)["name"].split(' ');
      var formattedName = rearrangeName(nameParts);

      widgeList.add(
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(
            formattedName,
            maxLines: 1,
          ),
        ),
        Expanded(
          child: Text(
            tempMap007.elementAt(i)["score"].toString(),
            maxLines: 1,
          ),
        ),
      ]));
    }
    return widgeList;
  }

  // Function to rearrange the names
  String rearrangeName(List<String> nameParts) {
    // Default rearranged name will be the last element (Last Name)
    var rearrangedName = nameParts.last;

    // If there are more than one name parts, rearrange accordingly
    if (nameParts.length > 1) {
      rearrangedName = '${nameParts.last},';
      for (var i = 0; i < nameParts.length - 1; i++) {
        rearrangedName += ' ${nameParts[i]}';
      }
    }
    return rearrangedName.trim();
  }
}
