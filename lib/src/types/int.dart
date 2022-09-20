part of bson2;

class BsonInt extends BsonObject {
  BsonInt(this.data);

  BsonInt.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  int data;

  static int extractData(BsonBinary buffer) => buffer.readInt32();

  @override
  int get value => data;
  @override
  int byteLength() => 4;
  @override
  int get typeByte => bsonDataInt;
  @override
  void packValue(BsonBinary buffer) => buffer.writeInt(data);
  @override
  void unpackValue(BsonBinary buffer) => data = extractData(buffer);
}

class BsonLong extends BsonObject {
  BsonLong(this.data);
  BsonLong.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  int data;

  static int extractData(BsonBinary buffer) => buffer.readInt64();

  @override
  int get value => data;
  @override
  int byteLength() => 8;
  @override
  int get typeByte => bsonDataLong;
  @override
  void packValue(BsonBinary buffer) => buffer.writeInt64(data);
  @override
  void unpackValue(BsonBinary buffer) => data = extractData(buffer);
}
