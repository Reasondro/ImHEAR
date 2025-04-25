import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:komunika/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_PROJECT_URL"]!,
    anonKey: dotenv.env["SUPABASE_API_KEY"]!,
  );
  runApp(App());
}


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