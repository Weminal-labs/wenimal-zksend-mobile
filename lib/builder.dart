import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_bech32/dart_bech32.dart';
import 'package:sui/sui.dart';
import 'package:sui/types/common.dart';
import 'package:zksend/zk_bag.dart';

const TESTNET_IDS = ZkBagContractOptions(
  packageId:
      '0x036fee67274d0d85c3532f58296abe0dee86b93864f1b2b9074be6adb388f138',
  bagStoreId:
      '0x5c63e71734c82c48a3cb9124c54001d1a09736cfb1668b3b30cd92a96dd4d0ce',
  bagStoreTableId:
      '0x4e1bc4085d64005e03eb4eab2510d52 7aeba9548cda431cb8f149ff37451f870',
);

const Map<String, int> SIGNATURE_SCHEME_TO_FLAG = {
  'ED25519': 0x00,
  'Secp256k1': 0x01,
  'Secp256r1': 0x02,
  'MultiSig': 0x03,
  'ZkLogin': 0x05,
};
const SUI_PRIVATE_KEY_PREFIX = 'suiprivkey';

const PRIVATE_KEY_SIZE = 32;

const Map<int, String> SIGNATURE_FLAG_TO_SCHEME = {
  0x00: 'ED25519',
  0x01: 'Secp256k1',
  0x02: 'Secp256r1',
  0x03: 'MultiSig',
  0x05: 'ZkLogin',
};
const DEFAULT_ZK_SEND_LINK_OPTIONS = {
  'host': 'https://dev.polymedia-send.pages.dev',
  'path': '/claim',
  'network': 'testnet',
};

class ZkSendLinkBuilder {
  static final SUI_COIN_TYPE = normalizeStructTagString('0x2::sui::SUI');
  static final Ed25519Keypair keypair = Ed25519Keypair();

  static Future<void> createLink(
    SuiAccount sender,
    int balances,
  ) async {
    ZkBag contract = ZkBag(package: TESTNET_IDS.packageId);
    final txb = TransactionBlock();
    txb.setSender(sender.getAddress());
    final mergedCoins = Map.fromEntries([MapEntry(SUI_COIN_TYPE, txb.gas)]);
    var receive = SuiAccount.ed25519Account();

    contract.newTransaction(txb,
        arguments: [TESTNET_IDS.bagStoreId, receive.getAddress()]);
    print('recive.address: ${receive.getAddress()}');
    final splits = txb.splitCoins(txb.gas, [txb.pureInt(balances)]);
    contract.add(txb,
        arguments: [TESTNET_IDS.bagStoreId, receive.getAddress(), splits[0]],
        typeArguments: ['0x2::coin::Coin<0x2::sui::SUI>']);
    final addResult = await SuiClient(SuiUrls.testnet)
        .signAndExecuteTransactionBlock(sender, txb);
    print('createLink: addResult.digest: ${addResult.digest}');
    var url = getLink(receive.getSecretKey());
    print('createLink: $url');
  }

  static getLink(Uint8List secretKey) {
    var encodedSecretKey = base64Encode(decodeSuiPrivateKeySecretKey(
        encodeSuiPrivateKey(
            secretKey.sublist(0, PRIVATE_KEY_SIZE), 'ED25519')));
    var hash = '\$${encodedSecretKey}';
    print('hash: $hash');

    var link = "${DEFAULT_ZK_SEND_LINK_OPTIONS['host']}/claim#${hash}";

    return link.toString();
  }
}

Uint8List decodeSuiPrivateKeySecretKey(String value) {
  Decoded decoded = bech32.decode(value);
  var prefix = decoded.prefix;
  var words = decoded.words;
  if (prefix != SUI_PRIVATE_KEY_PREFIX) {
    throw Exception('invalid private key prefix');
  }
  final extendedSecretKey = Uint8List.fromList(bech32.fromWords(words));
  final secretKey = extendedSecretKey.sublist(1);
  final signatureScheme = SIGNATURE_FLAG_TO_SCHEME[extendedSecretKey[0]]!;

  return secretKey;
}

String encodeSuiPrivateKey(Uint8List bytes, String scheme) {
  print('bytes.length = ${bytes.length}');
  if (bytes.length != PRIVATE_KEY_SIZE) {
    throw Exception(
        'Invalid bytes length: bytes.length = ${bytes.length}, PRIVATE_KEY_SIZE: ${PRIVATE_KEY_SIZE}');
  }
  int flag = SIGNATURE_SCHEME_TO_FLAG[scheme]!;
  Uint8List privKeyBytes = Uint8List(bytes.length + 1);
  privKeyBytes[0] = flag;
  privKeyBytes.setRange(1, bytes.length + 1, bytes);
  return bech32.encode(Decoded(
      prefix: SUI_PRIVATE_KEY_PREFIX, words: bech32.toWords(privKeyBytes)));
}
