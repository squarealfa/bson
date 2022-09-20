part of bson2;

class BsonBinary extends BsonObject {
  static final bool useFixnum = _isIntWorkaroundNeeded();
  static final bufferSize = 256;
  @Deprecated('use "bufferSize"')
  // ignore: non_constant_identifier_names
  static final BUFFER_SIZE = bufferSize;

  static final subtypeBinary = 0;
  @Deprecated('use "subtypeBinary"')
  // ignore: non_constant_identifier_names
  static final SUBTYPE_DEFAULT = subtypeBinary;

  static final subtypeFunction = 1;
  @Deprecated('use "subtypeFunction"')
  // ignore: non_constant_identifier_names
  static final SUBTYPE_FUNCTION = subtypeFunction;

  static final subtypeBinaryOld = 2;
  @Deprecated('use "subtypeBinaryOld"')
  // ignore: non_constant_identifier_names
  static final SUBTYPE_BYTE_ARRAY = subtypeBinaryOld;

  static final subtypeUuidOld = 3;
  @Deprecated('use "subtypeUuidOld"')
  // ignore: non_constant_identifier_names
  static final SUBTYPE_UUID = subtypeUuidOld;

  static final subtypeUuid = 4;
  @Deprecated('use "subtypeUuid"')
  // ignore: non_constant_identifier_names
  static final SUBTYPE_MD5 = subtypeUuid;

  static final subtypeUserDefined = 128;
  @Deprecated('use "subtypeUserDefined"')
  // ignore: non_constant_identifier_names
  static final SUBTYPE_USER_DEFINED = subtypeUserDefined;

  // Use a list as jump-table. It is faster than switch and if.
  static const int char0 = 48;
  static const int char1 = 49;
  static const int char2 = 50;
  static const int char3 = 51;
  static const int char4 = 52;
  static const int char5 = 53;
  static const int char6 = 54;
  static const int char7 = 55;
  static const int char8 = 56;
  static const int char9 = 57;
  static const int charA = 97;
  static const int charB = 98;
  static const int charC = 99;
  static const int charD = 100;
  static const int charE = 101;
  static const int charF = 102;

  static final tokens = createTokens();

  static List<int?> createTokens() {
    var result = List<int?>.generate(255, (_) => null, growable: false);
    result[char0] = 0;
    result[char1] = 1;
    result[char2] = 2;
    result[char3] = 3;
    result[char4] = 4;
    result[char5] = 5;
    result[char6] = 6;
    result[char7] = 7;
    result[char8] = 8;
    result[char9] = 9;
    result[charA] = 10;
    result[charB] = 11;
    result[charC] = 12;
    result[charD] = 13;
    result[charE] = 14;
    result[charF] = 15;
    return result;
  }

  BsonBinary(int length, {int? subType})
      : _byteList = Uint8List(length),
        _subType = subType ?? subtypeBinary;

  BsonBinary.from(Iterable<int> byteList, {int? subType})
      : _byteList = Uint8List(byteList.length)
          ..setRange(0, byteList.length, byteList),
        _subType = subType ?? subtypeBinary;

  BsonBinary.fromHexString(String hexString, {int? subType})
      : _hexString = hexString.toLowerCase(),
        _byteList = _makeByteList(hexString.toLowerCase()),
        _subType = subType ?? subtypeBinary;

