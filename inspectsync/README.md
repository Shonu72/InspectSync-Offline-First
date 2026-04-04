# InspectSync

> **Offline-First Field Inspection Platform** — Built for engineers who work where connectivity is unreliable.

InspectSync is a Flutter-based mobile application designed for field engineers to conduct infrastructure inspections, log field evidence, and synchronize data with command centers — even in environments with intermittent or zero internet connectivity.

---

## 📊 Project Completion Status

| Module | Status | Completion |
|--------|--------|------------|
| **Authentication** | ✅ Completed | 100% |
| **Dashboard** | ✅ Completed | 100% |
| **Task Management** | ✅ Completed | 100% |
| **Map View (Clustering)** | ✅ Completed | 100% |
| **Sync Engine** | ✅ Completed | 100% |
| **Conflict Resolution** | ✅ Completed | 95% |
| **Connectivity Telemetry** | ✅ Completed | 100% |
| **Create Task Flow** | ✅ Completed | 100% |
| **Design System (Theming)** | ✅ Completed | 100% |
| **User Profile & Settings** | ✅ Completed | 100% |
| **Localization (i18n)** | ✅ Completed | 90% |
| **Backend API Integration** | ✅ Progressing | 80% |

**Overall Progress: ~85%**

```
███████████████████████████░░░  85%
```
---

## 📦 Core Functional Modules

The application is structured into several high-performance modules, each handling a specific domain of field operations:

- **🔑 Authentication & Identity**: Manages secure engineer onboarding via JWT, persistent session handling, and biometric hardware verification (FaceID/Fingerprint).
- **📡 Strategic Sync Engine**: The core heartbeat of the app. Features an optimistic offline-first architecture with a reactive SQLite queue, change tracking, and an isolated background routine for data reconciliation.
- **📋 Task & Directive Management**: Handles the full lifecycle of field assignments—from priority-based creation and protocol definition to real-time execution tracking (Elapsed Time & Progress).
- **📊 Command Dashboard**: A high-fidelity telemetry interface providing an at-a-glance view of sync health, daily mission velocity, and prioritized operation lists.
- **🗺️ Geospatial Intelligence (Map)**: Interactive mapping layer featuring **Marker Clustering** for high-density task areas and tactical **Pointer Markers**.
- **📡 Signal Integrity Telemetry**: Enhanced connectivity monitoring that measures real-time latency (ms) and estimated uplink speed (Mbps) across network types.

---

## 🏗️ Architecture

The project follows a **Clean Architecture (Data/Domain/Presentation/Bloc)** pattern with strict separation of concerns.

```
lib/
├── main.dart                         # App entry point, MultiBlocProvider, GoRouter config
├── core/
│   ├── di/
│   │   └── injection_container.dart  # Central GetIt dependency injection
│   ├── db/
│   │   ├── app_database.dart         # Drift database definition
│   │   └── tables/                   # Tasks, SyncQueue, Conflicts schemas
│   ├── network/
│   │   ├── api_client.dart           # Dio-based REST client
│   │   └── connectivity_service.dart # Real internet reachability monitor
│   ├── theme/
│   │   ├── app_theme.dart            # Dual-mode design system
│   │   └── theme_cubit.dart          # Persistent appearance management
│   └── security/
│       └── security_cubit.dart       # Biometric hardware management
├── features/
│   ├── auth/                         # Auth module (Clean Architecture)
│   │   ├── domain/                   # Entities, Repositories, UseCases
│   │   ├── data/                     # Models, Repositories, DataSources
│   │   └── presentation/             # Bloc (Cubit), Screens, Widgets
│   ├── profile/                      # Engineer Profile & Settings
│   ├── dashboard/                    # Command center dashboard
│   ├── map/                          # Geospatial map view
│   ├── sync/                         # Offline sync engine
│   └── tasks/                        # Task management module
└── l10n/                             # Localization (en)
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Flutter 3.x (Dart ^3.11.0) | Cross-platform mobile UI |
| **Architecture** | Clean Architecture | Modularity & testability |
| **State Management** | **Flutter Bloc (Cubit)** | Reactive & predictable state |
| **Dep. Injection** | **GetIt ^8.0.2** | Centralized service registry |
| **Local Database** | Drift (SQLite) | Offline-first persistent storage |
| **Navigation** | GoRouter ^17.1.0 | Declarative routing & deep linking |
| **Security** | `local_auth` + `flutter_secure_storage` | Biometrics & credential encryption |
| **Connectivity** | `connectivity_plus` + Lookup | Two-layer network monitoring |
| **Theming** | `shared_preferences` | Persistent Dark/Light mode |

---

## 🎨 Design System

InspectSync implements a **dual-mode design system** called the **"Tactical Architect"** specification:

### Light Mode
- Clean, high-contrast surfaces (`#F8FAFB` base)
- Tonal layering with no visible 1px borders
- Primary blue accent (`#005BBF`)
- Large touch targets (min 48dp)

