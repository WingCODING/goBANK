import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goflutterbank/core/providers/core.providers.dart';
import 'package:goflutterbank/features/transfer/data/transfer.api.dart';

/// API de transferências amarrada ao Dio do bank (Java).
final transferApiProvider =
    Provider<TransferApi>((ref) => TransferApi(ref.watch(bankDioProvider)));
