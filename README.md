# 🤖 Reddit AI Summarizer

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Reddit AI Summarizer** is a premium Flutter application that turns long, noisy Reddit threads into clear, actionable AI-generated summaries. Built with high-end aesthetics and cross-platform support in mind.

---

## ✨ Features

- 📝 **Smart Summarization**: Get the gist of any Reddit post and its comments in seconds.
- 🎨 **Premium UI/UX**: Beautiful, modern interface using **Google Fonts (Outfit & Inter)** and **Material 3**.
- 🌐 **Web Ready**: Full support for Flutter Web with built-in **CORS proxying**.
- 📄 **Markdown Rendering**: Rich text display for AI summaries and formatted prompts.
- 🌗 **Dark Mode**: Seamless transition between light and dark themes.
- 🔐 **Secure Configuration**: Inject your AI API key securely via environment variables.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.22.0 or higher recommended)
- An API Key from your preferred AI provider.

### Running the App

To run the app locally on your machine or in the browser, use the following command:

#### 🌐 Web
```bash
flutter run -d chrome --dart-define=AI_API_KEY=your_api_key_here
```

#### 📱 Mobile
```bash
flutter run --dart-define=AI_API_KEY=your_api_key_here
```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts)
- **Markdown**: [flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus)
- **Error Handling**: [fpdart](https://pub.dev/packages/fpdart)

---

## 📂 Project Structure

```text
lib/
├── core/           # Theme, Networking, Models, Storage
├── features/       # Feature-based organization
│   ├── input/      # Landing page & URL handling
│   └── output/     # AI results & Markdown display
└── router/         # GoRouter configuration
```

---

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  Made with ❤️ by the Reddit AI Summarizer Team
</p>
