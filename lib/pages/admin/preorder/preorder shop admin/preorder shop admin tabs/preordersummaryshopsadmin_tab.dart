import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/my_package.dart';
import 'today.dart';
import 'tommorow.dart';

const myShopsTabs = [
  Tab(
    text: 'Today',
  ),
  Tab(
    text: 'Tommorrow',
  ),
];

class MyShopSummaryContent extends StatefulWidget {
  const MyShopSummaryContent({Key? key}) : super(key: key);

  @override
  State<MyShopSummaryContent> createState() => _MyShopSummaryContentState();
}

class _MyShopSummaryContentState extends State<MyShopSummaryContent>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController =
        TabController(length: myShopsTabs.length, vsync: this);
    return Column(
      children: [
        TabBar(
            controller: tabController,
            labelColor: AppColors.c003FFF_100,
            unselectedLabelColor: AppColors.c333333_100,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 48.sp,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
              color: AppColors.c003FFF_100,
              width: 6.h,
            )),
            tabs: myShopsTabs),
        SizedBox(
          height: 5.h,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              TodayOrders(),
              TommorrowOrders()
            ],
          ),
        ),
      ],
    );
  }

  Future<double> calculateTotalItemQuantity(
      QuerySnapshot productsnapshot, int index, BuildContext context) async {
    double totalitemquantity = 0;

    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('PickupTime',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day)
                .add(const Duration(days: 1))
                .toUtc())
        .where('PickupTime',
            isLessThanOrEqualTo: DateTime(now.year, now.month, now.day)
                .add(const Duration(days: 2))
                .toUtc())
        .get();
    for (final orderDoc in orderSnapshot.docs) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderDoc.id)
          .collection('items')
          .where('item name',
              isEqualTo: productsnapshot.docs[index].get('name'))
          .get();
      for (var itemDoc in querySnapshot.docs) {
        totalitemquantity += itemDoc.get('quantity');
      }
    }

    return totalitemquantity;
  }
}
