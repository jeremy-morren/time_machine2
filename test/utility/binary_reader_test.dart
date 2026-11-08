import 'package:test/test.dart';
import 'package:time_machine2/src/utility/binary_reader.dart';
import 'dart:typed_data';

/// 0x1234567890ABCDEF, parsed: dart2js can't compile the literal, which isn't
/// exact as a JavaScript number. Only used by tests that don't run on dart2js.
final int int64Value = int.parse('1234567890ABCDEF', radix: 16);

void main() {
  group('BinaryReader', () {
    late ByteData data;
    late BinaryReader reader;

    test('readInt32 reads correct value', () {
      data = ByteData(4)..setInt32(0, 0x12345678, Endian.little);
      reader = BinaryReader(data);
      expect(reader.readInt32(), equals(0x12345678));
    });

    test('readInt32 reads negative value', () {
      data = ByteData(4)..setInt32(0, -0x12345678, Endian.little);
      reader = BinaryReader(data);
      expect(reader.readInt32(), equals(-0x12345678));
    });

    test('readUint8 reads correct value', () {
      data = ByteData(1)..setUint8(0, 0xFF);
      reader = BinaryReader(data);
      expect(reader.readUint8(), equals(0xFF));
    });

    test('readUint8 reads high-bit value', () {
      data = ByteData(1)..setUint8(0, 0x80);
      reader = BinaryReader(data);
      expect(reader.readUint8(), equals(0x80));
    });

    test('readBool reads correct value', () {
      data = ByteData(2)
        ..setUint8(0, 1)
        ..setUint8(1, 0);
      reader = BinaryReader(data);
      expect(reader.readBool(), isTrue);
      expect(reader.readBool(), isFalse);
    });

    // These need 64-bit integers, and dart2js doesn't support
    // ByteData.setInt64.
    test('readInt64 reads correct value', () {
      data = ByteData(8)..setInt64(0, int64Value, Endian.little);
      reader = BinaryReader(data);
      expect(reader.readInt64(), equals(int64Value));
    }, testOn: '!js');

    test('readInt64 reads negative value', () {
      data = ByteData(8)..setInt64(0, -int64Value, Endian.little);
      reader = BinaryReader(data);
      expect(reader.readInt64(), equals(-int64Value));
    }, testOn: '!js');

    // readInt64 doesn't use ByteData.getInt64, so it works on dart2js for
    // values JavaScript numbers hold exactly.
    test('readInt64 reads a value within ±2^53', () {
      data = Uint8List.fromList([0xEF, 0xCD, 0xAB, 0x78, 0x56, 0x34, 0x12, 0])
          .buffer
          .asByteData();
      reader = BinaryReader(data);
      expect(reader.readInt64(), equals(0x12345678ABCDEF));
    });

    test('readInt64 reads a negative value within ±2^53', () {
      data =
          Uint8List.fromList([0x11, 0x32, 0x54, 0x87, 0xA9, 0xCB, 0xED, 0xFF])
              .buffer
              .asByteData();
      reader = BinaryReader(data);
      expect(reader.readInt64(), equals(-0x12345678ABCDEF));
    });

    test('read7BitEncodedInt reads correct value for small numbers', () {
      data = ByteData(1)..setUint8(0, 0x7F);
      reader = BinaryReader(data);
      expect(reader.read7BitEncodedInt(), equals(0x7F));
    });

    test('read7BitEncodedInt reads correct value for large numbers', () {
      data = ByteData(2)
        ..setUint8(0, 0xB4)
        ..setUint8(1, 0x24);
      reader = BinaryReader(data);
      expect(reader.read7BitEncodedInt(), equals(0x1234));
    });

    test('readString reads correct value', () {
      var bytes = [5, 0x48, 0x65, 0x6C, 0x6C, 0x6F]; // "Hello"
      data = ByteData.view(Uint8List.fromList(bytes).buffer);
      reader = BinaryReader(data);
      expect(reader.readString(), equals('Hello'));
    });

    test('readStringList reads correct values', () {
      var bytes = [
        2, // count
        5, 0x48, 0x65, 0x6C, 0x6C, 0x6F, // "Hello"
        5, 0x57, 0x6F, 0x72, 0x6C, 0x64 // "World"
      ];
      data = ByteData.view(Uint8List.fromList(bytes).buffer);
      reader = BinaryReader(data);
      expect(reader.readStringList(), equals(['Hello', 'World']));
    });
  });
}
