import 'package:flutter/material.dart';
import 'package:machine_test/model.dart';

class CartScreen extends StatelessWidget {
  final Map<int, int> itemCounts;
  final List<Model> cartItems;
  final Set<int> uniqueItemIds;

  CartScreen({
    required this.itemCounts,
    required this.cartItems,
    required this.uniqueItemIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: uniqueItemIds.length,
        itemBuilder: (context, index) {
          final itemId = uniqueItemIds.elementAt(index);
          final itemCount = itemCounts[itemId] ?? 0;

          // Find the corresponding item in cartItems
          final item = cartItems.firstWhere((item) => item.id == itemId,
              orElse: () => Model());

          if (itemCount > 0) {
            return ListTile(
              title: Text(item.title.toString()),
              subtitle: Text('Count: $itemCount'),
            );
          } else {
            return SizedBox.shrink(); // or return an empty widget
          }
        },
      ),
    );
  }
}