  factory BsonBinary.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    if (data.subType == subtypeUuid) {
      return BsonUuid.from(data.byteList);
    } else if (data.subType != subtypeBinary) {
      throw ArgumentError(
          'Binary subtype "${data.subType}" is not yet managed');
    }
    return BsonBinary.from(data.byteList);
  }

  // These values are always initiated
  Uint8List _byteList;
  int _subType;

  // These are initiated on-demand
  // Not used at present, see the getter comment
  //ByteData? _byteArray;
  String? _hexString;

  int offset = 0;

  static BsonBinaryData extractData(BsonBinary buffer) {
    var size = buffer.readInt32();
    var locSubType = buffer.readByte();
    var locByteList = Uint8List(size);
    locByteList.setRange(0, size, buffer.byteList, buffer.offset);
    buffer.offset += size;
    return BsonBinaryData(locByteList, locSubType);
  }

  Uint8List get byteList => _byteList;
  // as byteList can be still changed outside the class (ex. pack methods)
  // we do not store the values at present, but calculate them always
  // on request.
  // This logic will change when _byteList will be immutable and we will be
  // capable of caching these values
  ByteData get byteArray => /*_byteArray ??=*/ _getByteData(byteList);
  String get hexString => /*_hexString ??=*/ _makeHexString();

  @override
  int get typeByte => bsonDataBinary;
  int get subType => _subType;

  ByteData _getByteData(Uint8List from) => ByteData.view(from.buffer);

  @Deprecated('It is no more useful. It is called internally when needed.')
  String makeHexString() => _makeHexString();

  String _makeHexString() {
    var stringBuffer = StringBuffer();
    for (final byte in byteList) {
      if (byte < 16) {
        stringBuffer.write('0');
      }
      stringBuffer.write(byte.toRadixString(16));
    }
    return '$stringBuffer'.toLowerCase();
  }

  @Deprecated('It is no more useful. It is called internally when needed.')
  Uint8List makeByteList() {
    if (_hexString == null) {
      throw ArgumentError('Null hex representation');
    }
    return _makeByteList(_hexString!);
  }

  static Uint8List _makeByteList(String localHexString) {
    if (localHexString.length.isOdd) {
      throw ArgumentError(
          'Not valid hex representation: $localHexString (odd length)');
    }
    var localByteList = Uint8List((localHexString.length / 2).round().toInt());
    var pos = 0;
    var listPos = 0;
    while (pos < localHexString.length) {
      var char = localHexString.codeUnitAt(pos);
      var n1 = tokens[char];
      if (n1 == null) {
        throw ArgumentError(
            'Invalid char ${localHexString[pos]} in $localHexString');
      }
      pos++;
      char = localHexString.codeUnitAt(pos);
      var n2 = tokens[char];
      if (n2 == null) {
        throw ArgumentError(
            'Invalid char ${localHexString[pos]} in $localHexString');
      }
      localByteList[listPos++] = (n1 << 4) + n2;
      pos++;
    }
    return localByteList;
  }

  void setIntExtended(int value, int numOfBytes, Endian endianness) {
    var byteListTmp = Uint8List(4);
    var byteArrayTmp = _getByteData(byteListTmp);
    if (numOfBytes == 3) {
      byteArrayTmp.setInt32(0, value, endianness);
    } else {
      throw Exception('Unsupported num of bytes: $numOfBytes');
    }
    byteList.setRange(offset, offset + numOfBytes, byteListTmp);
  }

  void reverse(int numOfBytes) {
    void swap(int x, int y) {
      var t = byteList[x + offset];
      byteList[x + offset] = byteList[y + offset];
      byteList[y + offset] = t;
    }

    for (var i = 0; i <= (numOfBytes - 1) % 2; i++) {
      swap(i, numOfBytes - 1 - i);
    }
  }

  void encodeInt(
      int position, int value, int numOfBytes, Endian endianness, bool signed) {
    switch (numOfBytes) {
      case 4:
        byteArray.setInt32(position, value, endianness);
        break;
      case 2:
        byteArray.setInt16(position, value, endianness);
        break;
      case 1:
        byteArray.setInt8(position, value);
        break;
      default:
        throw Exception('Unsupported num of bytes: $numOfBytes');
    }
  }

  void writeInt(int value,
      {int numOfBytes = 4, endianness = Endian.little, bool signed = false}) {
    encodeInt(offset, value, numOfBytes, endianness, signed);
    offset += numOfBytes;
  }

  void writeByte(int value) {
    encodeInt(offset, value, 1, Endian.little, false);
    offset += 1;
  }

  void writeDouble(double value) {
    byteArray.setFloat64(offset, value, Endian.little);
    offset += 8;
  }

  void writeInt64(int value) {
    if (useFixnum) {
      var d64 = Int64(value);
      byteList.setRange(offset, offset + 8, d64.toBytes());
    } else {
      byteArray.setInt64(offset, value, Endian.little);
    }
    offset += 8;
  }

  /// Write an Int64 field
  void writeFixInt64(Int64 value) {
    byteList.setRange(offset, offset + 8, value.toBytes());
    offset += 8;
  }

  int readByte() => byteList[offset++];

  int readInt32() {
    offset += 4;
    return byteArray.getInt32(offset - 4, Endian.little);
  }

  int readInt64() {
    offset += 8;
    if (useFixnum) {
      offset -= 8;
      var i1 = readInt32();
      var i2 = readInt32();
      var i64 = Int64.fromInts(i2, i1);
      return i64.toInt();
    }
    return byteArray.getInt64(offset - 8, Endian.little);
  }

  /// Read an Int64 value
  Int64 readFixInt64() {
    var i1 = readInt32();
    var i2 = readInt32();
    return Int64.fromInts(i2, i1);
  }

  double readDouble() {
    offset += 8;
    return byteArray.getFloat64(offset - 8, Endian.little);
  }

  String readCString() {
    var stringBytes = <int>[];
    while (byteList[offset++] != 0) {
      stringBytes.add(byteList[offset - 1]);
    }
    return utf8.decode(stringBytes);
  }

  void writeCString(String val) {
    final utfData = utf8.encode(val);
    byteList.setRange(offset, offset + utfData.length, utfData);
    offset += utfData.length;
    writeByte(0);
  }

  @override
  int byteLength() => byteList.length + 4 + 1;
  bool atEnd() => offset == byteList.length;
  void rewind() => offset = 0;

  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteList.length);
    buffer.writeByte(_subType);
    buffer.byteList
        .setRange(buffer.offset, buffer.offset + byteList.length, byteList);
    buffer.offset += byteList.length;
  }

  @override
  void unpackValue(BsonBinary buffer) {
    var size = buffer.readInt32();
    _subType = buffer.readByte();
    _byteList = Uint8List(size);
    byteList.setRange(0, size, buffer.byteList, buffer.offset);
    buffer.offset += size;
  }

  @override
  dynamic get value => this;
  @override
  String toString() => 'BsonBinary($hexString)';
}

bool _isIntWorkaroundNeeded() {
  var n = 9007199254740992;
  var newInt = n + 1;
  return newInt.toString() == n.toString();
}

class BsonBinaryData {
  BsonBinaryData(this.byteList, this.subType);

  final Uint8List byteList;
  final int subType;
}
