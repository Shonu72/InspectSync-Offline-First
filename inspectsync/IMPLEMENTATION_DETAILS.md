# InspectSync Implementation Details

This document outlines the architecture, data structures, and core logic of the InspectSync application, reflecting its transition to a robust, offline-first data management system with integrated conflict resolution.

## 1. Project Overview
InspectSync is a field-service application designed for "Precision Field" operations. It emphasizes data integrity, offline functionality, and seamless synchronization between local field edits and server-side records.

## 2. Tech Stack
- **Framework**: Flutter (Dart)
- **Database**: [Drift](file:///Users/shouryasonu/Development/inspectSync/inspectsync/lib/core/db/app_database.dart) (Post-generation SQLite using `NativeDatabase`)
- **Navigation**: [GoRouter](file:///Users/shouryasonu/Development/inspectSync/inspectsync/lib/main.dart) 
- **State Management**: [ChangeNotifier](file:///Users/shouryasonu/Development/inspectSync/inspectsync/lib/features/sync/presentation/providers/sync_controller.dart) (SyncController) with `ListenableBuilder`
- **Design System**: "Obsidian Command" aesthetics (Dark Mode supported)

## 3. Core Architecture
The project follows a feature-based layer architecture:

- **Core**: Contains shared resources (Database, Theme, l10n).
- **Features**:
  - `auth`: Login, device authentication.
  - `sync`: Core logic for queue management, conflict resolution, and sync progress.
  - `tasks`: Task list, details, and repository bridging local/remote data.
  - `dashboard`: Main navigation hub and summary statistics.

## 4. Data Layer & Persistence
Managed via `AppDatabase` in `lib/core/db/`, using three primary tables:

- **Tasks**: Stores local copies of inspection tasks.
- **SyncQueue**: A transaction log of local edits (actions: 'create', 'update') pending server upload.
- **Conflicts**: Stores mismatched data between local and server versions until manually resolved.

## 5. Sync & Conflict Resolution Logic

### 5.1. Sync Controller
The `SyncController` serves as the primary gateway for the UI:
- **`loadData()`**: Refreshes both the pending queue and the conflict map in real-time.
- **`progressStream`**: Subscribes to `SyncService` for live progress updates (percentage, current item).

### 5.2. Conflict Detection
Implemented in `ConflictResolver`:
1. Compares local payload vs. server response field-by-field.
2. Ignores technical metadata (e.g., `version`, `updatedAt`).
3. If a mismatch is detected, the queue item is marked as `failed`, and a record is inserted into the `conflicts` table.

### 5.3. Navigation & Resolution
- **Sync Status Screen**: Displays a live list of the queue. If an item is in conflict, a "RESOLVE" button appears.
- **Resolution Flow**:
  - Tapping "RESOLVE" fetches the `Conflict` record from the DB.
  - User redirects to `ConflictResolutionScreen`.
  - User performs side-by-side selection for each field.
  - Upon commit, the conflict is marked as `resolved`.

## 6. Navigation Structure
- **Persistent Bottom Nav**: Managed by `MainScreen` using an `IndexedStack` containing Dashboard, Map, Tasks, and Sync.
- **Integrated Sync Tab**: The Sync dashboard is no longer a separate page but a first-class tab in the application.
- **Deep Routing**: Supports direct navigation to conflict details via `/sync/conflict/:id`.

---
> [!NOTE]
> All local changes are stored in the `SyncQueue` first. The `SyncService` then processes this queue sequentially to maintain order and data integrity.

> [!IMPORTANT]
> The current theme is set to **Dark Mode** as of the latest workspace configuration in `main.dart`.
