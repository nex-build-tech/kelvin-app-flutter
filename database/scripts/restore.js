const fs = require('fs');
const path = require('path');
const { config, getConnection } = require('./db_config');

const BACKUP_DIR = path.join(__dirname, '..', 'backups');

async function restore() {
  console.log('========================================================');
  console.log(`♻️ Starting Database Restore -> ${config.database}`);
  console.log('========================================================');

  let targetFile = process.argv[2];

  if (!targetFile) {
    if (!fs.existsSync(BACKUP_DIR)) {
      console.error('❌ No backups directory found at database/backups/');
      process.exit(1);
    }

    const files = fs
      .readdirSync(BACKUP_DIR)
      .filter((f) => f.endsWith('.sql'))
      .sort()
      .reverse();

    if (files.length === 0) {
      console.error('❌ No .sql backup files found in database/backups/');
      process.exit(1);
    }

    targetFile = path.join(BACKUP_DIR, files[0]);
    console.log(`Using latest backup: ${files[0]}`);
  } else {
    if (!path.isAbsolute(targetFile)) {
      targetFile = path.resolve(process.cwd(), targetFile);
    }
  }

  if (!fs.existsSync(targetFile)) {
    console.error(`❌ Specified backup file not found: ${targetFile}`);
    process.exit(1);
  }

  const conn = await getConnection();
  const sql = fs.readFileSync(targetFile, 'utf8');

  console.log(`Reading SQL from: ${path.basename(targetFile)}...`);
  const startTime = Date.now();

  try {
    await conn.query(sql);
    const duration = Date.now() - startTime;
    console.log('========================================================');
    console.log(`✅ Restore completed successfully (${duration}ms)!`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Restore failed:', err.message);
  } finally {
    await conn.end();
  }
}

restore();
