import 'package:bookes/resources/auth.dart';
import 'package:bookes/widgets/offerCard.dart';
import 'package:bookes/widgets/requestCard.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;
  final VoidCallback? onConfirm;
  final bool isDestructive;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.cancelColor,
    this.icon,
    this.onConfirm,
    this.isDestructive = false,
  }) : super(key: key);

  // Static method to show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon,
    VoidCallback? onConfirm,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        icon: icon,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (if provided)
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          cancelColor ?? theme.colorScheme.onSurface,
                      side: BorderSide(
                        color: cancelColor ?? theme.colorScheme.onSurface,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 16),

                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm?.call();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ??
                          (isDestructive
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary),
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showLogoutConfirmation(context) async {
  final result = await ConfirmDialog.show(
    context: context,
    title: 'Sign Out',
    message: 'Are you sure you want to sign out of your account?',
    confirmText: 'Sign Out',
    icon: Icons.logout,
    onConfirm: () async {
      await AuthMethods().signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    },
  );
}

void showCancelRequestConfirmation(context, requestId) async {
  final result = await ConfirmDialog.show(
    context: context,
    title: 'Cancel Request',
    message:
        'Would you like to cancel this book request? You will be able to get offers for this request .',
    confirmText: 'Accept',
    icon: Icons.check_circle_outline,
    confirmColor: Colors.green,
  );

  if (result == true) {
    RequestService.cancelRequest(context, requestId);
  }
}

void showAcceptOfferConfirmation(
    context, String response, offerId, offer) async {
  final acceptMessage =
      'Would you like to accept this book offer? You will be able to chat with the lender after accepting.';
  final declineMessage =
      'Would you like to decline this book offer? You will not be able to chat with the lender after declined.';
  final result = await ConfirmDialog.show(
    context: context,
    title: response == 'accepted' ? 'Accept Offer' : 'Cancel offer',
    message: response == 'accepted' ?acceptMessage : declineMessage,
    confirmText: response == 'accepted' ? 'Accept' : 'Decline',
    icon: response == 'accepted'
        ? Icons.check_circle_outline
        : Icons.cancel_outlined,
    confirmColor: response == 'accepted' ? Colors.green : Colors.red,
  );

  if (result == true) {
    OfferRequestService.respondToOffer(context, response, offerId, offer);
  }
}
