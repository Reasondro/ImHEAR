import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';

class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    required this.roleName,
    required this.roleDescription,
    required this.imageAssetPath,
    required this.onTap,
    super.key,
  });
  final String roleName;
  final String roleDescription;
  final String imageAssetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.deluge, width: 5),
          // color: AppColors.deluge.withAlpha(204),
          color: AppColors.deluge.withAlpha(100),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                spacing: 6,
                // mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleName,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      color: AppColors.columbiaBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // SizedBox(height: 12),
                  Text(
                    textAlign: TextAlign.justify,
                    roleDescription,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // TODO: Image placeholder - replace with actual Image.asset
            Image.asset(
              imageAssetPath,
              height: 120,
              width: 130,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.lavender,
                  ), // Fallback
            ),
          ],
        ),
      ),
    );
  }
}
