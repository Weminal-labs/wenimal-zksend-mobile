import 'package:flutter_test/flutter_test.dart';
import 'package:sui/cryptography/ed25519_keypair.dart';
import 'package:sui/sui_account.dart';
import 'package:zksend/builder.dart';

final keyPair = Ed25519Keypair.fromMnemonics(
    "frozen okay holiday moon worth mushroom mix trap auto latin myth rapid");
final suiAccount = SuiAccount(keyPair);

void main() {
  test(
    'test createLink()',
    () async {
      await ZkSendLinkBuilder.createLink(suiAccount, 300000000);
    },
  );
  test(
    'test createLinkObject()',
    () async {
      await ZkSendLinkBuilder.createLinkObject(suiAccount, ZkSendLinkBuilder());
    },
  );

  // test('getlink', () {
  //   String url = ZkSendLinkBuilder.getLink();
  //   print(url);
  // });
}
