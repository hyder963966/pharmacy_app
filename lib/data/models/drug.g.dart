// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug.dart';

// ignore_for_file: type=lint
extension DrugQueryFilter on QueryBuilder<Drug, Drug, QFilterCondition> {
  QueryBuilder<Drug, Drug, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) => query.filter(id: value));
  }

  QueryBuilder<Drug, Drug, QAfterFilterCondition> barcodeEqualTo(String value) {
    return QueryBuilder.apply(this, (query) => query.filter(barcode: value));
  }

  QueryBuilder<Drug, Drug, QAfterFilterCondition> nameContains(String value) {
    return QueryBuilder.apply(this, (query) => query.filter(name: value));
  }
}

extension DrugQuerySortBy on QueryBuilder<Drug, Drug, QSortBy> {
  QueryBuilder<Drug, Drug, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) => query.sortBy('name'));
  }

  QueryBuilder<Drug, Drug, QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) => query.sortBy('quantity'));
  }
}

const DrugSchema = CollectionSchema<Drug>(
  name: 'Drug',
  id: 1234567890, // أي رقم مميز
  properties: {
    'barcode': IndexPropertySchema(
      name: 'barcode',
      type: IndexType.value,
      unique: true, replace: true,
    ),
    'name': PropertySchema(name: 'name', type: IsarType.string),
    'genericName': PropertySchema(name: 'genericName', type: IsarType.string),
    'dosageForm': PropertySchema(name: 'dosageForm', type: IsarType.string),
    'therapeuticGroup': PropertySchema(name: 'therapeuticGroup', type: IsarType.string),
    'price': PropertySchema(name: 'price', type: IsarType.double),
    'quantity': PropertySchema(name: 'quantity', type: IsarType.long),
    'reorderLevel': PropertySchema(name: 'reorderLevel', type: IsarType.long),
    'usage': PropertySchema(name: 'usage', type: IsarType.string),
    'imagePath': PropertySchema(name: 'imagePath', type: IsarType.string),
    'createdAt': PropertySchema(name: 'createdAt', type: IsarType.dateTime),
    'updatedAt': PropertySchema(name: 'updatedAt', type: IsarType.dateTime),
  },
  serialize: _drugSerialize,
  deserialize: _drugDeserialize,
);

void _drugSerialize(IsarCollection<Drug> collection, IsarRawObject rawObj, Drug object, List<int> offsets) {
  rawObj.writeString(offsets[0], object.barcode);
  rawObj.writeString(offsets[1], object.name);
  rawObj.writeString(offsets[2], object.genericName);
  rawObj.writeString(offsets[3], object.dosageForm);
  rawObj.writeString(offsets[4], object.therapeuticGroup);
  rawObj.writeDouble(offsets[5], object.price);
  rawObj.writeLong(offsets[6], object.quantity);
  rawObj.writeLong(offsets[7], object.reorderLevel);
  rawObj.writeString(offsets[8], object.usage);
  rawObj.writeString(offsets[9], object.imagePath);
  rawObj.writeDateTime(offsets[10], object.createdAt);
  rawObj.writeDateTime(offsets[11], object.updatedAt);
}

Drug _drugDeserialize(IsarCollection<Drug> collection, IsarRawObject rawObj) {
  return Drug(
    barcode: rawObj.readString(0) ?? '',
    name: rawObj.readString(1) ?? '',
    genericName: rawObj.readString(2) ?? '',
    dosageForm: rawObj.readString(3) ?? 'حبوب',
    therapeuticGroup: rawObj.readString(4) ?? 'عام',
    price: rawObj.readDouble(5) ?? 0.0,
    quantity: rawObj.readLong(6) ?? 0,
    reorderLevel: rawObj.readLong(7) ?? 10,
    usage: rawObj.readString(8),
    imagePath: rawObj.readString(9),
    createdAt: rawObj.readDateTime(10),
    updatedAt: rawObj.readDateTime(11),
  );
}