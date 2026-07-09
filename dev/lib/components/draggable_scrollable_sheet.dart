import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BDraggableScrollableSheet extends StatelessWidget {
  final Widget content;
  final bool scrollViewRequired;
  const BDraggableScrollableSheet({
    super.key,
    required this.scrollViewRequired,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: scrollViewRequired
              ? SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: content,
                )
              : content,
        );
      },
    );
  }
}
