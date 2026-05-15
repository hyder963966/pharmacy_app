part of 'drug.dart';

class DrugAdapter extends TypeAdapter<Drug> {
  @override
  final int typeId = 0;

  @override
  Drug read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };

    return Drug(
      id: fields[0] as String?,
      barcode: fields[1] as String? ?? '',
      tradeName: fields[2] as String? ?? '',
      scientificName: fields[3] as String? ?? '',
      dosageForm: fields[4] as String? ?? 'حبوب',
      therapeuticGroup: fields[5] as String? ?? 'مسكنات',
      price: fields[6] as double? ?? 0,
      quantity: fields[7] as int? ?? 0,
      reorderLevel: fields[8] as int? ?? 5,
      uses: fields[9] as String? ?? '',
      imagePath: fields[10] as String?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Drug obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.tradeName)
      ..writeByte(3)
      ..write(obj.scientificName)
      ..writeByte(4)
      ..write(obj.dosageForm)
      ..writeByte(5)
      ..write(obj.therapeuticGroup)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.reorderLevel)
      ..writeByte(9)
      ..write(obj.uses)
      ..writeByte(10)
      ..write(obj.imagePath)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }
}
