import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/features/voice_journal/models/voice_journal_models.dart';

class VoiceNoteTile extends StatelessWidget {
  final VoiceNote note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onPlay;

  const VoiceNoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(note.formattedDuration,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(width: 8),
                        if (note.isTranscribed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Transcrit',
                                style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('En attente',
                                style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          '${note.date.day}/${note.date.month}/${note.date.year}',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                        if (note.location != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.location_on, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(note.location!,
                                style: TextStyle(color: AppColors.textHint, fontSize: 12),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                    if (note.transcript != null && note.transcript!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(note.transcript!,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
