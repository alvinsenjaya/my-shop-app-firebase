import 'package:flutter/material.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:my_shop_app/widgets/product_list_item.dart';

class ProductGridViewBuilder extends StatelessWidget {
  final List<Product> _products;

  const ProductGridViewBuilder(this._products);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _products.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: ((context, i) {
        return ProductListItem(_products[i]);
      }),
    );
  }
}
