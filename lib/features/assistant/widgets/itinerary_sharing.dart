import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trtravel/features/assistant/models/assistant_models.dart';

class ItinerarySharing {
  static void sharePlan(BuildContext context, TripPlan plan) {
    final buffer = StringBuffer();
    buffer.writeln('\u{1F5FA}\u{FE0F} ${plan.title}');
    buffer.writeln('\u{1F4CD} ${plan.city} \u{2022} ${plan.duration} jours');
    buffer.writeln('\u{1F4B0} Budget: ${plan.estimatedBudget}');
    buffer.writeln('');

    for (final day in plan.days) {
      buffer.writeln('${'=' * 25}');
      buffer.writeln('\u{1F4C5} Jour ${day.dayNumber} : ${day.theme}');
      buffer.writeln('${'=' * 25}');
      for (final activity in day.activities) {
        buffer.writeln('  \u{2705} $activity');
      }
      buffer.writeln('\u{1F37D}\u{FE0F} ${day.mealSuggestion}');
      buffer.writeln('\u{1F4B0} Coût: ${day.estimatedCost}');
      buffer.writeln('');
    }

    buffer.writeln('');
    buffer.writeln('Planifié avec TrTravel - Votre compagnon de voyage en Turquie');

    Share.share(buffer.toString(), subject: plan.title);
  }

  static void shareText(BuildContext context, String text, {String? subject}) {
    Share.share(text, subject: subject ?? 'TrTravel');
  }
}

class ShareButton extends StatelessWidget {
  final String? text;
  final TripPlan? plan;
  final double? size;

  const ShareButton({super.key, this.text, this.plan, this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share_rounded, size: size ?? 24),
      tooltip: 'Partager',
      onPressed: () {
        if (plan != null) {
          ItinerarySharing.sharePlan(context, plan!);
        } else if (text != null) {
          ItinerarySharing.shareText(context, text!);
        }
      },
    );
  }
}
