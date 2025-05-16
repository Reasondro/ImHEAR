# ImHEAR

## 📢 Vision

ImHEAR is an innovative communication platform designed to empower individuals with speech and hearing difficulties. It provides a seamless and inclusive way for them to interact and seek assistance in public spaces such as transportation hubs, stations, cafes, hospitals, and other service points.

The core mission is to bridge communication gaps by leveraging real-time location services, intuitive messaging, AI-powered understanding, and haptic feedback via a custom wearable device.

## ✨ Key Features

* **Role-Based Access:** Distinct interfaces and functionalities for:
    * **Mimi's Friend (Deaf Users):** Find nearby help, initiate chats, receive AI-assisted communication aids.
    * **Mimi's Helper (Official Staff):** Broadcast availability for specific "Sub Spaces" (service points), manage and respond to incoming chats from Deaf Users.
    * **Mimi's Admin (Organization Admins):** Manage their organization's profile, define Sub Spaces, and (eventually) manage Official Staff accounts. (Admin UI for this is planned).
* **Real-time Location & Nearby Service Discovery:**
    * Deaf users can see actively staffed Sub Spaces (service points) near their current location.
    * Officials broadcast their location and the Sub Space they are currently serving.
* **Direct 1-on-1 Chat:**
    * Deaf users can initiate a direct text-based chat with an active Sub Space.
    * Officials receive and respond to these chats within the context of the Sub Space they are managing.
    * Real-time messaging powered by Supabase.
* **HearAI - AI-Powered Assistance (for Deaf User):**
    * **Live Captioning & Analysis:** Captures audio via the phone's microphone.
    * Uses Google's Gemini API for Speech-to-Text and analysis of emotional tone/urgency or environmental sounds.
    * Displays transcribed text and analysis category.
    * **Continuous Listening Mode:** Option to have HearAI continuously record and process audio in chunks.
* **Wearable Device Integration (ESP32 Wristband):**
    * Connects to a custom ESP32-C3 based wristband via Bluetooth Low Energy (BLE).
    * Provides haptic feedback (vibrations) based on in-app events (e.g., new chat message, HearAI sound category).
    * (Conceptual) Display for simple visual cues.
* **User Authentication & Onboarding:**
    * Welcome screen, role selection, secure sign-up and sign-in for different user roles.
    * Auth state management with redirection.
* **Profile Management:** Basic profile viewing and sign-out.
* **Device Management Screen:** UI for scanning, connecting, and interacting with the BLE wristband.

## 🛠️ Tech Stack

* **Frontend (Mobile App):**
    * Flutter (Cross-platform UI framework)
    * State Management: BLoC (specifically Cubit)
    * Routing: GoRouter
    * Key Packages:
        * `flutter_bloc` (for state management)
        * `go_router` (for routing capabilities)
        * `supabase_flutter` (for backend service capabilities)
        * `record` (for audio capture)
        * `google_generative_ai` (for Gemini API interaction)
        * `flutter_blue_plus` (for Bluetooth Low Energy)
        * `permission_handler`
        * `intl` (for formatting)
        * `lottie` (for animations)
        * `equatable`
        * `flutter_dotenv`
* **Backend:**
    * Supabase:
        * Authentication
        * PostgreSQL Database (with PostGIS extension for geospatial queries)
        * Realtime (for chat and other live updates)
        * Storage (planned for profile pictures, etc.)
        * RPC Functions (PostgreSQL functions for custom backend logic)
* **AI:**
    * Google Gemini API (via Google AI Studio key for prototype)
* **Hardware (Wearable Prototype):**
    * ESP32-C3 Super Mini
    * Vibration Motor
    * LED Display

## 📂 Project Structure

The project follows a feature-first directory structure, with clear separation of data, domain, and presentation layers within each feature.
