# Dr. Crop – Plant Disease Diagnosis App

**Dr. Crop** is a Flutter mobile application that helps users diagnose plant diseases by analyzing images of leaves. It uses a TensorFlow Lite model for on-device classification and provides detailed information about the identified condition, including causes, symptoms, treatments, and prevention methods. User authentication is securely managed through Firebase with Google Sign-In.

---

## Features

- **Google Sign-In** with Firebase Authentication
- Capture or upload leaf images via camera/gallery
- On-device disease classification using **TensorFlow Lite**
- Instant diagnosis with name of the disease
- Detailed solutions: causes, symptoms, treatment, prevention
- User profile with name, email, and profile photo
- Smooth workflow: **Upload → Diagnose → Solution**

---

## Screenshots

> *(Recommended: Add real app screenshots here)*

| Login | Home | Image Upload | Diagnosis |
| :---: | :--: | :----------: | :--------: |
| ![Login](assets/login.png) | ![Home](assets/home.png) | ![Upload](assets/upload.png) | ![Result](assets/result.png) |

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **ML Model:** TensorFlow Lite (`tflite_flutter`)
- **Auth:** Firebase Authentication + Google Sign-In
- **Image Processing:** `image_picker`, `image`
- **State Management:** `setState` (native Flutter)

---

## Model Overview

- **File:** `lib/assets/tflite_model.tflite`
- **Input:** 256×256 RGB image normalized to [0, 1]
- **Output:** Probability scores for 88 classes
- **Classes Covered:** Diseases across 20+ crops (e.g., Apple, Tomato, Mango, Rice, Tea, Wheat)

See `_classnames` in `pages/home_page.dart` for the full list.

---

## Workflow Overview

1. **Login** using Google via Firebase
2. **Image selection** via camera/gallery
3. **Image preprocessing:** resize, normalize, reshape
4. **TFLite inference** (offline, on-device)
5. **Postprocessing:** highest probability → predicted class
6. **Display results** with:
   - Image preview
   - Predicted disease name
   - Dynamic solution (from `plantDiseaseSolutions`)

---

## Setup Instructions

### 1. Prerequisites

- Flutter SDK installed
- Firebase project created
- VS Code / Android Studio with Flutter plugins

### 2. Clone the Repository

```bash
git clone https://github.com/shanker-18/drcrop.git
cd drcrop/Dr.Crop
