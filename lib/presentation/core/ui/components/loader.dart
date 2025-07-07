
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class InfiniteLoader extends StatelessWidget {
  const InfiniteLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.progressiveDots(
        color: Theme.of(context).colorScheme.primary,
        size: 70,
      ),
    );
  }
}


