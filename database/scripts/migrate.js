const fs = require('fs');
const path = require('path');
const { config, getConnectionWithoutDb, getConnection } = require('./db_config');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'migrations');

async function ensureDatabaseAndTable() {
  // 1. Ensure database exists
  const serverConn = await getConnectionWithoutDb();
  await serverConn.query(
    `CREATE DATABASE IF NOT EXISTS \`${config.database}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
  );
  await serverConn.end();

  // 2. Ensure migration tracking table exists
  const dbConn = await getConnection();
  await dbConn.query(`
    CREATE TABLE IF NOT EXISTS \`schema_migrations\` (
      \`version\` VARCHAR(150) NOT NULL PRIMARY KEY,
      \`name\` VARCHAR(255) NOT NULL,
      \`applied_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  `);
  return dbConn;
}

function parseMigrationFile(content) {
  const lines = content.split('\n');
  let currentSection = null;
  const upLines = [];
  const downLines = [];

  for (const line of lines) {
    const trimmed = line.trim().toLowerCase();
    if (trimmed.startsWith('-- up')) {
      currentSection = 'up';
      continue;
    } else if (trimmed.startsWith('-- down')) {
      currentSection = 'down';
      continue;
    }

    if (currentSection === 'up') {
      upLines.push(line);
    } else if (currentSection === 'down') {
      downLines.push(line);
    } else {
      // If no '-- Up' header found at beginning, default to up
      upLines.push(line);
    }
  }

  return {
    upSql: upLines.join('\n').trim(),
    downSql: downLines.join('\n').trim(),
  };
}

async function getAppliedMigrations(conn) {
  const [rows] = await conn.query('SELECT version, name, applied_at FROM schema_migrations ORDER BY version ASC');
  return rows;
}

function getMigrationFiles() {
  if (!fs.existsSync(MIGRATIONS_DIR)) return [];
  return fs
    .readdirSync(MIGRATIONS_DIR)
    .filter((f) => f.endsWith('.sql'))
    .sort();
}

async function runUp() {
  console.log('========================================================');
  console.log(`📦 Running Database Migrations (UP) -> ${config.database}`);
  console.log('========================================================');

  const conn = await ensureDatabaseAndTable();
  const applied = await getAppliedMigrations(conn);
  const appliedSet = new Set(applied.map((a) => a.version));
  const files = getMigrationFiles();

  let count = 0;
  for (const file of files) {
    const version = file.replace(/\.sql$/, '');
    if (appliedSet.has(version)) {
      continue;
    }

    console.log(`⏳ Applying: ${file}...`);
    const filePath = path.join(MIGRATIONS_DIR, file);
    const content = fs.readFileSync(filePath, 'utf8');
    const { upSql } = parseMigrationFile(content);

    const startTime = Date.now();
    try {
      if (upSql.length > 0) {
        await conn.query(upSql);
      }
      await conn.query('INSERT INTO schema_migrations (version, name) VALUES (?, ?)', [version, file]);
      const duration = Date.now() - startTime;
      console.log(`✅ Applied:  ${file} (${duration}ms)`);
      count++;
    } catch (err) {
      console.error(`❌ Migration failed on ${file}:`, err.message);
      await conn.end();
      process.exit(1);
    }
  }

  if (count === 0) {
    console.log('✨ All migrations are already up to date.');
  } else {
    console.log(`🎉 Successfully applied ${count} migration(s).`);
  }

  await conn.end();
}

async function runDown() {
  console.log('========================================================');
  console.log(`⏪ Rolling Back Last Migration (DOWN) -> ${config.database}`);
  console.log('========================================================');

  const conn = await ensureDatabaseAndTable();
  const applied = await getAppliedMigrations(conn);

  if (applied.length === 0) {
    console.log('ℹ️ No migrations currently applied to roll back.');
    await conn.end();
    return;
  }

  const lastApplied = applied[applied.length - 1];
  const file = `${lastApplied.version}.sql`;
  const filePath = path.join(MIGRATIONS_DIR, file);

  if (!fs.existsSync(filePath)) {
    console.error(`❌ Migration file ${file} not found on disk.`);
    await conn.end();
    process.exit(1);
  }

  console.log(`⏳ Rolling back: ${file}...`);
  const content = fs.readFileSync(filePath, 'utf8');
  const { downSql } = parseMigrationFile(content);

  if (!downSql || downSql.length === 0) {
    console.error(`⚠️ No '-- Down' section found in ${file}. Rollback aborted.`);
    await conn.end();
    process.exit(1);
  }

  const startTime = Date.now();
  try {
    await conn.query(downSql);
    await conn.query('DELETE FROM schema_migrations WHERE version = ?', [lastApplied.version]);
    const duration = Date.now() - startTime;
    console.log(`✅ Rolled back: ${file} (${duration}ms)`);
  } catch (err) {
    console.error(`❌ Rollback failed on ${file}:`, err.message);
    await conn.end();
    process.exit(1);
  }

  await conn.end();
}

async function runStatus() {
  console.log('========================================================');
  console.log(`📋 Migration Status -> ${config.database}`);
  console.log('========================================================');

  const conn = await ensureDatabaseAndTable();
  const applied = await getAppliedMigrations(conn);
  const appliedMap = new Map(applied.map((a) => [a.version, a.applied_at]));
  const files = getMigrationFiles();

  if (files.length === 0) {
    console.log('ℹ️ No migration files found in database/migrations/');
    await conn.end();
    return;
  }

  for (const file of files) {
    const version = file.replace(/\.sql$/, '');
    if (appliedMap.has(version)) {
      const date = new Date(appliedMap.get(version)).toLocaleString();
      console.log(`  [APPLIED]  ${file.padEnd(35)} (at: ${date})`);
    } else {
      console.log(`  [PENDING]  ${file.padEnd(35)}`);
    }
  }

  console.log('========================================================');
  console.log(`Total: ${files.length} | Applied: ${applied.length} | Pending: ${files.length - applied.length}`);

  await conn.end();
}

const command = (process.argv[2] || 'up').toLowerCase();

switch (command) {
  case 'up':
    runUp();
    break;
  case 'down':
    runDown();
    break;
  case 'status':
    runStatus();
    break;
  default:
    console.log(`Unknown command: '${command}'. Available: up, down, status`);
    process.exit(1);
}
