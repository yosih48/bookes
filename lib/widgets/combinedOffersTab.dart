import 'package:bookes/screens/profile.dart';
import 'package:bookes/widgets/offersTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CombinedOffersTab extends StatefulWidget {
  final String userId;

  const CombinedOffersTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<CombinedOffersTab> createState() => _CombinedOffersTabState();
}

class _CombinedOffersTabState extends State<CombinedOffersTab> {
  bool showReceivedOffers = true;

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
                  onTap: () => setState(() => showReceivedOffers = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: showReceivedOffers
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.received,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: showReceivedOffers ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => showReceivedOffers = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !showReceivedOffers
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.myOffers,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !showReceivedOffers ? Colors.white : Colors.grey,
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
          child: showReceivedOffers
              ? OffersTab(userId: widget.userId)
              : MyOffersTab(userId: widget.userId),
        ),
      ],
    );
  }
}
