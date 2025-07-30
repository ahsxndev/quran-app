<div align="center">

# 📖 The Holy Qur'an — Flutter App

### A beautifully designed Al-Quran mobile app with complete offline support

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

A comprehensive Quranic app featuring complete Surahs and Juz navigation, smooth audio playback (streaming & offline), smart connectivity handling, Tasbeeh counter, and beautiful Asma ul Husna screen — all in a modern UI.

<img width="100%" alt="App Banner" src="https://github.com/user-attachments/assets/3a6e4167-9a07-4820-aea1-b52aae149983" />

[![Open Source](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](#)
[![GitHub Forks](https://img.shields.io/github/forks/ahsxndev/quran-app.svg?style=social&label=Fork&maxAge=2592000)](https://github.com/ahsxndev/quran-app/fork)
[![GitHub Issues](https://img.shields.io/github/issues/ahsxndev/quran-app.svg?style=flat&label=Issues&maxAge=2592000)](https://github.com/ahsxndev/quran-app/issues)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat&label=Contributions&colorA=red&colorB=black)](#)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 📖 **Quranic Content**
- 📚 Complete 114 Surahs with Arabic text
- 📑 30 Juz (Para) navigation
- 🔍 Search functionality
- 📱 Responsive text sizing
- 🎨 Beautiful Arabic typography

</td>
<td width="50%">

### 🎧 **Audio Experience**
- 🔊 High-quality recitation playback
- 📥 Download for offline listening
- 🎵 Background audio support
- ⚡ Seek, repeat, auto-next controls
- 🌐 Smart connectivity handling

</td>
</tr>
</table>

### 🔧 **Additional Tools**
- 🧮 **Digital Tasbeeh Counter** with vibration feedback
- 💎 **Asma ul Husna** - 99 Beautiful Names of Allah
- 🕌 **Prayer Times** with location-based calculations
- 📅 **Islamic Calendar** with Hijri dates
- 📱 **Offline-first** design for uninterrupted usage

---

## 📥 Download & Installation

### 📱 **Download Options**
> 🚧 **Play Store**: Coming Soon  
> 📦 **Source Code**: Available now for manual installation

### 🛠️ **Installation from Source**

**Prerequisites:**
```bash
Flutter SDK    >=3.22.0
Dart SDK       >=3.0.0
Android Studio or VS Code
```

**Setup Steps:**
```bash
# 1. Clone the repository
git clone https://github.com/ahsxndev/quran-app.git
cd quran-app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> ⚠️ **Important:** Test on a real device for download, storage, and background audio features.  
> 🗑️ **Note:** The `media_assets` folder can be deleted after cloning (used for GitHub preview only).

---

## 🎥 Demo

<div align="center">

[![Watch Demo](https://img.shields.io/badge/Watch-Demo_Video-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://vimeo.com/1103877665?share=copy)

*Experience the app's features in action*

</div>

---

## 📸 App Screenshots

### 🚀 **App Flow & Navigation**
<div align="center"> 
  <img src="assets/media_assets/splash.gif" width="180" alt="Animated Splash Screen" /> 
  <img src="assets/media_assets/onBoarding.gif" width="180" alt="Interactive Onboarding" /> 
  <img src="assets/media_assets/home.jpg" width="180" alt="Modern Home Screen" /> 
  <img src="assets/media_assets/quran.gif" width="180" alt="Quran Reading Interface" /> 
</div>

### 🎵 **Audio & Islamic Features**
<div align="center"> 
  <img src="assets/media_assets/audio.gif" width="180" alt="Audio Player Controls" /> 
  <img src="assets/media_assets/names.gif" width="180" alt="99 Names of Allah" /> 
  <img src="assets/media_assets/tasbih.gif" width="180" alt="Digital Tasbeeh Counter" /> 
  <img src="assets/media_assets/prayer.gif" width="180" alt="Prayer Time Calculator" /> 
</div>

---

## 🏗️ Technical Architecture

### 📦 **Core Dependencies**

| Package | Purpose | Features |
|---------|---------|----------|
| `just_audio` | Audio playback | Background play, seeking, speed control |
| `quran` | Quranic data | Complete Surah & verse text |
| `prayers_times` | Prayer calculations | Location-based Salah timings |
| `connectivity_plus` | Network status | Smart offline/online handling |
| `shared_preferences` | Local storage | Settings & download management |

### 🔧 **Key Features Implementation**
- **Offline Support**: Downloaded audio cached locally
- **Background Audio**: Continues playing when app is minimized
- **Smart Connectivity**: Auto-retries when connection restored
- **Performance**: Shimmer loading states for smooth UX
- **Accessibility**: Haptic feedback and readable typography

---

## 🌐 Data Sources & APIs

**Islamic Content:**
- 📖 **Quranic Text**: [`quran`](https://pub.dev/packages/quran) package
- 🕌 **Prayer Times**: [`prayers_times`](https://pub.dev/packages/prayers_times) with GPS location
- 📅 **Hijri Calendar**: Local calculation using `hijri` package
- 🎧 **Audio Recitation**: High-quality MP3 files from reliable Islamic sources

**Technical APIs:**
- 🌍 **Location Services**: Device GPS for accurate prayer times
- 🕐 **Timezone**: Automatic timezone detection and conversion

---

## 🔒 Permissions Required

| Permission | Purpose | Usage |
|------------|---------|-------|
| **Internet** | Audio streaming & downloads | Download Surah audio files |
| **Storage** | Offline audio storage | Save downloaded recitations |
| **Location** | Prayer time calculation | Accurate Salah timing based on GPS |
| **Vibration** | Haptic feedback | Tasbeeh counter vibration |

---

## 🧪 Testing & Compatibility

### ✅ **Verified Features**
- ✅ Complete offline functionality after audio download
- ✅ Background audio playback with system controls
- ✅ Haptic feedback and vibration on supported devices
- ✅ Responsive UI across different screen sizes
- ✅ Network connectivity state handling

### 📱 **Platform Support**
- 🤖 **Android**: Fully supported (API 21+)
- 🍎 **iOS**: Compatible (iOS 12+)
- 🌐 **Web**: Limited support (no background audio)

---

## 🤝 Contributing

We welcome contributions to make this app even better! Here's how you can help:

### 🛠️ **Development Setup**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and test thoroughly
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### 🎯 **Areas for Contribution**
- 🌍 **Translations**: Add more language support
- 🎨 **UI/UX**: Improve design and user experience
- 🔊 **Audio**: Add more reciter options
- 📱 **Features**: Prayer reminders, Qibla direction, etc.
- 🐛 **Bug Fixes**: Report and fix issues

---

## 🚀 Future Roadmap

- [ ] **Play Store Release** - Official app store distribution
- [ ] **Multiple Reciters** - Choice of different Qaris
- [ ] **Prayer Notifications** - Automatic Salah reminders
- [ ] **Qibla Direction** - Compass for prayer direction
- [ ] **Bookmarks** - Save favorite verses
- [ ] **Dark Mode** - Theme customization
- [ ] **Translations** - Multiple language support

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

**Special Thanks:**

🕌 **Islamic Content Providers** - For authentic Quranic text and audio  
📚 **Flutter Community** - For amazing packages and support  
🎨 **UI/UX Inspiration** - Modern Islamic app designs  
🌟 **Beta Testers** - For valuable feedback and testing  

---

## 👤 Author & Contact

<div align="center">

### **Ahsan Zaman**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ahsxndev)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/ahxanzaman)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:ahsanzaman.dev@gmail.com)

**Found this helpful?** Give it a ⭐ on GitHub and share your feedback!

[![GitHub followers](https://img.shields.io/github/followers/ahsxndev?style=social)](https://github.com/ahsxndev)
[![GitHub stars](https://img.shields.io/github/stars/ahsxndev/quran-app?style=social)](https://github.com/ahsxndev/quran-app)

</div>

---

<div align="center">

**Built with ❤️ for the Muslim Ummah**

*May Allah accept this humble effort* 🤲

**"And We have certainly made the Qur'an easy for remembrance, so is there any who will remember?"** - *Quran 54:17*

</div>
