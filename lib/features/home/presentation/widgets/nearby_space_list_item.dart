import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';

class NearbySpaceListItem extends StatelessWidget {
  final NearbyOfficial official;
  final VoidCallback onTap;

  const NearbySpaceListItem({
    required this.official,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: AppColors.haiti,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      official.locationName,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.lavender,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (official.officialFullName.isNotEmpty)
                      Text(
                        "by ${official.officialFullName}",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.lavender,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Text(
                      "${official.distanceMeters.toStringAsFixed(0)}m away",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.columbiaBlue,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bittersweet,
                  foregroundColor: AppColors.haiti,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  "Enter",
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
