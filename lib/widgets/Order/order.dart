import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nivocourier/widgets/StreamState/streamstate.dart';

import 'package:nivocourier/models/auth.dart';

import 'package:nivocourier/utils/getDocument.dart';

const STATUS = ['waiting', 'food prepare', 'deliver', 'done'];

class Order extends StatelessWidget {
  final String _id;
  final _db = Firestore.instance;
  final BaseAuth auth = Auth();

  Order(this._id);

  Future<int> _getPrice(List<dynamic> dishes) async {
    int total = 0;
    for (int i = 0; i < dishes.length; i++) {
      final dish = await dishes[i].get();
      final price =
          int.parse(dish['price'].substring(0, dish['price'].length - 5));
      total += price;
    }
    return total;
  }

  void _handleUpdate(String status) async {
    final _status = STATUS.indexOf(status);
    final _user = await auth.getCurrentUser();
    _db.collection('orders').document(_id).updateData({
      "status": STATUS[_status + 1],
      "courier": _user.uid,
    });
  }

  Widget _getDishes(BuildContext context, List<dynamic> dishes) {
    return Column(
        children: dishes
            .map(
              (dish) => GestureDetector(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: getDocument(dish),
                  builder: (context, snapshot) {
                    return StreamState(
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                    snapshot.data != null
                                        ? snapshot.data['name']
                                        : '',
                                    style: TextStyle(
                                      fontSize: 24,
                                    )),
                              ),
                              Expanded(
                                child: Text(
                                    snapshot.data != null
                                        ? snapshot.data['price']
                                        : '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                    )),
                              )
                            ],
                          ),
                        ),
                        snapshot);
                  },
                ),
              ),
            )
            .toList());
  }

  Widget _getButton(
      AsyncSnapshot<DocumentSnapshot> snapshot, BuildContext context) {
    if (snapshot.data != null && snapshot.data['status'] != 'done') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            height: 40.0,
            minWidth: MediaQuery.of(context).size.width - 20,
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text(
                snapshot.data != null
                    ? snapshot.data['status'] == 'waiting'
                        ? 'Take the order'
                        : 'Update status'
                    : '',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                )),
            onPressed: () => _handleUpdate(
                snapshot.data != null ? snapshot.data['status'] : ''),
            splashColor: Colors.redAccent,
          )
        ],
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('orders').document(_id).snapshots(),
            builder: (context, snapshot) {
              return StreamState(
                  Text(snapshot.data != null
                      ? '№' + snapshot.data['number']
                      : ''),
                  snapshot);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('orders').document(_id).snapshots(),
            builder: (context, snapshot) {
              return StreamState(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _getDishes(context,
                          snapshot.data != null ? snapshot.data['dishes'] : []),
                      Container(
                        child: FutureBuilder(
                          future: _getPrice(snapshot.data != null
                              ? snapshot.data['dishes']
                              : []),
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            return Text(snapshot.data.toString() + ' грн.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 28,
                                ));
                          },
                        ),
                        margin: EdgeInsets.only(left: 10, top: 10),
                      ),
                      Container(
                        child: StreamState(
                            Text(
                                snapshot.data != null
                                    ? snapshot.data['status']
                                    : '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                )),
                            snapshot),
                        margin: EdgeInsets.only(left: 10, top: 20),
                      ),
                      Container(
                        child: _getButton(snapshot, context),
                        margin: EdgeInsets.only(top: 20),
                      )
                    ],
                  ),
                  snapshot);
            },
          ),
        ));
  }
}
