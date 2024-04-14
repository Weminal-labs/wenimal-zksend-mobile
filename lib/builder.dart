import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_bech32/dart_bech32.dart';
import 'package:sui/builder/inputs.dart';
import 'package:sui/sui.dart';
import 'package:sui/sui_urls.dart';
import 'package:sui/types/common.dart';
import 'package:zksend/zk_bag.dart';
import 'package:zksend/zk_sign_builder.dart';

const MAINNET_IDS = ZkBagContractOptions(
  packageId:
      '0x5bb7d0bb3240011336ca9015f553b2646302a4f05f821160344e9ec5a988f740',
  bagStoreId:
      '0x65b215a3f2a951c94313a89c43f0adbd2fd9ea78a0badf81e27d1c9868a8b6fe',
  bagStoreTableId:
      '0x616db54ca564660cd58e36a4548be68b289371ef2611485c62c374a60960084e',
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
  'network': 'mainnet',
};

final suiClient = SuiClient(SuiUrls.mainnet);

class ZkSendLinkBuilder {
  static final SUI_COIN_TYPE = normalizeStructTagString('0x2::sui::SUI');
  static final Ed25519Keypair keypair = Ed25519Keypair();

  static Future<String> createLinkObject({
    required Keypair ephemeralKeyPair,
    required String senderAddress,
    required SuiObjectRef suiObjectRef,
    required String objectType,
  }) async {
    final txb = TransactionBlock();

    ZkBag contract = ZkBag(package: MAINNET_IDS.packageId);
    txb.setSender(senderAddress);
    var receive = SuiAccount.ed25519Account();
    //new
    contract.newTransaction(txb,
        arguments: [MAINNET_IDS.bagStoreId, receive.getAddress()]);

    final splits = txb.splitCoins(txb.gas, [txb.pureInt(10000000)]);
    contract.add(txb,
        arguments: [MAINNET_IDS.bagStoreId, receive.getAddress(), splits[0]],
        typeArguments: ['0x2::coin::Coin<0x2::sui::SUI>']);
    final objectRef = Inputs.objectRef(suiObjectRef);

    contract.add(txb,
        arguments: [MAINNET_IDS.bagStoreId, receive.getAddress(), objectRef],
        typeArguments: [objectType]);
    final sign = await txb
        .sign(SignOptions(signer: ephemeralKeyPair, client: suiClient));
    final zkSign = ZkSignBuilder.getZkSign(signSignature: sign.signature);

    final respZkSend = await suiClient.executeTransactionBlock(
      sign.bytes,
      [zkSign],
      options: SuiTransactionBlockResponseOptions(showEffects: true),
    );
    print('respZkSend: ${respZkSend.digest}');
    var url = getLink(receive.getSecretKey());
    return url;
  }

  static Future<String> createLink({
    required Keypair ephemeralKeyPair,
    required String senderAddress,
    required int balances,
  }) async {
    final txb = TransactionBlock();
    ZkBag contract = ZkBag(package: MAINNET_IDS.packageId);

    txb.setSender(senderAddress);
    var receive = SuiAccount.ed25519Account();

    contract.newTransaction(txb,
        arguments: [MAINNET_IDS.bagStoreId, receive.getAddress()]);
    final splits = txb.splitCoins(txb.gas, [txb.pureInt(balances)]);
    contract.add(txb,
        arguments: [MAINNET_IDS.bagStoreId, receive.getAddress(), splits[0]],
        typeArguments: ['0x2::coin::Coin<0x2::sui::SUI>']);
    final sign = await txb
        .sign(SignOptions(signer: ephemeralKeyPair, client: suiClient));
    final zkSign = ZkSignBuilder.getZkSign(signSignature: sign.signature);

    final respZkSend = await suiClient.executeTransactionBlock(
      sign.bytes,
      [zkSign],
      options: SuiTransactionBlockResponseOptions(showEffects: true),
    );
    print('respZkSend: ${respZkSend.digest}');
    var url = getLink(receive.getSecretKey());
    return url;
  }

  static getLink(Uint8List secretKey) {
    var encodedSecretKey = base64Encode(decodeSuiPrivateKeySecretKey(
        encodeSuiPrivateKey(
            secretKey.sublist(0, PRIVATE_KEY_SIZE), 'ED25519')));
    var hash = '\$${encodedSecretKey}';

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
  return secretKey;
}

String encodeSuiPrivateKey(Uint8List bytes, String scheme) {
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
