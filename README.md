# fishm 🐟📖  

![Flutter](https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter)  
![License](https://img.shields.io/badge/License-MIT-green)  
![Platforms](https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20Web%20|%20Desktop-lightgrey)  

A **cross-platform manga reader** built with Flutter, offering offline/online reading, plugin-based sources, and customizable UI. Inspired by [Tachiyomi] and optimized for Flutter ecosystems.  

---

## 🎬 Visual Showcase

<div align="center">
  <img src="https://raw.githubusercontent.com/shanlihou/PicNest/refs/heads/main/preview1.jpg" alt="Search Manga" width="200"/>
  <img src="https://raw.githubusercontent.com/shanlihou/PicNest/refs/heads/main/preview2.jpg" alt="Manga Detail" width="200"/> 
  <img src="https://raw.githubusercontent.com/shanlihou/PicNest/refs/heads/main/preview3.jpg" alt="Manga Reader" width="200"/>
</div>

*From left to right: Search Manga → Manga Detail → Manga Reader*

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

## 🛠️ Plugin Installation Tutorial (Demo)

### Step 1: Access Source Management
Navigate to:  
`Settings` → `Sources` → `Add New Source`  

### Step 2: Add YAML Source
Paste this URL in the input field:  

https://github.com/shanlihou/fish_demo/blob/master/local.yaml?raw=true

 Click **Confirm** to add the source .

### Step 3: Install Plugins
1. Go to `Store` tab  
2. Refresh the list (pull down or click 🔄)  
3. Find the demo plugin (e.g., `FishDemo`) and click **Install**  

### Step 4: Search for Demo Content
1. Open `Search` page  
2. Enter any random keyword (e.g., `test123`)  
3. Demo manga entries will appear  

### ⚠️ Notes  
- This is a **demo-only** workflow for testing purposes .  
- For real-world usage, replace the YAML address with trusted sources .  

---