### Dark Mode — "Obsidian Command"
- Deep navy surfaces (`#060E20` base)
- Softened blue primary (`#6B92ED`) for reduced eye strain
- Elevated tonal separation through opacity-based card hierarchy
- Suitable for low-light field environments

### Key Design Tokens
- **Fonts**: Manrope (headings), Inter (body)
- **Corner Radius**: 8px inputs, 12px cards, 16px sections, 20px modals
- **Elevation**: Zero shadow philosophy — separation through color contrast only
- **All screens are theme-aware** and render correctly in both Light and Dark modes

---

## 📱 Screen Inventory

### 1. Login Screen
- Secure terminal branding with "InspectSync" identity
- Email + password fields with validation
- "Remember device" option placeholder
- Navigates to Dashboard on successful authentication

### 2. Dashboard (Command Center)
- **Real-time Sync Status Header**: Dynamic icon/label that shows ONLINE, OFFLINE, or SYNCING with live progress percentage
- **Offline Mode Banner**: Red banner for no internet, orange banner for cached changes
- **Sync Telemetry Strip**: Shows current sync state with item counts
- **Priority-sorted Task Cards**: Tasks displayed with P1/P2/P3 color-coded indicators
- **Daily Velocity Tracker**: Progress gauge with target vs. achieved metrics
- **List/Map Toggle**: Switch between list and map visualization modes
- **Profile Redirection**: Tapping initials navigates to the dedicated Profile screen

### 3. Tasks Screen (Field Assignments)
- Scrollable list of active directives with tactical headers
- System telemetry status cards (encryption status, cache mode)
- Each task card supports full-card tap navigation to details

### 4. Task Details Screen (Tactical Interface)
- **Mission Header**: Project ID, task title, location sector.
- **Operational Checklist**: Interactive toggle items with real-time progress tracking.
- **Field Evidence Section**: Photo grid with capture button (camera integration stub).
- **Tactical Notes**: Multi-line text input for site observations.
- **Sticky Footer**: 
  - **Live Session Timer**: Shows **"Time on Site"** tracked since the screen was opened, providing accurate field duration telemetry.
  - **Dynamic Progress**: Real-time completion percentage based on checklist status.
  - **Submit Button**: Finalizes the local report.

### 5. Create Task Screen
- **Priority Toggle**: Animated HIGH / MED / LOW selector with color feedback
- **Task Title & Protocol**: Free-form input card for task definition
- **Category Picker**: Bottom sheet selector (Field Maintenance, Infrastructure Audit, Sensor Calibration, Emergency Repair, Routine Inspection)
- **Location Display**: Pre-filled zone/sector reference
- **Schedule Card**: Native date and time pickers with blue accent tint
- **Intelligence Attachments**: Media capture and document upload tiles (stubs)
- **"Execute Creation"** button with title validation

### 6. Map Screen
- **Marker Clustering**: Automatically groups nearby tasks to prevent visual overlap.
- **Pointer Design**: Tactical "Pin + ID Tag" markers for improved coordinate accuracy.
- **Auto-Fit View**: Centers and zooms the map to fit all active mission tasks on load.
- **Tactical Controls**: Dedicated Zoom In/Out, "My Location", and "List Mode" quick-access FABs.

