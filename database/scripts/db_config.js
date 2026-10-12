const path = require('path');
const fs = require('fs');

// Ensure packages installed in backend/node_modules are resolvable from database/scripts/
const backendNodeModules = path.join(__dirname, '..', '..', 'backend', 'node_modules');
if (fs.existsSync(backendNodeModules)) {
  module.paths.push(backendNodeModules);
}

const mysql = require('mysql2/promise');

// Look for .env in backend/ or current dir
const envPathBackend = path.join(__dirname, '..', '..', 'backend', '.env');
const envPathRoot = path.join(__dirname, '..', '..', '.env');

if (fs.existsSync(envPathBackend)) {
  require('dotenv').config({ path: envPathBackend });
} else if (fs.existsSync(envPathRoot)) {
  require('dotenv').config({ path: envPathRoot });
} else {
  require('dotenv').config();
}

const config = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '12345678',
  database: process.env.DB_NAME || 'kelvin_mech_db',
  multipleStatements: true,
};

let pool = null;

function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      ...config,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });
  }
  return pool;
}

async function getConnectionWithoutDb() {
  const { database, ...serverConfig } = config;
  return await mysql.createConnection(serverConfig);
}

async function getConnection() {
  return await mysql.createConnection(config);
}

module.exports = {
  config,
  getPool,
  getConnection,
  getConnectionWithoutDb,
};
