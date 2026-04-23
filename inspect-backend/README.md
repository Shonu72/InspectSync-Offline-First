# InspectSync Backend

> **Synchronized Field Operations API** — The authoritative source of truth for the InspectSync offline-first platform.

This is the Node.js REST API providing synchronization, authentication, and task management services for the InspectSync mobile application. It is designed with an "optimistic offline" philosophy, supporting version-based conflict detection and batch data syncing.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Runtime** | Node.js (Express v5) |
| **Database** | PostgreSQL |
| **ORM** | Prisma (Type-safe, auto-migrations) |
| **Cloud Storage** | **AWS S3** (Private Media) |
| **Auth** | JWT (JSON Web Tokens) |
| **Hashing** | BcryptJS (Password security) |
| **Validation** | Express-Validator |
| **Logging** | Morgan |
| **Presigned URLs** | AWS SDK v3 |

---

## 🏗️ Architecture & Structure

The project follows a **Service-Controller-Route** pattern for clean separation of concerns.

```
inspectsync-backend/
├── prisma/
│   ├── schema.prisma       # Database models (User, Task, SyncLog)
│   └── seed.js             # Initial dev data (engineer acc + sample tasks)
├── src/
│   ├── index.js            # Server entry point
│   ├── config/
│   │   └── db.js           # Prisma Client singleton
│   ├── controllers/        # Request/Response handlers
│   ├── middleware/         # Auth, Error handling, Security
│   ├── routes/             # API route definitions
│   ├── services/           # Business logic & DB operations
│   └── utils/              # Shared utilities (ApiError, etc.)
└── .env                    # Environment variables (DB URL, JWT Secret)
```

---

## 🔑 Core Features

### 1. Robust Authentication
- **Secure Onboarding**: Hashed password storage and email validation.
- **Stateless Sessions**: JWT-based identity management.
- **Admin/Engineer Roles**: Foundation for role-based access control.

### 2. Task Lifecycle Management
- **Full CRUD**: API endpoints for all field operation phases.
- **Version Tracking**: Every task and entity has a `version` integer. The server auto-increments this on every change, enabling robust conflict detection.

### 3. Advanced Offline Sync Engine
- **`GET /api/sync/pull`**: Delta-based updates. Pull only what changed since the client's last synchronization timestamp.
- **`POST /api/sync/push`**: Batch processing. Submit a list of offline changes (creates and updates) in a single atomic transaction.
- **Secure GET Pre-signing**: The `SyncService` automatically transforms static S3 URLs into time-limited **Presigned GET URLs** (24h expiry) during the pull phase, ensuring secure access to private media.

### 4. Secure Media Cloud (AWS S3)
- **Private-by-Default**: The media bucket is configured with "Block all public access".
- **Presigned PUT**: The `/api/media/presigned-url` endpoint generates authorized upload links for the mobile client.
- **Media Persistence**: Task attachments are stored as a comma-separated list of S3 keys/URLs in the PostgreSQL `images` field.

---

## 📡 API Documentation

### Auth Module (`/api/auth`)
- `POST /register`: Create a new account.
- `POST /login`: authenticate and receive a JWT.
- `GET /me`: Get current user profile (requires Auth header).

### Task Module (`/api/tasks`)
- `GET /`: List all tasks (supports filters for status/priority).
- `GET /:id`: Get specific task details.
- `POST /`: Create a new field directive.
- `PUT /:id`: Update task data (requires `version` for safety).
- `DELETE /:id`: Remove a task record.

### Sync Engine (`/api/sync`)
- **GET /pull?since={timestamp}**: Pull latest changes. Automatically signs media URLs.
- **POST /push**: Push a batch of client logs (CREATE/UPDATE/DELETE).

### Media Module (`/api/media`)
- **POST /presigned-url**: Generates a secure PUT URL for uploading images directly to S3.
    *   Payload: `{ "fileName": "example.jpg", "fileType": "image/jpeg" }`
    *   Returns: `{ "url": "...", "key": "..." }`

---

## 🚀 Getting Started

### 1. Installation
```bash
npm install
```

### 2. Database Configuration
Copy `.env.example` to `.env` and provide your PostgreSQL connection string:
```bash
DATABASE_URL="postgresql://user:password@localhost:5432/inspectsync?schema=public"
JWT_SECRET="your_secure_secret_here"

# AWS S3 Configuration
AWS_ACCESS_KEY_ID="AKIA..."
AWS_SECRET_ACCESS_KEY="..."
AWS_REGION="ap-south-1"
AWS_BUCKET_NAME="inspectsync-media-bucket"
```

### 3. Initialize Database
Connects to your DB, creates tables, and generates the Prisma client.
```bash
npx prisma db push
```

### 3b. Visual Database Management
Launch the Prisma Studio GUI to view/edit tasks and users:
```bash
npx prisma studio --url "postgresql://postgres:postgres@localhost:5432/inspectsync"
```

### 4. Seed Data (Optional)
Populate your database with a test engineer and sample tasks.
```bash
npm run db:seed
```
*Credentials: `engineer@inspectsync.com` / `password123`*

### 5. Run Server
```bash
# Development (with nodemon)
npm run dev

# Production
npm start
```

---

## ⚠️ Important Considerations

- **XAMPP Users**: XAMPP usually provides MySQL/MariaDB. This backend is configured for **PostgreSQL**. You will need to install PostgreSQL (via Homebrew or Postgres.app) to use it as-is, or modify the `provider` in `schema.prisma`.
- **CORS**: Currently enabled for all origins (`*`) in development. Restrict this in `src/index.js` for production deployments.
- **Versioning**: Ensure the mobile app increments local versions correctly to avoid persistent conflict loops.
