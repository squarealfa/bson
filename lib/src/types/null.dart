part of bson2;

class BsonNull extends BsonObject {
  BsonNull();
  BsonNull.fromBuffer(BsonBinary buffer);

  @override
  // ignore: prefer_void_to_null
  Null get value => null;
  @override
  int byteLength() => 0;
  @override
  int get typeByte => bsonDataNull;
  @override
  void packValue(BsonBinary buffer) {}
  @override
  void unpackValue(BsonBinary buffer) {}
}
