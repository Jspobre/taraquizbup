// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SignInModelAdapter extends TypeAdapter<SignInModel> {
  @override
  final int typeId = 1;

  @override
  SignInModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SignInModel(
      rToken: fields[6] as String,
      dName: fields[0] as String,
      mobileNumber: fields[3] as String,
      eMailId: fields[4] as String,
      profilePhotoURL: fields[7] as String,
      signInMethod: fields[9] as String,
      studentOrProfessor: fields[8] as String,
      isDash: fields[10] as bool,
      isSignedIn: fields[2] as bool,
      eMailIdVerified: fields[5] as bool,
      uid: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SignInModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.dName)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.isSignedIn)
      ..writeByte(3)
      ..write(obj.mobileNumber)
      ..writeByte(4)
      ..write(obj.eMailId)
      ..writeByte(5)
      ..write(obj.eMailIdVerified)
      ..writeByte(6)
      ..write(obj.rToken)
      ..writeByte(7)
      ..write(obj.profilePhotoURL)
      ..writeByte(8)
      ..write(obj.studentOrProfessor)
      ..writeByte(9)
      ..write(obj.signInMethod)
      ..writeByte(10)
      ..write(obj.isDash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignInModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
