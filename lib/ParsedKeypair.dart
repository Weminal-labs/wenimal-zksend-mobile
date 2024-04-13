import 'dart:typed_data';

import 'package:sui/cryptography/signature.dart';

class ParsedKeypair {
  final SignatureScheme schema;
  final Uint8List secretKey;

  ParsedKeypair({
    required this.schema,
    required this.secretKey,
  });
}