### 7. Engineer Profile Screen
- **User Telemetry**: Displays real-time name, role, and "Verified" status from `AuthCubit`
- **Functional Controls**:
    - **Appearance**: Persistent Dark/Light mode toggle
    - **Offline Mode**: Manual networking override for data privacy
    - **Biometric Login**: Hardware-aware FaceID/Fingerprint toggle
- **Account Actions**:
    - Change Password (UI stub)
    - **Logout**: Safe session termination with confirmation dialog
    - **Delete Account**: Destructive action with security warning

### 7. Sync Status Screen (Telemetry View)
- **Sync Progress Card**: Real-time progress bar with percentage, current item description, and Sync Now / Cancel All actions.
- **History Card**: Shows **"Last Successful Sync"** with dynamic human-readable formatting (e.g., "Today, 14:30") persisted via `SharedPreferences`.
- **Local Storage Card**: Real-time **DB File Size** calculation (e.g., "425.0 KB") measured directly from the SQLite `db.sqlite` file.
- **Reactive Queue List**: Pending sync items are displayed via a live `Stream`. Items appear in the queue **instantly** even in offline mode, reflecting the internal database state.
- **Resolve Button**: Deep-links to the Conflict Resolution screen for failed items.

### 8. Conflict Resolution Screen
- Side-by-side diff view of local vs. server data for conflicted entities
- "Keep Local", "Keep Server", and manual merge options
- Resolution saves back to the database and updates sync queue status

---

## 🔄 Offline Sync Engine

The sync system is the core technical innovation of InspectSync. It follows an **optimistic offline-first** pattern:

### Data Flow

```
User Action → Local DB Write → Sync Queue Entry → Background Sync → Server
                                                       ↓
                                                  Conflict Check
                                                     ↓    ↓
                                              No Conflict  Conflict Detected
                                                  ↓              ↓
                                           Mark Synced    Create Conflict Record
                                                              ↓
                                                    User Resolves via UI
```

### Key Components

1. **SyncQueueManager**: Manages a FIFO queue of pending changes in SQLite. Each entry tracks entity type, entity ID, action (create/update), payload, status, and retry count.

2. **SyncService**: The orchestrator that:
   - Reads the pending queue
   - Pushes changes to the remote datasource
   - Fetches latest server state for conflict detection
   - Emits real-time `SyncProgress` via a broadcast stream

3. **ConflictResolver**: Compares local and server payloads field-by-field. When a difference is detected, it creates a `Conflict` record in the database with both versions for user resolution.

4. **SyncController** (ChangeNotifier): The state manager that:
   - Listens to `SyncService.progressStream` for real-time operation updates.
   - **Reactive Queue**: Subscribes to the `SyncQueue` database stream to show pending items immediately (even offline).
   - **Telemetry**: Calculates real disk usage of the local database.
   - **Persistence**: Exposes the last successful sync time from shared preferences.
   - Blocks sync attempts when the device is "Logically Offline" (Manual Mode).

### Database Schema

| Table | Fields | Purpose |
|-------|--------|---------|
| **Tasks** | id, title, description, lat, lng, status, version, isSynced, updatedAt, createdAt | Core task data |
| **SyncQueue** | id, entityType, entityId, action, payload, status, retryCount, createdAt | Offline change queue |
| **Conflicts** | id, entityId, entityType, localData, serverData, status, createdAt | Unresolved merge conflicts |

---

## 🌐 Real Connectivity Monitoring

InspectSync implements a **two-layer connectivity verification** system:

| Layer | Mechanism | Speed | Accuracy | Note |
|-------|-----------|-------|----------|------|
| **Layer 1** | `connectivity_plus` | Instant | Medium | Detects physical radio state (WiFi/Mobile) |
| **Layer 2** | `InternetAddress.lookup` | ~1-5 sec | High | Verifies actual DNS reachability |
| **Layer 3** | **Signal Integrity** | Real-time | High | Measures **Latency (ms)** and **Mbps** |
| **Layer 4** | **Manual Toggle** | Instant | Perfect | User-defined "Offline Mode" override |

### Behavior

