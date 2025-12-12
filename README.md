# OhMyShelly

A **simpler alternative** to the official Shelly app for monitoring your smart home devices.

Unlike the configuration-heavy official app, OhMyShelly focuses on what matters most: **big, readable widgets** that show your data at a glance. Technical details stay hidden until you need them — toggle them on when you want more control, or keep things clean and simple.

[![Download](https://img.shields.io/github/v/release/dz0ny/ohmyshelly?label=Download&style=for-the-badge)](https://github.com/dz0ny/ohmyshelly/releases)

---

## Downloads

📱 **[Download Latest Release](https://github.com/dz0ny/ohmyshelly/releases)**

- **Android**: Download the `.apk` file from [releases](https://github.com/dz0ny/ohmyshelly/releases)
- **iOS**: Join the [TestFlight Beta](https://testflight.apple.com/join/FZa9eAv6)

---

## Screenshots

<p align="center">
<img width="240" src="https://github.com/user-attachments/assets/837594bd-675f-4200-ab10-9a37e917f74a" />
<img width="240" src="https://github.com/user-attachments/assets/7817d248-6f35-4c94-b37c-f90925220a1a" />
<img width="240" src="https://github.com/user-attachments/assets/1c8fd6b0-ceb8-438f-bc4b-63fae89b52dd" />
<img width="240" src="https://github.com/user-attachments/assets/031e90ad-faec-4e41-a2ff-4752de40bf18" />
<img width="240" src="https://github.com/user-attachments/assets/5b66f475-e0ff-47af-85a1-dd28bd4eb18c" />
<img width="240" src="https://github.com/user-attachments/assets/73b9dc9d-a942-4878-9be6-3f859a8f7eea" />
<img width="240" src="https://github.com/user-attachments/assets/151637fc-4947-4f68-876f-31468284e95a" />
<img width="240" src="https://github.com/user-attachments/assets/a6c8bcef-37d2-48e1-b853-eac2f6c1a93e" />
</p>

---

## Features

- 📊 **Big, readable widgets** — see your data at a glance
- 🙈 **Clutter-free** — technical details hidden until you need them
- 🎚️ **Toggles & scenes** — reveal advanced controls when you want them
- 🔐 Shelly Cloud authentication
- ⚡ Power consumption statistics
- 🌤️ Weather station charts
- 🔄 Auto-refresh + pull-to-refresh
- 🎨 Material 3 UI
- 📱 Android & iOS support

---

## Supported Devices

| Device | Code | Features |
|--------|------|----------|
| Smart Plug | `S3PL-*` | Power, voltage, current, ON/OFF |
| Weather Station | `SBWS-*` | Temp, humidity, pressure, UV, rain |
| Gateway | `SNGW-*` | Connection status |

---

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / Xcode

### Installation

```bash
# Clone the repository
git clone https://github.com/dz0ny/ohmyshelly.git
cd ohmyshelly

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build Release

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## License

This project is open source. See the repository for license details.

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
