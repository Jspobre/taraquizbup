import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taraquizbup/configs/constants/constants.dart';
import 'package:taraquizbup/dashboard/gameRoom.dart';
import 'package:taraquizbup/helpers/email.dart';
import 'package:taraquizbup/test/test.dart';

import '../test/fullTest.dart';
import '../widgets/custom_dialog.dart';

class CommonPage extends StatelessWidget {
  final String title;
  final String subTitle;
  final String name;
  final String emailId;
  late String url;
  final String uid;
  final String subjectCode;
  final String subjectName;
  final String stdName;
  final String stdPhoto;

  final String studentORProf;

  final List<String> testCodeList;
  final List finalOverAllList;
  final List finalIndividualList;
  final Map finalGroupList;

  final List<Map> testDetailsList;
  final List<String> studentCodeList;
  final List completedQuiz;

  final Map studentDetailsList;
  CommonPage(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.name,
      required this.stdName,      required this.completedQuiz,


        required this.stdPhoto,
      required this.emailId,
      required this.url,
      required this.uid,
      required this.subjectCode,
      required this.subjectName,
      required this.testCodeList,
      required this.studentORProf,
      required this.testDetailsList,
      required this.studentCodeList,
      required this.studentDetailsList,
      required this.finalOverAllList,
      required this.finalIndividualList,
      required this.finalGroupList})
      : super(key: key);
  bool ready = true;

  final TextEditingController controllerSubject = TextEditingController();
  final TextEditingController controllerQuery = TextEditingController();

  final FocusNode focusNodeSubject = FocusNode();
  final FocusNode focusNodeQuery = FocusNode();

  bool isImageSelected = false;
  late File file;

  CustomDialog customDialog = CustomDialog();

  @override
  Widget build(BuildContext context) {

   print(finalGroupList.values);

    _body() {
      return (title == "Support" || title == "Contact us")
          ?
          //Contact and Support
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
                            mail.sendEmail(context, title, name, emailId,
                                controllerSubject.text, controllerQuery.text);
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
                              ? NetworkImage((url == "default_str")
                                  ? url = AppConstants.defaultURLConstant
                                  : url)
                              : NetworkImage(
                                  "https://source.unsplash.com/dLij9K4ObYY",
                                  scale: 1),
                        ),
                      ),
                      Text(
                        "Name: $name",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        "email id: $emailId",
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

    return (title == "Subject Tests")
        ? DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(title),
                automaticallyImplyLeading: true,
                bottom: const TabBar(
                  tabAlignment: TabAlignment.fill,
                  unselectedLabelColor: Colors.white60,
                  dividerColor: Colors.white70,
                  isScrollable: false,
                  labelColor: Colors.white,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.quiz),
                      text: "Quiz",
                    ),
                    Tab(icon: Icon(Icons.assessment), text: "Overall"),
                    Tab(
                      icon: Icon(Icons.person),
                      text: "Individual",
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
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
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom:20,
                            left: (MediaQuery.of(context).size.width * 4) / 100,
                            right:
                                (MediaQuery.of(context).size.width * 4) / 100,
                          ),
                          child: SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 90 / 100,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  subTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.blue),
                                  maxLines: 4,
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      73 /
                                      100,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    child: ListView.builder(
                                        itemBuilder: (context, index) =>
                                            ("${testDetailsList[index]["status"]}" ==
                                                    "Uploaded")
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 5,
                                                      bottom: 5,
                                                    ),
                                                    child: Card(
                                                      child: ListTile(
                                                        onTap: completedQuiz[index] == "Completed" ? null:() {
                                                          if (testDetailsList[
                                                                      index]
                                                                  ["Type"] ==
                                                              "20_min_multi") {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                       (context) =>
                                                                          GameRoom(
                                                                            uid:
                                                                                uid,
                                                                            testCode:
                                                                                testCodeList[index]
                                                                                ,
                                                                            subCode:
                                                                                testDetailsList[index]["Type"],
                                                                            proUid:
                                                                                testDetailsList[index]["uid"],
                                                                            url:
                                                                                testDetailsList[index]["excelURL"],
                                                                            subjectCode:
                                                                                subjectCode,
                                                                            name:
                                                                                stdName,
                                                                            photoUrl:
                                                                                stdPhoto,
                                                                          ),
                                                                  maintainState:
                                                                      true,
                                                                  fullscreenDialog:
                                                                      false),
                                                            );
                                                          } else if(testDetailsList[
                                                          index]
                                                          ["Type"] ==
                                                              "20_min_single"){
                                                            Navigator.of(
                                                                context)
                                                                .push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                        Test(
                                                                          uid:
                                                                          uid,
                                                                          testCode:
                                                                          testCodeList[index]
                                                                          ,
                                                                          subCode:
                                                                          testDetailsList[index]["Type"],
                                                                          proUid:
                                                                          testDetailsList[index]["uid"],
                                                                          url:
                                                                          testDetailsList[index]["excelURL"],
                                                                          subjectCode:
                                                                          subjectCode,
                                                                          name:
                                                                          stdName,
                                                                          photoUrl:
                                                                          stdPhoto,
                                                                        ),
                                                                    maintainState:
                                                                    true,
                                                                    fullscreenDialog:
                                                                    false),);}else {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          FullTest(
                                                                            uid:
                                                                                uid, url: '',
                                                                          ),
                                                                  maintainState:
                                                                      true,
                                                                  fullscreenDialog:
                                                                      false),
                                                            );
                                                          }
                                                        },
                                                        trailing: completedQuiz[index] == "Completed" ? Icon(Icons.check_circle,color: Colors.green,):Icon(Icons.cancel, color: Colors.red,),
                                                        title: Text(
                                                          "${testDetailsList[index]["Title"]}",
                                                          maxLines: 3,
                                                        ),
                                                        subtitle: testDetailsList[
                                                                        index]
                                                                    ["Type"] ==
                                                                "20_min_multi"
                                                            ? const Text(
                                                                "Type: Multiplayer Quiz\nDuration: 20 min")
                                                            : testDetailsList[
                                                                            index]
                                                                        [
                                                                        "Type"] ==
                                                                    "20_min_single"
                                                                ? const Text(
                                                                    "Type: Single Player Quiz\nDuration: 20 min")
                                                                : const Text(
                                                                    "Type: Single Player Quiz\nDuration: 60 min"),
                                                      ),
                                                    ))
                                                : const SizedBox.shrink(),
                                        itemCount: testDetailsList.length),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                  finalOverAllList.isNotEmpty
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
                              left:
                                  (MediaQuery.of(context).size.width * 4) / 100,
                              right:
                                  (MediaQuery.of(context).size.width * 4) / 100,
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
                                      itemBuilder:
                                          (BuildContext context, int index) {
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
                                                      finalOverAllList[index]
                                                          ["photoURL"]),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "${finalOverAllList[index]["Name"].toString().trim().split(" ").join(" ")}" +
                                                        "\n\nScore: ${finalOverAllList[index]["Score"]}" +
                                                        "\nRanking: ${index + 1}",
                                                    maxLines: 7,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: finalOverAllList.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      : const Center(
                          child: Text("No data available yet."),
                        ),
                  finalIndividualList.isEmpty
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
                              left:
                                  (MediaQuery.of(context).size.width * 4) / 100,
                              right:
                                  (MediaQuery.of(context).size.width * 4) / 100,
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
                                      itemBuilder:
                                          (BuildContext context, int index) {
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
                                                      finalIndividualList[index]
                                                          ["photoURL"]),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "${finalIndividualList[index]["Name"].toString().trim().split(" ").join(" ")}" +
                                                        "\n\nScore: ${finalIndividualList[index]["Score"]}" +
                                                        "\nRanking: ${index + 1}",
                                                    maxLines: 7,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: finalIndividualList.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Text(((title == "My Profile") ||
                      (title == "Contact us") ||
                      (title == "Support"))
                  ? title
                  : title),
              automaticallyImplyLeading: true,
            ),
            body: _body(),
          );
  }
}
