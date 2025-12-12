# OhMyShelly

A Flutter mobile app for monitoring and controlling **Shelly smart home devices**.  
Includes live dashboards, device management, and detailed power & weather statistics.

[![Download](https://img.shields.io/github/v/release/dz0ny/ohmyshelly?label=Download&style=for-the-badge)](https://github.com/dz0ny/ohmyshelly/releases)

---

## Downloads

📱 **[Download Latest Release](https://github.com/dz0ny/ohmyshelly/releases)**

- **Android**: Download the `.apk` file from releases
- **iOS**: Build from source (see instructions below)

---

## Screenshots

<p align="center">
<img width="240" src="https://github.com/user-attachments/assets/2355832a-ce10-4f7b-8cbb-2670f5d0fa36" />
<img width="240" src="https://github.com/user-attachments/assets/d0015b95-8067-47cd-84b0-c088c4ac2359" />
<img width="240" src="https://github.com/user-attachments/assets/f8e92014-6c46-4efb-99ba-e159e1715313" />
<img width="240" src="https://github.com/user-attachments/assets/d5427bfc-6b1a-4263-a187-4a06346e3836" />
<img width="240" src="https://github.com/user-attachments/assets/0b40e026-eae1-4886-92ca-9eb03b813c58" />
<img width="240" src="https://github.com/user-attachments/assets/fac9e2f0-9c60-4baf-9710-f5b3d72d414c" />
<img width="240" src="https://github.com/user-attachments/assets/96f59839-c733-4718-8e17-a32e3e88b290" />
<img width="240" src="https://github.com/user-attachments/assets/a7bfc1da-33a0-457d-b498-10c8e1d24eff" />
</p>

---

## Features

- 🔐 Shelly Cloud authentication
- 📊 Live device dashboard
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
