import 'package:flutter_test/flutter_test.dart';
import 'package:sui/builder/transaction_block.dart';
import 'package:sui/types/common.dart';
import 'package:zksend/zk_bag.dart';
import 'package:sui/sui.dart';

final keyPair = Ed25519Keypair.fromMnemonics(
    "frozen okay holiday moon worth mushroom mix trap auto latin myth rapid");
final suiAccount = SuiAccount(keyPair);
final suiAccount2 = SuiAccount.ed25519Account();
final SUI_COIN_TYPE = normalizeStructTagString('0x2::sui::SUI');

const TESTNET_IDS = ZkBagContractOptions(
  packageId:
      '0x036fee67274d0d85c3532f58296abe0dee86b93864f1b2b9074be6adb388f138',
  bagStoreId:
      '0x5c63e71734c82c48a3cb9124c54001d1a09736cfb1668b3b30cd92a96dd4d0ce',
  bagStoreTableId:
      '0x4e1bc4085d64005e03eb4eab2510d52 7aeba9548cda431cb8f149ff37451f870',
);

void main() {
  test('test new', () async {
    final contract = ZkBag(package: TESTNET_IDS.packageId);
    final txb = TransactionBlock();
    contract.newTransaction(txb,
        arguments: [TESTNET_IDS.bagStoreId, suiAccount.getAddress()]);
    SuiClient client = SuiClient(SuiUrls.testnet);
    final result = await client.signAndExecuteTransactionBlock(suiAccount, txb);
    print(result.digest);
  });

  test(
    'test add',
    () async {
      final contract = ZkBag(package: TESTNET_IDS.packageId);
      final txb = TransactionBlock();

      // // get mergedCoins object
      // var mergedCoins = Map<String, dynamic>();
      // // get all coins of user
      // final client = SuiClient(SuiUrls.testnet);
      // final allCoins = await client.getAllCoins(suiAccount.getAddress());
      // final coins = allCoins.data;
      //
      // for (CoinStruct coin in coins) {
      // print('coins: $coins');
      // final mappedCoins = coins
      //     .map(
      //       (coin) => txb.objectRef(
      //           SuiObjectRef(coin.digest, coin.coinObjectId, coin.version)),
      //     )
      //     .toList();
      // final first = mappedCoins[0];
      // final rest = mappedCoins.skip(1).toList();
      //
      // if (rest.isNotEmpty) {
      //   txb.mergeCoins(mappedCoins[0], rest);
      // }
      // mergedCoins = {'coinType': '0x2::sui::SUI', 'object': txb.object(first)};
      // // }
      // print('mergedCoins: $mergedCoins');
      // // end
      const coinType = '0x2::sui::SUI';
      final splits = txb.splitCoins(txb.gas, [txb.pureInt(20000)]);
      print('spilt: ${splits.result}');
      contract.add(txb, arguments: [
        TESTNET_IDS.bagStoreId,
        suiAccount.getAddress(),
        splits[0]
      ], typeArguments: [
        '0x2::coin::Coin<0x2::sui::SUI>'
      ]);
      SuiClient client = SuiClient(SuiUrls.testnet);
      final resp = await client.signAndExecuteTransactionBlock(suiAccount, txb);
    },
  );

  test(
    'test spilt coin',
    () async {
      final account = SuiAccount.fromMnemonics(
          'frozen okay holiday moon worth mushroom mix trap auto latin myth rapid',
          SignatureScheme.Ed25519);
      // final account = SuiAccount.ed25519Account();
      // final faucet = FaucetClient(SuiUrls.faucetTest);
      // await faucet.requestSuiFromFaucetV0(account.getAddress());
      final client = SuiClient(SuiUrls.testnet);
      final tx = TransactionBlock();
      // final coin = tx.splitCoins(tx.gas, [tx.pureInt(1000000)]);
      // print('tx.gas: ${tx.gas}');
      // print(('coin: ${coin.result}'));

      final coins = await client.getCoins(account.getAddress(),
          coinType: '0x2::sui::SUI');
      print('coins: ${coins.data[0].coinObjectId}');

      // tx.transferObjects([coin], tx.pureAddress(account.getAddress()));
      // final result = await client.signAndExecuteTransactionBlock(account, tx);
      // print(result.digest);
    },
  );

  test(
    'sign',
    () async {
      SuiClient client = SuiClient(SuiUrls.testnet);
      final txb = TransactionBlock();
      final mergedCoins = Map.fromEntries([MapEntry(SUI_COIN_TYPE, txb.gas)]);
      print('mergedCoins: $mergedCoins');

      // final allCoins = await client.getAllCoins(suiAccount.getAddress());
      // final coins = allCoins.data;
      final contract = ZkBag(package: TESTNET_IDS.packageId);
      contract.newTransaction(txb,
          arguments: [TESTNET_IDS.bagStoreId, suiAccount2.getAddress()]);

      print('new done');
      final balance = BigInt.from(200000000);
      print('balance: $balance');

      //
      // //add
      print('before spilts');
      //
      final splits = txb.splitCoins(txb.gas, [txb.pureInt(200000000)]);
      print('spilts: $splits');
      // txb.transferObjects([splits], txb.pureAddress(suiAccount2.getAddress()));
      //
      contract.add(txb, arguments: [
        TESTNET_IDS.bagStoreId,
        suiAccount2.getAddress(),
        splits[0]
      ], typeArguments: [
        '0x2::coin::Coin<0x2::sui::SUI>'
      ]);
      print('add done');
      // print('slipt done');
      // // final mergedCoins = Map<String, dynamic>
      final addResult =
          await client.signAndExecuteTransactionBlock(suiAccount, txb);
      // // print(addResult.digest);
      // print('add done');
    },
  );
}
