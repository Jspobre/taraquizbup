// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prodashboard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProDashboardModelAdapter extends TypeAdapter<ProDashboardModel> {
  @override
  final int typeId = 1;

  @override
  ProDashboardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProDashboardModel(
      proSubjectDetails: (fields[11] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProDashboardModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(11)
      ..write(obj.proSubjectDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProDashboardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
