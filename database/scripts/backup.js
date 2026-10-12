const fs = require('fs');
const path = require('path');
const { config, getConnection } = require('./db_config');

const BACKUP_DIR = path.join(__dirname, '..', 'backups');

function formatSqlValue(val) {
  if (val === null || val === undefined) return 'NULL';
  if (typeof val === 'number') return val;
  if (typeof val === 'boolean') return val ? 1 : 0;
  if (val instanceof Date) {
    return `'${val.toISOString().slice(0, 19).replace('T', ' ')}'`;
  }
  const str = String(val).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
  return `'${str}'`;
}

async function backup() {
  console.log('========================================================');
  console.log(`💾 Starting Database Backup -> ${config.database}`);
  console.log('========================================================');

  if (!fs.existsSync(BACKUP_DIR)) {
    fs.mkdirSync(BACKUP_DIR, { recursive: true });
  }

  const conn = await getConnection();

  const now = new Date();
  const timestamp = now
    .toISOString()
    .replace(/[-:]/g, '')
    .replace('T', '_')
    .slice(0, 15);
  const backupFileName = `backup_${config.database}_${timestamp}.sql`;
  const backupFilePath = path.join(BACKUP_DIR, backupFileName);

  const writeStream = fs.createWriteStream(backupFilePath, { encoding: 'utf8' });

  writeStream.write(`-- ========================================================\n`);
  writeStream.write(`-- Kelvin Mech Database Backup\n`);
  writeStream.write(`-- Database: ${config.database}\n`);
  writeStream.write(`-- Created At: ${now.toISOString()}\n`);
  writeStream.write(`-- ========================================================\n\n`);
  writeStream.write(`SET FOREIGN_KEY_CHECKS = 0;\n\n`);

  try {
    const [tables] = await conn.query('SHOW FULL TABLES WHERE Table_type = "BASE TABLE"');
    const tableNames = tables.map((t) => Object.values(t)[0]);

    console.log(`Found ${tableNames.length} tables to dump.`);

    for (const table of tableNames) {
      console.log(`  Exporting table: ${table}...`);
      writeStream.write(`-- --------------------------------------------------------\n`);
      writeStream.write(`-- Table structure for table \`${table}\`\n`);
      writeStream.write(`-- --------------------------------------------------------\n`);
      writeStream.write(`DROP TABLE IF EXISTS \`${table}\`;\n`);

      const [[createResult]] = await conn.query(`SHOW CREATE TABLE \`${table}\``);
      writeStream.write(`${createResult['Create Table']};\n\n`);

      const [rows] = await conn.query(`SELECT * FROM \`${table}\``);
      if (rows.length > 0) {
        writeStream.write(`-- Dumping data for table \`${table}\` (${rows.length} rows)\n`);
        const columns = Object.keys(rows[0]).map((c) => `\`${c}\``).join(', ');

        for (const row of rows) {
          const values = Object.values(row).map(formatSqlValue).join(', ');
          writeStream.write(`INSERT INTO \`${table}\` (${columns}) VALUES (${values});\n`);
        }
        writeStream.write(`\n`);
      }
    }

    writeStream.write(`SET FOREIGN_KEY_CHECKS = 1;\n`);
    writeStream.write(`-- Dump completed at ${new Date().toISOString()}\n`);
    writeStream.end();

    const stats = fs.statSync(backupFilePath);
    console.log('========================================================');
    console.log(`✅ Backup successfully created!`);
    console.log(`📁 File: database/backups/${backupFileName}`);
    console.log(`📦 Size: ${(stats.size / 1024).toFixed(2)} KB`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Backup failed:', err.message);
  } finally {
    await conn.end();
  }
}

backup();
