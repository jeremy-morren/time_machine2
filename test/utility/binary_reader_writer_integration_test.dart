import 'package:test/test.dart';
import 'package:time_machine2/src/utility/binary_reader.dart';
import 'package:time_machine2/src/utility/binary_writer.dart';
import 'dart:typed_data';

/// 0x1234567890ABCDEF, parsed: dart2js can't compile the literal, which isn't
/// exact as a JavaScript number. Only used by tests that don't run on dart2js.
final int int64Value = int.parse('1234567890ABCDEF', radix: 16);

void main() {
  group('BinaryReader and BinaryWriter Integration', () {
    late List<int> output;
    late BinaryWriter writer;
    late ByteData data;
    late BinaryReader reader;

    setUp(() {
      output = [];
      writer = BinaryWriter(output);
    });

    void writeAndRead() {
      data = ByteData.view(Uint8List.fromList(output).buffer);
      reader = BinaryReader(data);
    }

    test('int32 roundtrip', () {
      writer.writeInt32(0x12345678);
      writeAndRead();
      expect(reader.readInt32(), equals(0x12345678));
    });

    test('int32 negative roundtrip', () {
      writer.writeInt32(-0x12345678);
      writeAndRead();
      expect(reader.readInt32(), equals(-0x12345678));
    });

    test('uint8 roundtrip', () {
      writer.writeUint8(0xFF);
      writeAndRead();
      expect(reader.readUint8(), equals(0xFF));
    });

    test('uint8 high-bit roundtrip', () {
      writer.writeUint8(0x80);
      writeAndRead();
      expect(reader.readUint8(), equals(0x80));
    });

    test('bool roundtrip', () {
      writer.writeBool(true);
      writer.writeBool(false);
      writeAndRead();
      expect(reader.readBool(), isTrue);
      expect(reader.readBool(), isFalse);
    });

    // The int64 tests need 64-bit integers, and writeInt64 uses
    // ByteData.setInt64, which dart2js doesn't support.
    test('int64 roundtrip', () {
      writer.writeInt64(int64Value);
      writeAndRead();
      expect(reader.readInt64(), equals(int64Value));
    }, testOn: '!js');

    test('int64 negative roundtrip', () {
      writer.writeInt64(-int64Value);
      writeAndRead();
      expect(reader.readInt64(), equals(-int64Value));
    }, testOn: '!js');

    test('7BitEncodedInt roundtrip', () {
      writer.write7BitEncodedInt(0x1234);
      writeAndRead();
      expect(reader.read7BitEncodedInt(), equals(0x1234));
    });

    test('string roundtrip', () {
      writer.writeString('Hello, World!');
      writeAndRead();
      expect(reader.readString(), equals('Hello, World!'));
    });

    test('stringList roundtrip', () {
      writer.writeStringList(['Hello', 'World']);
      writeAndRead();
      expect(reader.readStringList(), equals(['Hello', 'World']));
    });

    // Includes an int64, so not on dart2js either.
    test('complex roundtrip', () {
      writer.writeInt32(42);
      writer.writeBool(true);
      writer.writeString('Test');
      writer.writeInt64(int64Value);
      writer.writeStringList(['A', 'B', 'C']);

      writeAndRead();

      expect(reader.readInt32(), equals(42));
      expect(reader.readBool(), isTrue);
      expect(reader.readString(), equals('Test'));
      expect(reader.readInt64(), equals(int64Value));
      expect(reader.readStringList(), equals(['A', 'B', 'C']));
    }, testOn: '!js');
  });
}
