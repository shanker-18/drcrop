# Dr. Crop - Plant Disease Diagnosis App

Dr. Crop is a Flutter mobile application designed to help users diagnose diseases in their crops by analyzing images of plant leaves. The app utilizes a TensorFlow Lite model for on-device classification and provides potential causes, symptoms, treatments, and prevention methods for the identified condition. User authentication is handled via Firebase Authentication with Google Sign-In.

## Features

*   **User Authentication:** Secure login/signup using Google Sign-In via Firebase Authentication.
*   **Image Input:** Capture images using the device camera or upload from the gallery.
*   **Plant Disease Detection:** Utilizes an embedded TensorFlow Lite model to classify plant leaf images into one of 88 categories (various plant diseases or healthy states).
*   **On-Device Inference:** The TFLite model runs directly on the user's device, ensuring privacy and offline capability for the core diagnosis feature (once the model is loaded).
*   **Diagnosis Results:** Displays the predicted disease name.
*   **Solution Guidance:** Provides detailed information including potential causes, symptoms, treatment options, and prevention strategies for the detected disease.
*   **User Profile:** Displays the logged-in user's profile picture (from Google Account), name, and email.
*   **Simple Workflow:** Easy-to-follow process: Upload/Capture -> Diagnose -> Get Solution.

## Screenshots

*(It's highly recommended to add actual screenshots of your app here)*

| Login Screen        | Home Screen (Initial) | Image Selected       | Diagnosis Result      |
| :------------------: | :-------------------: | :------------------: | :-------------------: |
| [Placeholder Image] | [Placeholder Image]  | [Placeholder Image] | [Placeholder Image]  |
|                     |                      |                     |                      |

## Technology Stack

*   **Framework:** Flutter
*   **Language:** Dart
*   **Machine Learning:** TensorFlow Lite (`tflite_flutter`)
*   **Authentication:** Firebase Authentication, Google Sign-In (`firebase_auth`, `google_sign_in`)
*   **Image Handling:** Image Picker (`image_picker`), Image Processing (`image`)
*   **State Management:** `setState` (built-in Flutter state management)

## Model Information

*   **Model:** A pre-trained TensorFlow Lite model (`tflite_model.tflite`).
*   **Location:** `lib/assets/tflite_model.tflite`
*   **Input:** 256x256 RGB image, pixel values normalized to [0, 1].
*   **Output:** An array of probabilities corresponding to 88 different plant disease/healthy classes.
*   **Classes:** The model is trained to identify 88 conditions across a wide range of plants including Apple, Cassava, Cherry, Chili, Coffee, Corn, Cucumber, Guava, Grape, Jamun, Lemon, Mango, Peach, Pepper, Pomegranate, Potato, Rice, Soybean, Strawberry, Sugarcane, Tea, Tomato, and Wheat. The full list of class names can be found in the `_classnames` list within `pages/home_page.dart`.

## How It Works

1.  **Authentication:** The user logs in using their Google Account. Firebase Authentication verifies the user.
2.  **Image Selection:** The user either takes a new picture using the camera or selects an existing image from their gallery.
3.  **Preprocessing:** The selected image is:
    *   Decoded.
    *   Resized to 256x256 pixels.
    *   Normalized (pixel values converted to the range [0, 1]).
    *   Formatted into the tensor shape expected by the TFLite model.
4.  **Inference:** The preprocessed image data is fed into the loaded TFLite interpreter (`_interpreter`).
5.  **Postprocessing:**
    *   The model outputs an array of probabilities for each of the 88 classes.
    *   The app identifies the class index with the highest probability.
    *   The corresponding class name (disease/healthy) is retrieved from the `_classnames` list.
6.  **Display Results:**
    *   The selected image is displayed.
    *   The predicted disease name is shown.
    *   A detailed solution/description corresponding to the predicted class is retrieved from the `plantDiseaseSolutions` map and displayed.
7.  **Reset/Cancel:** The user can cancel the selected image before diagnosis or reset the view after diagnosis to analyze another image.
8.  **Logout:** The user can sign out, clearing their session.

## Setup and Installation

1.  **Prerequisites:**
    *   Flutter SDK installed.
    *   An IDE like VS Code or Android Studio with Flutter plugins.
    *   A Firebase project set up.

2.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    cd dr_crop_project_directory
    ```

3.  **Firebase Setup:**
    *   Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
    *   Add an Android and/or iOS app to your Firebase project. Follow the on-screen instructions.
    *   **Enable Authentication:** Go to the Authentication section, select the "Sign-in method" tab, and enable "Google" as a sign-in provider. Make sure to provide the necessary SHA-1 (for Android) or other configuration details as prompted.
    *   **Download Configuration Files:**
        *   **Android:** Download the `google-services.json` file and place it in the `android/app/` directory.
        *   **iOS:** Download the `GoogleService-Info.plist` file and place it in the `ios/Runner/` directory using Xcode.
    *   Ensure your `android/app/build.gradle` and `android/build.gradle` files have the necessary Google Services dependencies, as guided by the Firebase setup process.

4.  **Place Assets:**
    *   Make sure the TFLite model file `tflite_model.tflite` is placed inside the `lib/assets/` directory. Create this directory if it doesn't exist.
    *   Ensure you have the logo (`logo.png`), process image (`process.png`), and default avatar (`default_avatar.png`) in `lib/assets/`.
    *   Verify that your `pubspec.yaml` file includes the assets directory:
        ```yaml
        flutter:
          uses-material-design: true
          assets:
            - lib/assets/
        ```

5.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

6.  **Run the App:**
    ```bash
    flutter run
    ```

## Future Enhancements (Suggestions)

*   Store diagnosis history for logged-in users (using Firestore).
*   Allow users to provide feedback on diagnosis accuracy.
*   Integrate location services to suggest region-specific advice.
*   Improve the model or allow for model updates.
*   Add support for more plant types and diseases.
*   Implement offline storage for solutions.
*   Localization for different languages.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues to improve the app.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the [Specify License, e.g., MIT] License. See `LICENSE` file for more information (if applicable).
