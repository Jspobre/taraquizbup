import 'package:hive/hive.dart';

import '../../configs/constants/constants.dart';

part 'dashboard_model.g.dart';

@HiveType(typeId: 1)
class DashboardModel extends HiveObject {
  String fName;
  String lName;

  String dName;
  String uid;
  String eMailId;
  String mobileNumber;
  String profilePhotoURL;
  String rToken;
  String signInMethod;

  String studentOrProfessor;

  bool isDash;
  @HiveField(12)
  Map<String, dynamic> subjectDetails;
  @HiveField(13)
  Map<String, dynamic> studentDetails;
  @HiveField(14)
  Map<String, dynamic> proDetails;


  DashboardModel(
      {this.rToken = AppConstants.defaultStringConstant,
      this.fName = AppConstants.defaultStringConstant,

      this.lName = AppConstants.defaultStringConstant,
      this.dName = AppConstants.defaultStringConstant,
      this.eMailId = AppConstants.defaultStringConstant,
      this.mobileNumber = AppConstants.defaultStringConstant,
      this.profilePhotoURL = AppConstants.defaultStringConstant,
      this.signInMethod = AppConstants.defaultStringConstant,
      this.studentDetails = AppConstants.defaultMapConstant,
      this.subjectDetails = AppConstants.defaultMapConstant,
      this.proDetails = AppConstants.defaultMapConstant,

      this.isDash = AppConstants.defaultBoolConstant,

      this.studentOrProfessor = AppConstants.defaultStringConstant,
      this.uid = AppConstants.defaultStringConstant});
}
