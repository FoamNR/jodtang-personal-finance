import 'package:flutter_test/flutter_test.dart';
import 'package:jod_tang/domain/models/transaction_item.dart';
import 'package:jod_tang/domain/models/wallet.dart';

double calculateAvailableBalance({
  required List<Wallet> wallets,
  required int walletId,
  TransactionItem? transactionToEdit,
}) {
  final wallet = wallets.where((w) => w.id == walletId).firstOrNull;
  if (wallet == null) return 0.0;
  double balance = wallet.currentBalance;

  if (transactionToEdit != null) {
    if (transactionToEdit.type == TransactionType.transfer) {
      if (transactionToEdit.walletId == walletId) {
        balance += transactionToEdit.amount;
      }
      if (transactionToEdit.toWalletId == walletId) {
        balance -= transactionToEdit.amount;
      }
    } else if (transactionToEdit.type == TransactionType.expense) {
      if (transactionToEdit.walletId == walletId) {
        balance += transactionToEdit.amount;
      }
    } else if (transactionToEdit.type == TransactionType.income) {
      if (transactionToEdit.walletId == walletId) {
        balance -= transactionToEdit.amount;
      }
    }
  }
  return balance;
}

void main() {
  group('Transfer Balance Validation Logic Tests', () {
    final walletA = Wallet(
      id: 1,
      name: 'บัญชีหลัก',
      initialBalance: 1000.0,
      currentBalance: 500.0,
      colorValue: 0xFF2196F3,
      iconCodePoint: 0xe040,
    );

    final walletB = Wallet(
      id: 2,
      name: 'เงินออม',
      initialBalance: 200.0,
      currentBalance: 800.0,
      colorValue: 0xFF4CAF50,
      iconCodePoint: 0xe041,
    );

    final wallets = [walletA, walletB];

    test('New transfer: available balance is equal to wallet current balance', () {
      final availableA = calculateAvailableBalance(
        wallets: wallets,
        walletId: 1,
        transactionToEdit: null,
      );
      expect(availableA, 500.0);

      // Transferring 500 or less should be valid
      expect(500.0 <= availableA, isTrue);
      // Transferring 500.01 or more should be invalid
      expect(500.01 <= availableA, isFalse);
    });

    test('Edit existing transfer: restores amount to source wallet', () {
      // Suppose txToEdit was 300 transferred from Wallet A to Wallet B
      final editTx = TransactionItem(
        id: 99,
        type: TransactionType.transfer,
        amount: 300.0,
        date: DateTime.now(),
        walletId: 1,
        toWalletId: 2,
        createdAt: DateTime.now(),
      );

      final availableA = calculateAvailableBalance(
        wallets: wallets,
        walletId: 1,
        transactionToEdit: editTx,
      );
      // 500 current + 300 from old tx = 800 available to transfer
      expect(availableA, 800.0);

      // And for destination wallet B, it shouldn't count the 300 that is being edited
      final availableB = calculateAvailableBalance(
        wallets: wallets,
        walletId: 2,
        transactionToEdit: editTx,
      );
      // 800 current - 300 from old tx = 500 available
      expect(availableB, 500.0);
    });

    test('Zero or negative balance wallet cannot transfer', () {
      final emptyWallet = Wallet(
        id: 3,
        name: 'กระเป๋าว่าง',
        initialBalance: 0.0,
        currentBalance: 0.0,
        colorValue: 0xFF000000,
        iconCodePoint: 0xe042,
      );

      final available = calculateAvailableBalance(
        wallets: [emptyWallet],
        walletId: 3,
        transactionToEdit: null,
      );
      expect(available, 0.0);
      expect(1.0 <= available, isFalse);
    });
  });
}
