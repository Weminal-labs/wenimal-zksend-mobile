import 'package:flutter_test/flutter_test.dart';
import 'package:sui/cryptography/ed25519_keypair.dart';
import 'package:sui/sui.dart';
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
      String myLink = await ZkSendLinkBuilder.createLinkObject(
          sender: suiAccount,
          suiObjectRef: SuiObjectRef(
              "4oh73oKqJBqHp4FHcJnzqfAnF7xaqhZhR4HCmQv3XHcB",
              "0xd8c1f5b9530abb3a454ed145740616fcfec0bca6ef735342560e254198f1e1a8",
              29091175),
          objectType:
              '0xfdba6d8e99368a97d27d4e797da45ef43fe47e90aa70f80d5eeaa2e5689bda64::event::Ticket');
      print(myLink);
    },
  );
}
