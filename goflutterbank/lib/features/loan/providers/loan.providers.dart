import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goflutterbank/core/providers/core.providers.dart';
import 'package:goflutterbank/features/loan/data/loan.api.dart';

/// API de empréstimos amarrada ao Dio do loan-service (Go).
final loanApiProvider =
    Provider<LoanApi>((ref) => LoanApi(ref.watch(loanDioProvider)));
