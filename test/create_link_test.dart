import 'package:flutter_test/flutter_test.dart';
import 'package:sui/sui.dart';
import 'package:zksend/builder.dart';
import 'package:zksend/zk_sign_builder.dart';

void main() {
  test('test create link coin', () async {
    // ZkLoginSignatureInputs zkLoginSignatureInputs = ZkLoginSignatureInputs(
    //   proofPoints: proofPoints,
    //   issBase64Details: Claim.fromJson(proof['issBase64Details']),
    //   addressSeed: addressSeed.toString(),
    //   headerBase64: proof['headerBase64'],
    // );   You need wenimal-zkLogin and sui package to get it. You can view demo on this link
    // https://github.com/Weminal-labs/weminal-zklogin-mobile.git

    // ZkSignBuilder.setInfo(
    //     inputZkLoginSignatureInputs: zkLoginSignatureInputs,
    //     inputMaxEpoch:
    //         int.parse((res['maxEpoch']!).toString().replaceAll('.0', '')));

    // String url = await ZkSendLinkBuilder.createLink(ephemeralKeyPair: ephemeralKeyPair, senderAddress: senderAddress, balances: balances);
  });
  test('test create link nft', () async {
    // ZkLoginSignatureInputs zkLoginSignatureInputs = ZkLoginSignatureInputs(
    //   proofPoints: proofPoints,
    //   issBase64Details: Claim.fromJson(proof['issBase64Details']),
    //   addressSeed: addressSeed.toString(),
    //   headerBase64: proof['headerBase64'],
    // );   You need wenimal-zkLogin and sui package to get it. You can view demo on this link
    // https://github.com/Weminal-labs/weminal-zklogin-mobile.git

    // ZkSignBuilder.setInfo(
    //     inputZkLoginSignatureInputs: zkLoginSignatureInputs,
    //     inputMaxEpoch:
    //         int.parse((res['maxEpoch']!).toString().replaceAll('.0', '')));

    // String url = await ZkSendLinkBuilder.createLinkObject(ephemeralKeyPair: ephemeralKeyPair, senderAddress: senderAddress, suiObjectRef: SuiObjectRef(digest, objectId, version), objectType: objectType)
  });

  test('test create link coin', () async {
    Ed25519Keypair keypair = Ed25519Keypair.fromMnemonics(
        'frozen okay holiday moon worth mushroom mix trap auto latin myth rapid');
    String url = await ZkSendLinkBuilder.createLink2(
        ephemeralKeyPair: keypair,
        senderAddress:
            '0x89ef5e69e2f6dd0e759f15a13823098011cca2122d1c0225f5b6f3337be88485',
        balances: 10000000);
    print(url);
  });
}
