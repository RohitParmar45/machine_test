import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:machine_test/cart_page.dart';
import 'package:machine_test/model.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Model> postList = [];
  int? totalPrice = 0;
  Map<int, int> itemTotalPrices = {};
  Map<int, int> itemCounts = {};

  void initState() {
    super.initState();
    // Initialize itemTotalPrices and itemCounts maps here
    getPostApi().then((list) {
      for (var model in list) {
        itemTotalPrices[model.id ?? 0] = model.price ?? 0;
        itemCounts[model.id ?? 0] = 0;
      }
    });
  }

  void updateTotalPrice(int? price) {
    setState(() {
      totalPrice = (totalPrice ?? 0) + price!;
    });
  }

  Future<List<Model>> getPostApi() async {
    var response = await http.get(Uri.parse("https://dummyjson.com/products"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      var productList = data['products'];

      for (Map<String, dynamic> i in productList) {
        postList.add(Model.fromJson(i));
      }

      return postList;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Filter items with count greater than 0
          Set<int> uniqueItemIds =
              itemCounts.keys.where((id) => itemCounts[id]! > 0).toSet();

          // Navigate to the CartScreen and pass the necessary data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(
                uniqueItemIds: uniqueItemIds,
                itemCounts: itemCounts,
                cartItems: postList,
              ),
            ),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getPostApi(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Loading...");
                  } else {
                    return ListView.builder(
                        itemCount: postList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Image.network(
                                    postList[index].images![0].toString()),
                                title: Text(postList[index].title.toString()),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product price
                                    Text(
                                        'Price: \$${postList[index].price.toString()}'),
                                    // Available stock
                                    Text(
                                        'Total: \$${itemTotalPrices[postList[index].id ?? 0].toString()}'),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      itemTotalPrices[postList[index].id ?? 0] =
                                          (itemTotalPrices[postList[index].id ??
                                                      0] ??
                                                  0) +
                                              (postList[index].price ?? 0);

                                      itemCounts[postList[index].id ?? 0] =
                                          (itemCounts[postList[index].id ??
                                                      0] ??
                                                  0) +
                                              1;
                                    });
                                  },
                                  child: Text(
                                      '${itemCounts[postList[index].id ?? 0]}'),
                                ),
                              ),
                            ),
                          );
                        });
                  }
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
