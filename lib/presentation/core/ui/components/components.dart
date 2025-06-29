
import 'package:flutter/material.dart';

class InfiniteLoader extends StatelessWidget {
  const InfiniteLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
