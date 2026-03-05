# 🌾 Soko Mkononi

**Bei za Mazao Kwa Urahisi** — Real-time crop price intelligence for Tanzanian farmers.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      SwiftUI Views                       │
│  DashboardView  PriceDetailView  WatchlistView  Settings │
└──────────────────────┬──────────────────────────────────┘
                       │ @StateObject / @EnvironmentObject
┌──────────────────────▼──────────────────────────────────┐
│                    ViewModels (@MainActor)                │
│    DashboardVM    PriceDetailVM    WatchlistVM           │
└──────────┬─────────────────────────────┬────────────────┘
           │                             │
┌──────────▼──────────┐   ┌─────────────▼───────────────┐
│   CropNetworkService │   │      CropCacheService        │
│   URLSession +       │   │      SwiftData +             │
│   Async/Await        │   │      ModelContext             │
│   Local JSON fallback│   │      Offline persistence     │
└─────────────────────┘   └─────────────────────────────┘
```

## Key Features

| Feature | Implementation |
|---|---|
| **Offline First** | SwiftData cache with instant load, network refresh |
| **Type-Safe Navigation** | `NavigationStack` + `NavigationPath` + `AppRouter` |
| **Error Handling** | `AppError` enum → `LoadState<T>` → UI error states |
| **State Management** | `@MainActor` ViewModels + `@Published` reactive state |
| **Data Viz** | Swift Charts with line + area marks, time range picker |
| **Network Monitoring** | `NWPathMonitor` with offline banner |
| **Protocol-Driven** | `CropDataServiceProtocol` enables mocking/testing |
| **Localization** | Kiswahili UI labels throughout |

## Folder Structure

```
SokoMkononi/
├── App/              # Entry point, routing, navigation
├── Models/           # DTOs, SwiftData models, enums, errors
├── Services/         # Network, cache, monitoring
├── ViewModels/       # Business logic, state management
├── Views/
│   ├── Dashboard/    # Market feed
│   ├── Detail/       # Price chart + analysis  
│   ├── Watchlist/    # Kibindoni offline view
│   └── Components/   # Reusable UI
├── Utilities/        # Theme, design system
├── Extensions/       # Swift/SwiftUI extensions
└── Resources/        # crops.json, assets
```

## Screens

### 1. Soko Dashboard
- Searchable, filterable crop list
- Region + Category + Sort chips
- Offline mode banner
- Pull-to-refresh
- Trend indicators (🟢 up / 🔴 down / 🟡 stable)

### 2. Bei Detail (Price Detail)
- Swift Charts line graph with gradient fill
- 7-day / 30-day / 90-day time range
- Price statistics (min/max/average)
- Multi-market comparison table
- Watchlist bookmark button

### 3. Kibindoni (Watchlist)
- Saved crops with offline badge
- Last updated timestamp
- Swipe-to-remove
- Works fully offline

### 4. Mipangilio (Settings)
- Live network status
- Default region preference
- Cache management
- App version info
