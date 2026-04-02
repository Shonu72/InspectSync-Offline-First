# InspectSync

> **Offline-First Field Inspection Platform** — Built for engineers who work where connectivity is unreliable.

InspectSync is a Flutter-based mobile application designed for field engineers to conduct infrastructure inspections, log field evidence, and synchronize data with command centers — even in environments with intermittent or zero internet connectivity.

---

## 📊 Project Completion Status

| Module | Status | Completion |
|--------|--------|------------|
| **Authentication** | ✅ Completed | 100% |
| **Dashboard** | ✅ Completed | 100% |
| **Task Management** | ✅ Completed | 95% |
| **Map View** | ✅ Completed | 85% |
| **Sync Engine** | ✅ Completed | 90% |
| **Conflict Resolution** | ✅ Completed | 90% |
| **Connectivity Monitoring** | ✅ Completed | 100% |
| **Create Task Flow** | ✅ Completed | 90% |
| **Design System (Theming)** | ✅ Completed | 100% |
| **Localization (i18n)** | ✅ Completed | 80% |
| **Admin Dashboard (Desktop)** | 🔲 Not Started | 0% |
| **Push Notifications** | 🔲 Not Started | 0% |
| **User Profile & Settings** | 🔲 Not Started | 0% |
| **Analytics & Reporting** | 🔲 Not Started | 0% |
| **Backend API Integration** | 🔲 Stubbed | 15% |

**Overall Progress: ~65%**

```
████████████████████░░░░░░░░░░░  65%
```

---

## 🏗️ Architecture

The project follows a **feature-first modular architecture** with a clear separation between data, domain, and presentation layers.

```
lib/
├── main.dart                         # App entry point, dependency wiring, GoRouter config
├── core/
│   ├── db/
│   │   ├── app_database.dart         # Drift database definition
│   │   ├── app_database.g.dart       # Generated Drift code
│   │   └── tables/
│   │       ├── tasks_table.dart      # Tasks schema
│   │       ├── sync_queue_table.dart  # Offline sync queue schema
│   │       └── conflicts_table.dart  # Conflict tracking schema
│   ├── network/
│   │   └── connectivity_service.dart # Real internet reachability monitor
│   └── theme/
│       └── app_theme.dart            # Dual-mode design system (Light + Dark)
├── features/
│   ├── auth/                         # Authentication module
│   ├── dashboard/                    # Command center dashboard
│   ├── map/                          # Geospatial map view
│   ├── sync/                         # Offline sync engine
│   │   ├── sync_service.dart         # Core sync orchestrator
│   │   ├── sync_queue_manager.dart   # Queue CRUD operations
│   │   ├── conflict_resolver.dart    # Conflict detection & resolution
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── sync_controller.dart
│   │       └── screens/
│   │           ├── sync_status_screen.dart
│   │           └── conflict_resolution_screen.dart
│   └── tasks/                        # Task management module
│       ├── data/
│       │   ├── task_local_datasource.dart
│       │   ├── task_remote_datasource.dart
│       │   └── task_repository.dart
│       └── presentation/
│           ├── screens/
│           │   ├── tasks_screen.dart
│           │   ├── task_details_screen.dart
│           │   └── create_task_screen.dart
│           └── widgets/
│               └── task_card.dart
└── l10n/                             # Localization
    ├── app_en.arb                    # English translations
    ├── app_localizations.dart        # Generated l10n
    └── app_localizations_en.dart     # Generated English delegate
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Flutter 3.x (Dart ^3.11.0) | Cross-platform mobile UI |
| **Local Database** | Drift (SQLite) | Offline-first persistent storage |
| **Navigation** | GoRouter ^17.1.0 | Declarative routing & deep linking |
| **Connectivity** | connectivity_plus ^7.1.0 | Network interface monitoring |
| **Maps** | flutter_map ^8.2.2 + latlong2 | OpenStreetMap tile rendering |
| **Typography** | Google Fonts (Manrope + Inter) | Premium design system fonts |
| **Localization** | flutter_localizations + intl | Multi-language support |
| **Code Generation** | drift_dev + build_runner | Database DAO generation |
| **State Management** | ChangeNotifier + ListenableBuilder | Lightweight reactive state |

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

### 3. Tasks Screen (Field Assignments)
- Scrollable list of active directives with tactical headers
- System telemetry status cards (encryption status, cache mode)
- Each task card supports full-card tap navigation to details

### 4. Task Details Screen (Tactical Interface)
- **Mission Header**: Project ID, task title, location sector
- **Operational Checklist**: Interactive toggle items with real-time progress tracking
- **Field Evidence Section**: Photo grid with capture button (camera integration stub)
- **Tactical Notes**: Multi-line text input for site observations
- **Sticky Footer**: Elapsed time + completion percentage metrics + submit button

### 5. Create Task Screen
- **Priority Toggle**: Animated HIGH / MED / LOW selector with color feedback
- **Task Title & Protocol**: Free-form input card for task definition
- **Category Picker**: Bottom sheet selector (Field Maintenance, Infrastructure Audit, Sensor Calibration, Emergency Repair, Routine Inspection)
- **Location Display**: Pre-filled zone/sector reference
- **Schedule Card**: Native date and time pickers with blue accent tint
- **Intelligence Attachments**: Media capture and document upload tiles (stubs)
- **"Execute Creation"** button with title validation

### 6. Map Screen
- Full-screen OpenStreetMap tile layer via `flutter_map`
- Marker layer with task location pins
- Interactive zoom and pan controls

### 7. Sync Status Screen (Telemetry View)
- **Sync Progress Card**: Real-time progress bar with percentage, current item description, and Sync Now / Cancel All actions
- **History Card**: Last successful sync timestamp with stability indicator
- **Local Storage Card**: Cached data size display
- **Queue List**: Pending sync items with status indicators (PENDING, UPLOADING, SYNCED, CONFLICT)
- **Resolve Button**: Deep-links to the Conflict Resolution screen for failed items

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
   - Listens to `SyncService.progressStream` for real-time updates
   - Exposes `isOnline`, `isOffline`, `isSyncing`, `pendingItems`, and `conflicts`
   - Auto-triggers sync when connectivity is restored
   - Blocks sync attempts when the device is offline

### Database Schema

| Table | Fields | Purpose |
|-------|--------|---------|
| **Tasks** | id, title, description, lat, lng, status, version, isSynced, updatedAt, createdAt | Core task data |
| **SyncQueue** | id, entityType, entityId, action, payload, status, retryCount, createdAt | Offline change queue |
| **Conflicts** | id, entityId, entityType, localData, serverData, status, createdAt | Unresolved merge conflicts |

---

## 🌐 Real Connectivity Monitoring

InspectSync implements a **two-layer connectivity verification** system:

| Layer | Mechanism | Speed | Accuracy |
|-------|-----------|-------|----------|
| **Layer 1** | `connectivity_plus` (network interface detection) | Instant | Medium — detects WiFi/mobile toggle but not captive portals |
| **Layer 2** | `InternetAddress.lookup('google.com')` (DNS reachability) | ~1-5 sec | High — verifies actual internet access |

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
| `/` | LoginScreen | Root |
| `/dashboard` | MainScreen (with BottomAppBar shell) | Authenticated root |
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
