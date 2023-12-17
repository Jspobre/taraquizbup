import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:taraquizbup/widgets/custom_dialog.dart';

import '../configs/constants/constants.dart';
import '../helpers/csv_loader.dart';
import '../mixins/mixins.dart';

class TestPreparation extends StatefulWidget {
  final String title;
  final String name;
  final bool dataExist;
  final Map subjects;
  final String uid;
  final String subjectCode;
  final String subTitle;


  const TestPreparation({
    Key? key,
    required this.title,
    required this.name,
    required this.dataExist,
    required this.uid,
    required this.subjects,
    required this.subjectCode,
    required this.subTitle,


  }) : super(key: key);

  _TestPreparationState createState() => _TestPreparationState();
}



class _TestPreparationState extends State<TestPreparation> {
  bool isActivity = false;
  bool isMultiQuiz = false;
  bool isExam = false;
  bool isQuiz = false;
  bool isOthers = false;
  List<Widget> listWidget11 = List.empty(growable: true);
  List<Widget> listWidget12 = List.empty(growable: true);
  final TextEditingController controllerSubjectCode = TextEditingController();
  final TextEditingController controllerSubjectName = TextEditingController();
  final TextEditingController controllerSubjectPassword =
      TextEditingController();
  final formKey1 = GlobalKey<FormState>();
  final TextEditingController controllerMCQ = TextEditingController();
  final TextEditingController controllerTF = TextEditingController();
  final TextEditingController controllerFill = TextEditingController();
  final TextEditingController controllerTitle = TextEditingController();
  final FocusNode focusNodeTitle = FocusNode();

  final FocusNode focusNodeMCQ = FocusNode();
  final FocusNode focusNodeTF = FocusNode();
  final FocusNode focusNodeFill = FocusNode();
  final FocusNode focusNodeSubjectCode = FocusNode();
  final FocusNode focusNodeSubjectName = FocusNode();
  final FocusNode focusNodeSubjectPassword = FocusNode();
  List<DropdownMenuItem<String>> menuItems12 = List.empty(growable: true);
  List<DropdownMenuItem<String>> menuItems11 = List.empty(growable: true);

  final Snippet snippet = Snippet();
  final CustomDialog customDialog = CustomDialog();

  @override
  initState() {
    super.initState();
  }
  String selectedQuizValue = 'Please select quiz type';

