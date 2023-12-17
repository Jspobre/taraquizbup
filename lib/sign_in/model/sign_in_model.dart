import 'package:hive/hive.dart';

import '../../configs/constants/constants.dart';

part 'sign_in_model.g.dart';

@HiveType(typeId: 1)
class SignInModel extends HiveObject {
  String fName;
  String lName;
  String password;
  String otp;
  String cPassword;
  String nPassword;

  @HiveField(0)
  String dName;
  @HiveField(1)
  String uid;
  @HiveField(2)
  bool isSignedIn;
  @HiveField(3)
  String mobileNumber;
  @HiveField(4)
  String eMailId;
  @HiveField(5)
  bool eMailIdVerified;
  @HiveField(6)
  String rToken;

  @HiveField(7)
  String profilePhotoURL;
  @HiveField(8)
  String studentOrProfessor;
  @HiveField(9)
  String signInMethod;

  @HiveField(10)
  bool isDash;

  SignInModel(
      {this.rToken = AppConstants.defaultStringConstant,
      this.fName = AppConstants.defaultStringConstant,
      this.lName = AppConstants.defaultStringConstant,
      this.dName = AppConstants.defaultStringConstant,
      this.mobileNumber = AppConstants.defaultStringConstant,
      this.eMailId = AppConstants.defaultStringConstant,

      this.profilePhotoURL = AppConstants.defaultStringConstant,
      this.password = AppConstants.defaultStringConstant,

      this.signInMethod = AppConstants.defaultStringConstant,
      this.studentOrProfessor = AppConstants.defaultStringConstant,

      this.cPassword = AppConstants.defaultStringConstant,
      this.nPassword = AppConstants.defaultStringConstant,
      this.otp = AppConstants.defaultStringConstant,


        this.isDash = AppConstants.defaultBoolConstant,

        this.isSignedIn = AppConstants.defaultBoolConstant,
      this.eMailIdVerified = AppConstants.defaultBoolConstant,
      this.uid = AppConstants.defaultStringConstant});
}
