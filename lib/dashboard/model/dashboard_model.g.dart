// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardModelAdapter extends TypeAdapter<DashboardModel> {
  @override
  final int typeId = 1;

  @override
  DashboardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardModel(
      studentDetails: (fields[13] as Map).cast<String, dynamic>(),
      subjectDetails: (fields[12] as Map).cast<String, dynamic>(),
      proDetails: (fields[14] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DashboardModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(12)
      ..write(obj.subjectDetails)
      ..writeByte(13)
      ..write(obj.studentDetails)
      ..writeByte(14)
      ..write(obj.proDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
