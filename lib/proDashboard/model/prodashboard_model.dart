import 'package:hive/hive.dart';

import '../../configs/constants/constants.dart';

part 'prodashboard_model.g.dart';

@HiveType(typeId: 1)
class ProDashboardModel extends HiveObject {
  String fName;
  String lName;
  String dName;
  String uid;
  String eMailId;
  bool isDash;
  String mobileNumber;
  String profilePhotoURL;
  String rToken;
  String signInMethod;


  @HiveField(11)
  Map proSubjectDetails;
  Map proStudentDetails;


  ProDashboardModel(
      {this.rToken = AppConstants.defaultStringConstant,
      this.fName = AppConstants.defaultStringConstant,
      this.lName = AppConstants.defaultStringConstant,
      this.dName = AppConstants.defaultStringConstant,

      this.eMailId = AppConstants.defaultStringConstant,
      this.mobileNumber = AppConstants.defaultStringConstant,
      this.profilePhotoURL = AppConstants.defaultStringConstant,
      this.signInMethod = AppConstants.defaultStringConstant,
      this.isDash = AppConstants.defaultBoolConstant,
      this.proSubjectDetails = AppConstants.defaultMapConstant,
      this.proStudentDetails = AppConstants.defaultMapConstant,

      this.uid = AppConstants.defaultStringConstant});
}
