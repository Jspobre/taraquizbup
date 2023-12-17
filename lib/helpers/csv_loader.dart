import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mailjet/mailjet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taraquizbup/configs/constants/constants.dart';
import 'package:taraquizbup/main.dart';

class ExcelLoader {
  String apiKey = "a54e3b17cdbc69a7f5c716f1b8f9b7dc";
  String secretKey = "91323d677798204bd82336d28777c7d2";

//An email registered to your mailjet account
  String myContactEmail = "taraapp446@gmail.com";
  String mySupportReceiverEmail = "taraapp446@gmail.com";
  String timeStr = DateTime.now().millisecondsSinceEpoch.toString();

  readExcelFile() async {}
  writeExcelFile( code,type,title, fill, tf,
      mcqs, uid, context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    int rowCount = 1;
    List<String> row = ["Note:", "Please check the questions before uploading.\nOnly one image can be uploaded per question, answer and/or option.\nOnly make changes on the cells provided.\nDon't change file name or format.\n\nNote:\n\nMCQ answers should be 1 to mark option a:, 2 to mark option b, 3 to mark option c: and 4 to mark option d:\n\nTrue/False, Mark 1 for True as answer and 2 for False\n\nFill in the blanks - just answers, if these is more than one blank in question, separate them by comma (,)."];
    sheetObject.appendRow(row);
    List<String> firstRow = [ "Title:", title ];
    sheetObject.appendRow(firstRow);
    List<String> secondRow = [ "Exam Type:", type ];
    sheetObject.appendRow(secondRow);
if(type == "20_min_multi"){
  List<String> thirdRow = [ "Enter Password:", "Here." ];
  sheetObject.appendRow(thirdRow);
}

    List<String> firstRowQuestionMCQ = [
      "Question:", "Insert your question here.", "Insert your question Image link here. (If any)"
         ];
    List<String> secondRowQuestionMCQ = [
      "Option a:" , "Insert your Option a: here.", "Insert your Option a: Image link here. (If any)"
      ];
    List<String> thirdRowQuestionMCQ = [
      "Option b:", "Insert your Option b: here.", "Insert your Option b: Image link here. (If any)"
,
    ];
    List<String> fourthRowQuestionMCQ = [
    "Option c:", "Insert your Option c: here.", "Insert your Option c: Image link here. (If any)"

    ];
    List<String> fifthRowQuestionMCQ = [
      "Option d:", "Insert your Option d: here.", "Insert your Option d: Image link here. (If any)"
    ];
    List<String> sixthRowQuestionMCQ = [
      "Answer:", "Insert your answer here.","Insert your answer Image link link here. (If any)"
    ];
    List<String> firstRowQuestionOthers = ["Question:", "Insert your question here.", "Insert your question Image link here. (If any)"];
    List<String> secondRowQuestionOthers = ["Answer:", "Insert your answer here." ,  "Insert your answer Images link here. (If any)"];

    rowCount = (type == "20_min_multi") ? 5: 4;
    int mcqNo =  (mcqs!="")? int.parse(mcqs) : 0;
    int tfNo = (tf!="")?int.parse(tf): 0;
    int fillNo = (fill!="")?int.parse(fill): 0;

      rowCount = rowCount + 1;
      if (mcqNo != 0) {
        List<String> typeRow = ["Type:","MCQs" ];
        sheetObject.appendRow(typeRow);
        for (int i = 0; i < mcqNo; i++) {

            sheetObject.appendRow(firstRowQuestionMCQ);
            rowCount++;
            sheetObject.appendRow(secondRowQuestionMCQ);
            rowCount++;
            sheetObject.appendRow(thirdRowQuestionMCQ);
            rowCount++;
            sheetObject.appendRow(fourthRowQuestionMCQ);
            rowCount++;
            sheetObject.appendRow(fifthRowQuestionMCQ);
            rowCount++;
            sheetObject.appendRow(sixthRowQuestionMCQ);
            rowCount++;


        }
      }
      if (tfNo != 0) {
        List<String> typeRow = ["Type:","True/False" ];
        sheetObject.appendRow(typeRow);
        rowCount++;
        for (int i = 0; i < tfNo; i++) {

            sheetObject.appendRow(firstRowQuestionOthers);
            rowCount++;
            sheetObject.appendRow(secondRowQuestionOthers);
            rowCount++;

        }

      }
      if (fillNo != 0 && type != "20_min_multi") {
        List<String> typeRow = ["Type:","Fill up the Blanks" ];
        sheetObject.appendRow(typeRow);
        rowCount++;
        for (int i = 0; i < fillNo; i++) {

            sheetObject.appendRow(firstRowQuestionOthers);
            rowCount++;
            sheetObject.appendRow(secondRowQuestionOthers);
            rowCount++;

        }
      }

    var fileBytes = excel.save();
    var directory = await getApplicationDocumentsDirectory();
    String temp3  = type.split(" ").join("").toLowerCase();
    String temp5  = title.split(" ").join("").toLowerCase();
    MailJet mailJet = MailJet(
      apiKey: apiKey,
      secretKey: secretKey,
    );
    await mailJet.sendEmail(
      subject: title,
      sender: Sender(
        email: myContactEmail,
        name: "Tara Quiz",
      ),
      reciepients: [
        Recipient(
          email:  mySupportReceiverEmail,

          name: "Tara Quiz",
        ),
      ],
      htmlEmail: title,
      Attachments: [
        File(directory.path + '/'+timeStr+'_'+uid+'_'+temp3+'_'+temp5+'.xls')
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes!)
      ],
    ).whenComplete(() async {
      final storageRef = FirebaseStorage.instance.ref();
      final mountainsRef = storageRef.child( timeStr+'_'+uid+'_'+temp3+'_'+temp5+'.xls');
      await mountainsRef.putFile(File(directory.path + '/'+timeStr+'_'+uid+'_'+temp3+'_'+temp5+'.xls')).whenComplete(() async {
        await mountainsRef.getDownloadURL().then((value) {
          FirebaseFirestore.instance
              .collection('ProfessorsDetails')
              .doc(uid)
              .get().then((value1) {
                Map? tempMap1 = Map();
                Map? tempMap2 = Map();
                Map? tempMap3 = Map();
                tempMap1 = value1.data()?["Quiz"];

            Map<String, String> tempMap = {"code": code,"uid" : uid,  "Type" : type,  "Title": title, "excelURL":value, "status":"Not Uploaded" };
                if(tempMap1 != null){

                  tempMap3 = tempMap1[code];
                  if(tempMap3 != null){
                    tempMap3.addEntries({timeStr: tempMap}.entries);
                    Map<String, dynamic> temp = Map();
                    temp = {code: tempMap3};
                    tempMap1.addAll(temp) ;
                  }  else {
                    tempMap2 =  {timeStr: tempMap};
                    Map<String, dynamic> temp = Map();
                    temp = {code: tempMap2};
                    tempMap1.addAll(temp);
                  }

                } else {
                  tempMap2 =  {timeStr: tempMap};
                  tempMap1 = {code: tempMap2} ;
                }
            FirebaseFirestore.instance
                .collection('ProfessorsDetails')
                .doc(uid)
                .update({            "Quiz": tempMap1
            }).then((_) {
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
                          "File format successfully mailed.\n Please fill the details and upload.",
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
                                    ?.copyWith(color: Colors.blue),
                              ),
                              onPressed: () {
                                navigatorKey.currentState?.pushNamed(RoutesConstants.proLaunchPadScreenRoute);


                              }),
                        ]);
                  });
            } ).onError((error, stackTrace) => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      title: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 60,
                      ),
                      content: Text(
                        "File formating ussuccessful.\n Please Try Again.",
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
                                  ?.copyWith(color: Colors.blue),
                            ),
                            onPressed: () {
                              navigatorKey.currentState?.pushNamed(RoutesConstants.proLaunchPadScreenRoute);


                            }),
                      ]);
                }));
          });


        });
      });
    });
  }
}