- **Periodic polling**: Background recheck every 30 seconds
- **Instant response**: Layer 1 events trigger immediate Layer 2 verification
- **Auto-sync on reconnect**: When connectivity is restored and pending items exist, sync triggers automatically
- **UI feedback**: Dashboard status header, sync screen badge, and offline banners all react in real-time via `ChangeNotifier`

---

## 🧭 Navigation Architecture

All navigation is managed through **GoRouter** with the following route table:

| Route | Screen | Type |
|-------|--------|------|
| `/` | LoginScreen | Root (Guard-protected) |
| `/dashboard` | MainScreen (with BottomAppBar shell) | Authenticated root |
| `/profile` | ProfileScreen | Full-screen push |
| `/sync` | SyncStatusScreen | Full-screen push |
| `/sync/conflict/:id` | ConflictResolutionScreen | Full-screen push (with `extra` data) |
| `/task-details` | TaskDetailsScreen | Full-screen push |
| `/create-task` | CreateTaskScreen | Full-screen push |

### Bottom Navigation Tabs (inside `/dashboard`)

| Index | Icon | Label | Behavior |
|-------|------|-------|----------|
| 0 | Dashboard | DASHBOARD | IndexedStack tab |
| 1 | Map | MAP | IndexedStack tab |
| 2 | Tasks | TASKS | IndexedStack tab |
| 3 | Sync | SYNC | Redirects to `/sync` (full-screen push) |

The FAB (center-docked `+` button) navigates to `/create-task`.

---

## 🌍 Localization

The app uses Flutter's official `flutter_localizations` framework with ARB files:

- **Current locales**: English (`en`)
- **Translation file**: `lib/l10n/app_en.arb`
- **Coverage**: Dashboard labels, navigation labels, sync status messages, task field labels, velocity metrics, system messages
- **Parameterized messages**: Supports plurals and variable interpolation (e.g., `taskUnitsRemaining(count)`, `systemHealthy(count)`)

---

## 🧪 Testing

| Type | Status | Details |
|------|--------|---------|
| Widget tests | ✅ Stub test | Basic app bootstrap validation (`widget_test.dart`) |
| Unit tests | 🔲 Not started | Sync engine, conflict resolver, connectivity service |
| Integration tests | 🔲 Not started | Full user flow testing |

---

## 🚀 Build & Run

### Prerequisites
- Flutter SDK ^3.11.0
- Dart ^3.11.0
- Android SDK / Xcode (for platform builds)

### Development
```bash
flutter pub get
flutter run
```

### Production Build
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

### Code Generation (after schema changes)
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 📦 APK Size

| Build Type | Size |
|-----------|------|
| Release APK | **63.2 MB** |
| Material Icons (tree-shaken) | 10 KB (99.4% reduction) |
| Cupertino Icons (tree-shaken) | 848 B (99.7% reduction) |

---

## 🗺️ Roadmap

### Phase A — Foundation ✅
- [x] Authentication flow
- [x] Dashboard with sync status header
- [x] Map view integration
- [x] Task list with priority indicators
- [x] Offline database setup (Drift/SQLite)
- [x] Dual-mode design system (Light + Dark)
- [x] Localization framework

### Phase B — Task Execution ✅
- [x] Task detail screen with operational checklist
- [x] Task creation flow with full form
- [x] GoRouter navigation for all screens
- [x] FAB → Create Task flow
- [x] Dashboard → Task Details flow
- [x] Theme-aware UI across all screens

### Phase C — Sync & Connectivity ✅
- [x] Sync engine with queue management
- [x] Conflict detection and resolution UI
- [x] Real connectivity monitoring (two-layer)
- [x] Auto-sync on reconnect
- [x] Sync progress streaming

### Phase D — Production Readiness 🔲
- [ ] Backend API integration (replace stubs)
- [ ] Camera & file upload for field evidence
- [ ] Time-on-site tracking service
- [ ] User profile & settings screen
- [ ] Push notifications for task assignments
- [ ] Admin/supervisor desktop dashboard
- [ ] Unit & integration test suite
- [ ] CI/CD pipeline (Fastlane + Codemagic)
- [ ] Error tracking & analytics (Sentry / Firebase)

---

## 📄 License

Private — Not for redistribution.
