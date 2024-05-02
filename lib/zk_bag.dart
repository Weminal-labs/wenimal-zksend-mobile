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
