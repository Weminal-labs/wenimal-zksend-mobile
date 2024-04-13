import 'package:sui/sui.dart';

class ZkBagContractOptions {
  final String packageId;
  final String bagStoreId;
  final String bagStoreTableId;

  const ZkBagContractOptions({
    required this.packageId,
    required this.bagStoreId,
    required this.bagStoreTableId,
  });
}

const MAINNET_CONTRACT_IDS = ZkBagContractOptions(
  packageId:
      '0x5bb7d0bb3240011336ca9015f553b2646302a4f05f821160344e9ec5a988f740',
  bagStoreId:
      '0x65b215a3f2a951c94313a89c43f0adbd2fd9ea78a0badf81e27d1c9868a8b6fe',
  bagStoreTableId:
      '0x616db54ca564660cd58e36a4548be68b289371ef2611485c62c374a60960084e',
);

class ZkBag<IDs> {
  final String _package;
  final String _module = 'zk_bag';

  ZkBag({required String package}) : _package = package;

  void newTransaction(TransactionBlock txb,
      {required List<dynamic> arguments}) {
    txb.moveCall(
      '$_package::$_module::new',
      arguments: [
        txb.objectId(arguments[0]),
        arguments[1] is String ? txb.pureAddress(arguments[1]) : arguments[1],
      ],
    );
  }

  dynamic add(TransactionBlock txb,
      {required List<dynamic> arguments, required List<String> typeArguments}) {
    return txb.moveCall(
      '$_package::$_module::add',
      arguments: [
        txb.objectId(arguments[0]),
        arguments[1] is String ? txb.pureAddress(arguments[1]) : arguments[1],
        txb.object(arguments[2]),
      ],
      typeArguments: typeArguments,
    );
  }

  List<dynamic> initClaim(TransactionBlock txb,
      {required List<dynamic> arguments}) {
    final result = txb.moveCall(
      '$_package::$_module::init_claim',
      arguments: [txb.object(arguments[0])],
    );

    return [result[0], result[1]];
  }

  List<dynamic> reclaim(TransactionBlock txb,
      {required List<dynamic> arguments}) {
    final result = txb.moveCall(
      '$_package::$_module::reclaim',
      arguments: [
        txb.object(arguments[0]),
        arguments[1] is String ? txb.pureAddress(arguments[1]) : arguments[1],
      ],
    );

    return [result[0], result[1]];
  }

  dynamic claim(TransactionBlock txb,
      {required List<dynamic> arguments, required List<String> typeArguments}) {
    return txb.moveCall(
      '$_package::$_module::claim',
      arguments: [
        txb.object(arguments[0]),
        txb.object(arguments[1]),
        arguments[2] is String ? txb.object(arguments[2]) : arguments[2],
      ],
      typeArguments: typeArguments,
    );
  }

  void finalize(TransactionBlock txb, {required List<dynamic> arguments}) {
    txb.moveCall(
      '$_package::$_module::finalize',
      arguments: [txb.object(arguments[0]), txb.object(arguments[1])],
    );
  }

  void updateReceiver(TransactionBlock txb,
      {required List<dynamic> arguments}) {
    txb.moveCall(
      '$_package::$_module::update_receiver',
      arguments: [
        txb.object(arguments[0]),
        arguments[1] is String ? txb.pureAddress(arguments[1]) : arguments[1],
        arguments[2] is String ? txb.pureAddress(arguments[2]) : arguments[2],
      ],
    );
  }
}
