// // --- Widget for the tab buttons ---
// import 'package:flutter/material.dart';
// import 'package:komunika/app/themes/app_colors.dart';

// class BuildTabSelector extends StatefulWidget {
//   const BuildTabSelector({
//     required tabTitles,
//     required selectedTabIndex,
//     required notificationCount,
//     super.key,
//   }) : _tabTitles = tabTitles,
//        _selectedTabIndex = selectedTabIndex,
//        _notificationCount = notificationCount;
//   final List<String> _tabTitles;
//   final int _selectedTabIndex;
//   final ValueNotifier<int> _notificationCount;
//   @override
//   State<BuildTabSelector> createState() => _BuildTabSelectorState();
// }

// class _BuildTabSelectorState extends State<BuildTabSelector> {
//   late int
//   _currentActiveTabIndex; // State variable to hold the currently selected tab

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the current active tab index with the initial value from the widget
//     _currentActiveTabIndex = widget._selectedTabIndex;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Row(
//         children:
//             List.generate(widget._tabTitles.length, (index) {
//                   bool isSelected = widget._selectedTabIndex == index;
//                   return Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           // widget._selectedTabIndex = index;
//                           _currentActiveTabIndex = index;
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12.0),
//                         decoration: BoxDecoration(
//                           color:
//                               isSelected
//                                   ? AppColors.bittersweet
//                                   : AppColors.deluge.withAlpha(180),
//                           borderRadius: BorderRadius.circular(
//                             10,
//                           ), // Figma-like rounding
//                         ),
//                         alignment: Alignment.center,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               widget._tabTitles[index],
//                               style: TextStyle(
//                                 color: AppColors.white,
//                                 fontWeight:
//                                     isSelected
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             if (index == 1) // If it's the Notifications tab
//                               ValueListenableBuilder<int>(
//                                 valueListenable: widget._notificationCount,
//                                 builder: (context, count, child) {
//                                   if (count > 0) {
//                                     return Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: CircleAvatar(
//                                         radius: 11,
//                                         backgroundColor: AppColors.white,
//                                         child: CircleAvatar(
//                                           radius: 9,
//                                           backgroundColor:
//                                               isSelected
//                                                   ? AppColors.white
//                                                   : AppColors.paleCarmine,
//                                           child: Text(
//                                             count.toString(),
//                                             style: TextStyle(
//                                               color:
//                                                   isSelected
//                                                       ? AppColors.bittersweet
//                                                       : AppColors.white,
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                   return const SizedBox.shrink();
//                                 },
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 })
//                 .expand(
//                   (w) => [
//                     w,
//                     if (w !=
//                         (List.generate(
//                           widget._tabTitles.length,
//                           (index) => w,
//                         )).last)
//                       const SizedBox(width: 10),
//                   ],
//                 )
//                 .toList(),
//       ),
//     );
//   }
// }
