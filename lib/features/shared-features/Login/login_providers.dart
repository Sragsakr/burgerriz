import 'package:flutter_riverpod/flutter_riverpod.dart';

//It is used to determine either to display the initial balance UI to the cashier or not
final timeToDisplayInitialBalanceProvider = StateProvider<bool>((ref) => false);
