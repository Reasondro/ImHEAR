import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/app.dart';
import 'package:komunika/app/routing/routing_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_PROJECT_URL"]!,
    anonKey: dotenv.env["SUPABASE_API_KEY"]!,
  );
  GoRouter router = RoutingService().router;
  runApp(App(router: router));

  // runApp(MyApp(router: router));
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key, required this.router});
//   final GoRouter router;

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // initialize();
//   }

//   // void initialize() async {
//   //   await Future.delayed(const Duration(milliseconds: 650));
//   //   FlutterNativeSplash.remove();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // SystemChrome.setPreferredOrientations(
//     //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       title: 'ImHear',
//       theme: imHearLightTheme,
//       routerConfig: widget.router,
//     );
//   }
// }


// TODO LIST


//! 3. Key Considerations & Next Steps:

// ? DONE    Permissions: geolocator provides methods like checkPermission, requestPermission. Handle denied/permanently denied cases gracefully in UserLocationBloc. Explain clearly why location is needed.

//? DONE     Accuracy vs. Battery: Configure geolocator's LocationSettings (accuracy, distanceFilter) carefully, especially for the Official broadcasting. High accuracy drains battery faster. distanceFilter prevents updates if the user hasn't moved significantly.

// ? not yet     Background Location (Officials): If Officials need to broadcast while the app is not in the foreground, this adds significant complexity. You'll need background execution capabilities (geolocator has some, but platform restrictions are strict, especially iOS), foreground services (Android), and "Always Allow" location permission. Start without background first.

// ? SEMI DONE    Throttling/Debouncing: Absolutely critical for NearbyOfficialsBloc RPC calls and recommended for OfficialBroadcastingBloc database updates. Prevents spamming your backend.

// ? SEMI DONE    Error Handling: Implement robust error handling in BLoCs and UI (network issues, DB errors, permission errors).

//? SEMI DONE     State Management: Ensure BLoCs are provided correctly and UI widgets rebuild efficiently based on state changes.

//* NOT YET     Chat Room Joining: Once a Deaf user taps a nearby official in the list, you'll need logic to navigate to a chat screen, passing the official_location_id or official_user_id to identify the correct chat context. This will involve a separate ChatBloc/feature.

//* fuck this     Testing: Write unit tests for BLoCs and integration tests for repository/provider interactions.
// * CHAT APP TUTOR
// * DATABSE DESGIN???
// * BLUETOOTH CONNNECTION



// TODO NEW TODO LIST

// Ah, okay! Thank you for adding that crucial context. Knowing that hardware integration is a main objective and scores highly in the competition definitely changes the prioritization. My previous recommendation focused on software completeness, but competition goals are paramount.

// Given this, let's adjust the plan to prioritize demonstrating the Bluetooth/ESP32 link earlier, while still making logical progress. Here’s a revised suggested order:

//     Step 1: Minimum Viable Official Response Path:
//         Goal: Create the absolute simplest way for some message to be sent back as if from an official, which can later trigger the wristband.
//         Action: You don't need the full Official UI yet. You could:
//             Implement the sendMessage part of the SupabaseChatRepository (already done).
//             Create a temporary "Send Reply" button within the Deaf User's ChatScreen (just for testing!) that calls sendMessage, maybe hardcoding the senderId to be the official user's ID you created earlier.
//             OR, even simpler, use the Supabase Studio (database table editor) to manually insert a new message into the messages table for the relevant room_id, setting the sender_id to your test official's ID.
//         Reasoning: This gives you a way to trigger the "message received" event in the app's ChatCubit stream without building the full official UI right now.

//     Step 2: Basic Bluetooth (BLE) Integration & Wristband Trigger:
//         Goal: Prove the core hardware connection and a simple reaction.
//         Action:
//             Set up your ESP32 project to act as a BLE peripheral.
//             Use a Flutter BLE package (like flutter_blue_plus or flutter_reactive_ble) in your Flutter app to scan for and connect to the ESP32.
//             Define a very simple BLE characteristic or service. For example, the app writes a value (1 for vibrate, 2 for display icon X) to a characteristic on the ESP32.
//             Modify the ChatCubit or the ChatScreen's BlocListener listening to the message stream: When a new message arrives (and isMe is false), send the "vibrate" command over BLE to the connected ESP32.
//             Get the ESP32 to react (vibrate the motor, light up an LED, display something basic).
//         Reasoning: This directly tackles the high-priority hardware objective. Getting a simple end-to-end "message received -> BLE command -> wristband vibrates" flow working early is a huge win for the competition aspect.

//     Step 3: Integrate Simple Mandatory AI Feature:
//         Goal: Fulfill the competition requirement with a functional, demonstrable AI integration.
//         Action: Choose the simplest viable AI feature first. A basic FAQ chatbot accessible from a button, or simple pre-defined response suggestions based on keywords, might be faster to implement than complex context-aware features. Integrate the Gemini/Gemma API call.
//         Reasoning: Checks off the mandatory AI requirement without getting bogged down in complex AI logic before the hardware link is proven.

//     Step 4: Build Out Core UI & Remaining Functionality:
//         Goal: Make the app fully functional and presentable.
//         Action: Now, circle back to fully implementing Option 1 from before:
//             Build the proper Official User UI based on Figma (logging in, seeing assigned sub spaces, viewing chat lists, sending replies properly). Replace the temporary message sending mechanism from Step 1.
//             Build the Org Admin UI for managing sub spaces (like your Figma settings page).
//             Implement GoRouter and navigation shells as planned.
//             Polish the overall UI/UX.
//             Enhance the AI feature if time permits.
//             Refine the hardware interaction with more specific commands/displays.

// Why this revised order?

// This prioritizes tackling the highest impact competition requirements (Hardware Integration, Mandatory AI) earlier, ensuring you have something demonstrable for those key areas. Step 1 provides the minimum linkage needed to test Step 2 effectively. Step 4 then fleshes out the complete application once the core differentiators are addressed.

// Does this revised plan, focusing on getting a basic hardware interaction working sooner, feel like a better approach given the competition's emphasis?





