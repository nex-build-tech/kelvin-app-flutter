const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'kelvin_mech_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 10000,
});

// Test connection on startup
async function testConnection() {
  try {
    const conn = await pool.getConnection();
    console.log(`[MySQL] Connected successfully to '${process.env.DB_NAME || 'kelvin_mech_db'}' on ${process.env.DB_HOST}:${process.env.DB_PORT || 3306}`);
    conn.release();
    return true;
  } catch (err) {
    console.error(`[MySQL Connection Error] Could not connect to MySQL: ${err.message}`);
    console.warn(`[MySQL Tip] Ensure MySQL80 service is running and credentials in backend/.env are correct.`);
    return false;
  }
}

module.exports = { pool, testConnection };
