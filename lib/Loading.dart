import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink)
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Loading...',
        ),
      ],
    ),
  );
}
