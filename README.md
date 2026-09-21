# KaragirSetu V2

**Your craft. Your story. Your marketplace.**

KaragirSetu is a Flutter Android prototype exploring how artisans can turn craft photos and their own descriptions into culturally respectful, buyer-facing product listings, while keeping a simple view of products, orders, and marketplace destinations.

> **Status:** SIH / demonstration prototype. This repository is not a production-ready commerce platform. Review all AI output and do not enter sensitive or real customer data.

## Contents

- [What is included](#what-is-included)
- [Demo access](#demo-access)
- [Build an APK using GitHub Actions](#build-an-apk-using-github-actions)
- [Build locally (optional)](#build-locally-optional)
- [Configure Gemini and Groq](#configure-gemini-and-groq)
- [Prototype boundaries](#prototype-boundaries-and-known-limitations)
- [Project layout](#project-layout)
- [License and third-party notices](#license-and-third-party-notices)

## What is included

- Demo login screen.
- Dashboard, Analytics, Products, Orders, Marketplace, and Settings screens.
- Sample product/order/analytics information for demonstration.
- Product creation/editing with image selection, artisan-supplied details, price, stock/capacity, and lead time.
- AI-assisted listing text generation through Gemini or Groq when you provide your own API key.
- Buyer preview and native share flow.
- Demo marketplace connection switches and simulated publishing states.
- Earth-tone palette: olive `#70823E`, sand `#DFC799`, gold `#E0B44A`, terracotta `#D8853F`, ivory `#F3EDE0`, and earth `#866C5A`.

## Demo access

The login screen is prefilled with this demonstration account:

- **Username:** `BharatPotery@login`
- **Password:** `Bharat2456`

These credentials are hardcoded for demo navigation only. They are **not secure authentication** and must not be reused for real accounts.

## Build an APK using GitHub Actions

You do **not** need to install Flutter on your Windows computer to use this route. The workflow in `.github/workflows/build_apk.yml` sets up Flutter in GitHub-hosted CI, generates the Android project files, and uploads the APK as a downloadable workflow artifact.

1. Create or open your GitHub repository and upload the **contents** of this project folder (including the hidden `.github` folder).
2. Push/commit the files to the `main` branch.
3. Open the repository's **Actions** tab.
4. Select **Build KaragirSetu APK** and choose **Run workflow** (or let the workflow run after a push).
5. Open the completed run. Under **Artifacts**, download `KaragirSetu-APK`.
6. Extract the artifact ZIP to get `app-debug.apk`, then transfer it to your Android phone and install it. You may need to allow installation from that file source.

The workflow builds a **debug APK** for prototyping. GitHub Actions can still fail if an upstream package/API or Android toolchain changes; inspect the failing step's log if that happens.

## Build locally (optional)

Install the Flutter stable SDK and Android Studio/Android SDK first. From this project directory:

```bash
flutter create --platforms=android --project-name karigar_setu --org com.sih.karigarsetu .
flutter pub get
flutter run
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`.

## Configure Gemini and Groq

1. Launch the app and sign in with the demo credentials.
2. Open **Settings → AI configuration**.
3. Paste your own Gemini API key and/or Groq API key and apply it.
4. Go to **Products**, create a product, enter artisan-confirmed details, select a provider, and generate the listing.
5. Review and correct all generated text before sharing.

Keys are held in app memory in this prototype and are not securely persisted. Do not commit API keys to source control or distribute an APK containing your personal key. Provider endpoints and model identifiers can change; update and test the service code if needed.

## Prototype boundaries and known limitations

- **No real user authentication:** the demo login is hardcoded.
- **No persistent backend:** profile/product/order state is primarily in memory and may reset when the app restarts.
- **Illustrative analytics:** sample figures are not real transactions; profit figures are estimates, not accounting records.
- **Marketplace publishing is simulated:** marketplace cards/toggles do not authenticate or publish to GeM, ONDC, Amazon, Flipkart, or any other marketplace. Real integration requires platform approval, seller onboarding, official API access, credentials, and compliance work.
- **No public hosted product page:** the buyer preview is inside the app; sharing uses the available native share flow rather than publishing a permanent web URL.
- **Video upload is not implemented** in this prototype.
- **AI can be wrong:** verify material, origin, cultural, GI-tag, pricing, and production claims. Never allow generated text to invent provenance or certifications.
- **No production security, privacy, backup, payment, or delivery infrastructure** is provided.

## Project layout

```text
lib/
  main.dart                 Main app screens and demo flows
  models/                   Product listing model
  data/                     Sample/demo data and templates
  services/                 AI, pricing, description, and image utilities
  screens/                  Prototype screens
  theme/                    Palette and theme
.github/workflows/
  build_apk.yml             Cloud APK build workflow
```

## License and third-party notices

This project is distributed under the **PolyForm Noncommercial License 1.0.0**. You may use, modify, and redistribute it for permitted noncommercial purposes under that license. **Commercial use, selling the software, or selling copies is not permitted by this license.** Read `LICENSE` for the official license link and notice.

Third-party packages and services retain their own licenses and terms. See `pubspec.yaml` and the providers' terms for details. This project's license does not grant rights to third-party trademarks, marketplace platforms, or AI services.

---

Made for the people behind the craft.
