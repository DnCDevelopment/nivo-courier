import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nivocourier/widgets/Order/order.dart';

import 'package:nivocourier/models/auth.dart';

import 'package:nivocourier/utils/getDocument.dart';

class Orders extends StatelessWidget {
  final _db = Firestore.instance;
  final BaseAuth auth = Auth();

  Widget _getOrders(BuildContext context, List<DocumentSnapshot> orders) {
    return Column(
      children: orders
          .map((order) => GestureDetector(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '№' + order['number'],
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot>(
                            stream: getDocument(order['restaurant']),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data != null
                                    ? snapshot.data['name']
                                    : '',
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              );
                            }),
                      ],
                    )),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Order(order.documentID),
                    ),
                  );
                },
              ))
          .toList(),
    );
  }

  Future<Stream<QuerySnapshot>> _hasOrder() {
    return auth
        .getCurrentUser()
        .then((user) => _db
            .collection('orders')
            .where("status", whereIn: ['food prepare', 'deliver'])
            .where("courier", isEqualTo: user.uid)
            .snapshots())
        .catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    _hasOrder();
    return Scaffold(
        body: SingleChildScrollView(
      child: FutureBuilder<Stream<QuerySnapshot>>(
        future: _hasOrder(),
        builder: (context, orders) {
          return StreamBuilder<QuerySnapshot>(
            stream: orders.data,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              if (snapshot.data.documents.length == 0) {
                return StreamBuilder<QuerySnapshot>(
                  stream: _db
                      .collection('orders')
                      .where('status', isEqualTo: 'waiting')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return _getOrders(context, snapshot.data.documents);
                  },
                );
              }
              return _getOrders(context, snapshot.data.documents);
            },
          );
        },
      ),
    ));
  }
}
