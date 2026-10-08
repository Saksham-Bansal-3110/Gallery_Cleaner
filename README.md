# Gallery Cleaner

A native iOS application for finding, reviewing, and cleaning up photos and videos that are taking up unnecessary storage.

Gallery Cleaner analyzes your photo library and organizes media into useful categories such as screenshots, duplicates, similar photos, and large videos, allowing users to review items before deciding what to remove.

---

## ✨ Features

### 📸 Screenshots
Quickly find screenshots in your photo library and review them in one place.

### 🎬 Videos
Browse videos separately from photos and identify media that may be taking up significant storage.

### 🗂️ Duplicate Photos
Detect exact duplicate photos so you can review redundant copies.

### 🖼️ Similar Photos
Identify highly similar photos, such as burst shots or multiple captures of the same scene.

Similarity detection uses a multi-stage pipeline combining perceptual hashing and Apple's Vision framework.

### 🎥 Duplicate Videos
Find duplicate video assets and review them before deletion.

### 💾 Large Videos
Identify videos consuming significant amounts of storage.

### 📊 Storage Overview
See how your photo library's storage is distributed across the different categories.

### 🔍 Media Detail
Open individual photos and videos in a dedicated detail viewer.

- High-quality photo viewing
- Video playback
- Pinch-to-zoom
- Media information sheet
- File size and metadata
- Safe deletion with confirmation

### 🧹 Safe Cleanup
Gallery Cleaner never automatically deletes media.

Users review and explicitly select the items they want to remove before deletion.

## 🏗️ Architecture

Gallery Cleaner is built using a modular architecture designed to handle large photo libraries efficiently.

```text
                    Gallery Cleaner
                          │
                          ▼
                    SwiftUI UI
                          │
             ┌────────────┴────────────┐
             ▼                         ▼
       Category Views             Media Detail
             │                         │
             ▼                         ▼
      Scanner Services          PhotoKit / AVKit
             │
             ▼
       Analysis Pipeline
             │
      ┌──────┴──────┐
      ▼             ▼
   dHash          Vision
      │             │
      └──────┬──────┘
             ▼
     Candidate Generation
             │
             ▼
     Similarity Scoring
             │
             ▼
      Group Clustering
             │
             ▼
      Photo Ranking
```

The application separates UI concerns from media analysis and persistence to keep expensive operations away from the main UI thread.

---

## 🔬 Similar Photo Detection

Similar photo detection uses a multi-stage pipeline rather than comparing every image against every other image.

```text
Photo Library
      │
      ▼
Exact Duplicate Filtering
      │
      ▼
Cheap Image Analysis
      │
      ├── Metadata
      ├── Perceptual Hash
      └── Temporal Information
      │
      ▼
Candidate Generation
      │
      ▼
Vision Feature Extraction
      │
      ▼
Vision Distance
      │
      ▼
Conservative Similarity Threshold
      │
      ▼
Complete-Linkage Clustering
      │
      ▼
Similar Photo Groups
      │
      ▼
Photo Ranking
```

### Candidate generation

Cheap signals such as perceptual hashing and temporal proximity are used to reduce the number of expensive comparisons.

### Vision

Apple's Vision framework is used for visual feature representations and similarity scoring.

### Conservative grouping

Similarity groups use conservative clustering to reduce false positives.

The application intentionally prioritizes **precision over recall** because incorrectly identifying unrelated photos as similar can lead to unsafe cleanup decisions.

## 📱 Categories

Gallery Cleaner currently organizes the library into:

| Category | Purpose |
|---|---|
| Screenshots | Find screenshots |
| Videos | Browse videos |
| Duplicate Photos | Find exact photo duplicates |
| Similar Photos | Find highly similar photos |
| Duplicate Videos | Find duplicate videos |
| Large Videos | Find large video files |

## 🚀 Getting Started

### Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/GalleryCleaner.git
```

### Photo Library Permission

Gallery Cleaner requires access to the user's Photos library to analyze media.

On first launch:

```text
Onboarding
    ↓
Get Started
    ↓
Photos Permission
    ↓
Gallery Cleaner
```

## ⚠️ Disclaimer

Gallery Cleaner is intended to assist users in reviewing and organizing their photo library.

Similarity detection is algorithmic and may occasionally produce incorrect results. Users should always review media before deleting it.

Gallery Cleaner does not automatically delete photos or videos based solely on similarity analysis.

---

## 📄 License

This project is currently for educational and development purposes.

License details will be added as the project evolves.

---

## 👨‍💻 Author

**Saksham Bansal**
