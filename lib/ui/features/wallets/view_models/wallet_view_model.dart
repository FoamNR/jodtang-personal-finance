import 'package:flutter/foundation.dart';
import '../../../../data/repositories/wallet_repository.dart';
import '../../../../domain/models/wallet.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository;

  WalletViewModel({WalletRepository? walletRepository})
      : _walletRepository = walletRepository ?? WalletRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Wallet> _wallets = [];
  List<Wallet> get wallets => _wallets;

  double get totalBalance => _wallets.fold(0.0, (acc, w) => acc + w.currentBalance);

  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await _walletRepository.getAllWallets();
    } catch (e) {
      debugPrint('Error loading wallets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveWallet(Wallet wallet) async {
    if (wallet.id == null) {
      await _walletRepository.addWallet(wallet);
    } else {
      await _walletRepository.updateWallet(wallet);
    }
    await loadWallets();
  }

  Future<void> deleteWallet(int id) async {
    await _walletRepository.deleteWallet(id);
    await loadWallets();
  }
}
