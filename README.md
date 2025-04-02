# fishm 🐟📖  

![Flutter](https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter)  
![License](https://img.shields.io/badge/License-MIT-green)  
![Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20Web%20|%20Desktop-lightgrey)  

A **cross-platform manga reader** built with Flutter, offering offline/online reading, plugin-based sources, and customizable UI. Inspired by [Tachiyomi] and optimized for Flutter ecosystems.  

---

## ✨ Features  
### 📖 Core Reading  
- **Multi-format support**: Parse `.cbz`/`.zip` files locally  
- **Reading modes**: Webtoon/paginated, dual-page, and vertical scrolling  

### 🔌 Extensibility  
- **Lua plugin engine**:  
  - Embed Lua scripts for custom source parsing (e.g., dynamic URL generation)   
  - Hot-reload plugins without app restart  
- **YAML-based source management**:  
  - Define plugin metadata (name/version/API endpoints) in `http://*.yaml`   
  - Auto-download plugin lists from trusted repositories via YAML manifests  

### 🌐 Online Integration  
- **Smart caching**: Preload chapters with priority queues (YAML-defined thresholds)  

### ⚙️ Configuration  
- **YAML-driven**:  
  - Define source-specific rules (e.g., rate limits, auth headers)   

---

## 🚀 Quick Start  
### Prerequisites  
- Flutter 3.27+  

### Installation  
```bash  
git clone https://github.com/shanlihou/fishm
cd fishm  
flutter pub get  
flutter run
```

## 📦 Installation from APK  

```bash
curl -L -o fishm.apk https://github.com/shanlihou/fishm/releases/download/v1.0.14/app-release.apk
```




