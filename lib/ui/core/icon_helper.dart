import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(int codePoint) {
    for (final icon in availableIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.category_outlined;
  }

  // Curated list of icons for Category / Wallet picker
  static const List<IconData> availableIcons = [
    Icons.restaurant,
    Icons.local_cafe,
    Icons.directions_car,
    Icons.directions_bus,
    Icons.shopping_bag_outlined,
    Icons.shopping_cart_outlined,
    Icons.home_outlined,
    Icons.bolt,
    Icons.water_drop_outlined,
    Icons.medical_services_outlined,
    Icons.fitness_center,
    Icons.movie_outlined,
    Icons.sports_esports_outlined,
    Icons.flight,
    Icons.hotel,
    Icons.school_outlined,
    Icons.pets,
    Icons.savings_outlined,
    Icons.account_balance_outlined,
    Icons.payments_outlined,
    Icons.credit_card,
    Icons.account_balance_wallet_outlined,
    Icons.work_outline,
    Icons.card_giftcard,
    Icons.trending_up,
    Icons.phone_iphone,
    Icons.wifi,
    Icons.attach_money,
    Icons.category_outlined,
    Icons.more_horiz,
  ];
}
