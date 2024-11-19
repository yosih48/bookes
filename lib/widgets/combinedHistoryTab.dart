import 'package:bookes/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CombinedHistoryTab extends StatefulWidget {
  final String userId;

  const CombinedHistoryTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<CombinedHistoryTab> createState() => _CombinedHistoryTabState();
}

class _CombinedHistoryTabState extends State<CombinedHistoryTab> {
  bool showBorrowedBooks = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => showBorrowedBooks = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: showBorrowedBooks
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                     AppLocalizations.of(context)!.borrowedBooks,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: showBorrowedBooks ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => showBorrowedBooks = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !showBorrowedBooks
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                     AppLocalizations.of(context)!.lentBooks,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !showBorrowedBooks ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: showBorrowedBooks
              ? HistoryTab(userId: widget.userId)
              : MyHistoryTab(userId: widget.userId),
        ),
      ],
    );
  }
}
