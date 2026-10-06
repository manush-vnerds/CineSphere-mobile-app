import 'package:flutter/material.dart';

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  SearchBarHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 92;

  @override
  double get maxExtent => 92;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF0A1424),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(SearchBarHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