  List<DropdownMenuItem<String>> get dropdownQuizItems{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Please select quiz type"),value: "Please select quiz type"),
      DropdownMenuItem(child: Text("20 Minutes, Single Player"),value: "20_min_single"),
   //   DropdownMenuItem(child: Text("60 Minutes, Single Player"),value: "60_min_single"),
      DropdownMenuItem(child: Text("20 Minutes, Multi-Player"),value: "20_min_multi"),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      body: widget.title == "Add Subject" ? _body1() : _body2(),
    );
  }

  _body1() {
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
      child: Form(
        key: formKey1,
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height * 2) / 100),
                      bottom: ((MediaQuery.of(context).size.height * 2) / 100),
                    ),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        maxLength: 15,
                        validator: (value) {
                          if (RegExp(r"^[a-zA-Z0-9]{5,}$").hasMatch(value!)) {
                            return null;
                          } else {
                            return "Enter Subject Code with atleast 5 characters.";
                          }
                        },
                        keyboardType: TextInputType.text,
                        controller: controllerSubjectCode,
                        focusNode: focusNodeSubjectCode,
                        onChanged: (e) {
                          controllerSubjectCode.text = e;
                        },
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodeSubjectCode);
                          controllerSubjectCode.text = '';
                        },
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          helperText: "Greater than 5 AlphaNumeric characters",
                          labelText: "Subject Code:\*",
                        ),
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodeSubjectName);
                        },
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height * 2) / 100),
                      bottom: ((MediaQuery.of(context).size.height * 2) / 100),
                    ),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: controllerSubjectName,
                        focusNode: focusNodeSubjectName,
                        onChanged: (e) {
                          controllerSubjectName.text = e;
                        },
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodeSubjectName);
                          controllerSubjectName.text = '';
                        },
                        validator: (value) {
                          if (value!.length >= 5) {
                            return null;
                          } else {
                            return "Enter valid Subject Name.";
                          }
                        },
                        decoration: const InputDecoration(
                          helperText: "Minimum 5 characters",
                          border: UnderlineInputBorder(),
                          labelText: "Subject Name:\*",
                        ),
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodeSubjectPassword);
                        },
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height * 2) / 100),
                      bottom: ((MediaQuery.of(context).size.height * 2) / 100),
                    ),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: controllerSubjectPassword,
                        focusNode: focusNodeSubjectPassword,
                        onChanged: (e) {
                          controllerSubjectPassword.text = e;
                        },
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodeSubjectPassword);
                          controllerSubjectPassword.text = '';
                        },
                        maxLength: 15,
                        validator: (value) {
                          if (RegExp(r"^[a-zA-Z0-9]{8,}$").hasMatch(value!)) {
                            return null;
                          } else {
                            return "Enter Subject Code with atleast 8 characters.";
                          }
                        },
                        decoration: const InputDecoration(
                          helperText: "Greater than 8 AlphaNumeric characters",
                          border: UnderlineInputBorder(),
                          labelText: "Subject Password:\*",
                        ),
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 24.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Map tempMap = Map();

                       if(widget.subjects != {"default":"default"}) tempMap.addAll(widget.subjects);

                        tempMap.addEntries({
                          controllerSubjectCode.text: {
                            "Name": controllerSubjectName.text,
                            "Password": controllerSubjectPassword.text
                          }
                        }.entries)  ;

                        if (formKey1.currentState!.validate()) {
                          FirebaseFirestore.instance
                              .collection('ProfessorsDetails')
                              .doc(widget.uid)
                              .update({
                           "Subject": tempMap
                          }).onError((error, stackTrace) {
                            customDialog.customErrorDialog(
                              "error uploading details",
                              context,
                            );}).then((value) => customDialog.customSuccessDialog("Success", context, false, true));
                        }
                      },
                      child: const Text("Create Subject")),
                ),
              ]),
        ),
      ),
    );
  }

  _body2() {
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
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0, bottom: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller:controllerTitle,
                  focusNode: focusNodeTitle,
                  onChanged: (e) {


                    controllerTitle.text = e;


                  },
                  onTapOutside: (event) =>
                      FocusScope.of(context).unfocus(),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeTitle);

                    controllerTitle.text = '';
                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Title:\*",

                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeMCQ);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: ((MediaQuery.of(context).size.height * 2) / 100),
                  left: ((MediaQuery.of(context).size.width * 8) / 100),
                  right: ((MediaQuery.of(context).size.width * 8) / 100),
                  bottom:
                  ((MediaQuery.of(context).size.height * 2) / 100),
                ),
                child: DropdownButton<String>(
                  value: selectedQuizValue,
                  items: dropdownQuizItems,

                  onChanged: (value) {
                    setState(() {
                      selectedQuizValue = value!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0, bottom: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  controller:controllerMCQ,
                  focusNode: focusNodeMCQ,
                  onChanged: (e) {


                    controllerMCQ.text = e;


                  },
                  onTapOutside: (event) =>
                      FocusScope.of(context).unfocus(),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeMCQ);

                    controllerMCQ.text = '';
                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Number of Multiple choice:\*",
                      helperText: "Type 0 (Zero) if no Multiple choice Question."

                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeTF);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0, bottom: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller:controllerTF,
                  maxLength: 3,
                  focusNode: focusNodeTF,
                  onChanged: (e) {


                    controllerTF.text = e;


                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Number of True/False:\*",
                      helperText: "Type 0 (Zero) if no True/False Question."

                  ),
                  onTapOutside: (event) =>
                      FocusScope.of(context).unfocus(),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeTF);

                    controllerTF.text = '';

                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeFill);
                  },

                ),
              ),

              selectedQuizValue !="20_min_multi" ? Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0, bottom: 18.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller:controllerFill,
                  focusNode: focusNodeFill,
                  maxLength: 3,
                  onChanged: (e) {

                    controllerFill.text = e;



                  },
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Number of Fill in the blanks:\*",
                      helperText: "Type 0 (Zero) if no Fill in the blanks Question."
                  ),
                  onTapOutside: (event) =>
                      FocusScope.of(context).unfocus(),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(focusNodeFill);
                    controllerFill.text = '';
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ) : SizedBox.shrink(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ElevatedButton(
                      onPressed: () {
                          ExcelLoader excelLoader = ExcelLoader();

                          excelLoader.writeExcelFile( widget.subjectCode,selectedQuizValue,controllerTitle.text,controllerFill.text,controllerTF.text,controllerMCQ.text, widget.uid, context);


                      }, child: const Text("Prepare Format")),
                ),
              ),
            ]),
      ),
    );
  }
}
