// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 2;

  @override
  Category read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Category.food;
      case 1:
        return Category.transportation;
      case 2:
        return Category.entertainment;
      case 3:
        return Category.housing;
      case 4:
        return Category.salary;
      case 5:
        return Category.other;
      default:
        return Category.food;
    }
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    switch (obj) {
      case Category.food:
        writer.writeByte(0);
        break;
      case Category.transportation:
        writer.writeByte(1);
        break;
      case Category.entertainment:
        writer.writeByte(2);
        break;
      case Category.housing:
        writer.writeByte(3);
        break;
      case Category.salary:
        writer.writeByte(4);
        break;
      case Category.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
