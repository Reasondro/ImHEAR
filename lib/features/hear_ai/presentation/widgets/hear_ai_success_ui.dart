import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:komunika/app/themes/app_colors.dart';
// import 'package:komunika/features/hear_ai/domain/entities/hear_ai_result.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_idle_ui.dart';

// TODO: clean up / rework sucess ui as its currently just a duplicate for idle ui
class HearAiSuccessUi extends StatelessWidget {
  // final List<HearAiResult> resultsHistory;
  // final HearAiResult latestResult;
  final VoidCallback onStartNextRecording;
  final bool isContinuousMode;

  const HearAiSuccessUi({
    // required this.resultsHistory,
    // required this.latestResult,
    required this.onStartNextRecording,
    required this.isContinuousMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HearAiIdleUi(
          onTap: onStartNextRecording,
          permissionNeeded: false,
          // ? override the buttonText here
        ),
        // const SizedBox(height: 7),
      ],
    );
  }
}
