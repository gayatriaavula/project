const express = require('express');
const mysql = require('mysql2/promise');

function createApp(db) {
  const app = express();
  app.disable('x-powered-by');
  app.locals.db = db;

  app.get('/api/health', async (req, res) => {
    try {
      const [rows] = await req.app.locals.db.query('SELECT NOW() AS now');
      res.json({ status: 'ok', time: rows[0].now });
    } catch (error) {
      console.error('Health check failed', error);
      res.status(500).json({ status: 'error', message: error.message });
    }
  });

  app.get('/api/visitors', async (req, res) => {
    try {
      await req.app.locals.db.query('INSERT INTO visitors () VALUES ()');
      const [rows] = await req.app.locals.db.query('SELECT id, visited_at FROM visitors ORDER BY id DESC LIMIT 10');
      res.json({ visitors: rows });
    } catch (error) {
      console.error('Visitor query failed', error);
      res.status(500).json({ status: 'error', message: error.message });
    }
  });

  app.get('/', (req, res) => {
    res.send('Sample backend is running. Use /api/health or /api/visitors');
  });

  return app;
}

/* c8 ignore start */
async function initDatabase() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'appuser',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'sampledb',
    port: Number.parseInt(process.env.DB_PORT || '3306', 10),
    waitForConnections: true,
    connectionLimit: 5,
  });
  await pool.query(`CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`);
  return pool;
}

if (require.main === module) {
  if (!process.env.DB_PASSWORD) {
    console.error('DB_PASSWORD environment variable is required');
    process.exit(1);
  }
  const port = process.env.PORT || 3000;
  initDatabase()
    .then((pool) => {
      const app = createApp(pool);
      app.listen(port, () => {
        console.log(`Backend API listening on port ${port}`);
      });
    })
    .catch((error) => {
      console.error('Unable to initialize database connection', error);
      process.exit(1);
    });
}
/* c8 ignore end */

module.exports = { createApp };
