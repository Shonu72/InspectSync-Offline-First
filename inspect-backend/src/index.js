require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const errorHandler = require('./middleware/errorHandler');
const ApiError = require('./utils/ApiError');
const syncWorker = require('./workers/sync-jobs.worker'); // Start BullMQ worker

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(morgan('dev'));

// Routes
const authRoutes = require('./routes/auth.routes');
const taskRoutes = require('./routes/task.routes');
const syncRoutes = require('./routes/sync.routes');
const mediaRoutes = require('./routes/media.routes');

app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/sync', syncRoutes);
app.use('/api/media', mediaRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'UP', timestamp: new Date() });
});

app.get("/", (req, res) => {
  res.send(`
    <html>
      <head>
        <title>InspectSync API</title>
        <style>
          body {
            font-family: Arial;
            background: #0f172a;
            color: #e2e8f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
          }
          .card {
            background: #1e293b;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
          }
          h1 { color: #38bdf8; }
          p { margin: 10px 0; }
          a {
            color: #22c55e;
            text-decoration: none;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>🚀 InspectSync API</h1>
          <p>Status: <strong>Running</strong></p>
          <p><a href="/health">Check Health</a></p>
          <p>Version: 1.0</p>
        </div>
      </body>
    </html>
  `);
});

// 404 handler
app.use((req, res, next) => {
  next(new ApiError(404, 'Not found'));
});

// Global Error Handler
app.use(errorHandler);

app.listen(port, () => {
  console.log(`[InspectSync] Server running at http://localhost:${port}`);
});
