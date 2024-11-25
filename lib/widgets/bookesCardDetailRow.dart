import 'package:flutter/material.dart';

Widget buildDetailRow(
  IconData icon,
  String text, {
  Color? color,
  double iconSize = 16,
  double fontSize = 14,
}) {
  return Row(
    children: [
      Icon(
        icon,
        size: iconSize,
        color: color ?? Colors.grey[600],
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
