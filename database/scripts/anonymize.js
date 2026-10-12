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

async function anonymizeAndExport() {
  console.log('========================================================');
  console.log(`🔒 Kelvin Mech — Data Anonymization & Sanitized Export`);
  console.log(`🛡️ Compliance: Masks PII (Emails, Phones, Names)`);
  console.log('========================================================\n');

  if (!fs.existsSync(BACKUP_DIR)) {
    fs.mkdirSync(BACKUP_DIR, { recursive: true });
  }

  const now = new Date();
  const timestamp = now.toISOString().replace(/[-:]/g, '').replace('T', '_').slice(0, 15);
  const outputFile = path.join(BACKUP_DIR, `sanitized_${config.database}_${timestamp}.sql`);
  const writeStream = fs.createWriteStream(outputFile, { encoding: 'utf8' });

  writeStream.write(`-- ========================================================\n`);
  writeStream.write(`-- SANITIZED / ANONYMIZED DATABASE DUMP\n`);
  writeStream.write(`-- Safe for Development, QA, and Third-Party Sharing\n`);
  writeStream.write(`-- Created: ${now.toISOString()}\n`);
  writeStream.write(`-- ========================================================\n\n`);
  writeStream.write(`SET FOREIGN_KEY_CHECKS = 0;\n\n`);

  let conn;

  try {
    conn = await getConnection();
    const [tables] = await conn.query('SHOW FULL TABLES WHERE Table_type = "BASE TABLE"');
    const tableNames = tables.map((t) => Object.values(t)[0]);

    for (const table of tableNames) {
      writeStream.write(`-- Table: \`${table}\`\n`);
      writeStream.write(`DROP TABLE IF EXISTS \`${table}\`;\n`);

      const [[createResult]] = await conn.query(`SHOW CREATE TABLE \`${table}\``);
      writeStream.write(`${createResult['Create Table']};\n\n`);

      const [rows] = await conn.query(`SELECT * FROM \`${table}\``);

      if (rows.length > 0) {
        const columns = Object.keys(rows[0]).map((c) => `\`${c}\``).join(', ');

        for (let i = 0; i < rows.length; i++) {
          const row = { ...rows[i] };

          // Mask PII in users table
          if (table === 'users') {
            row.name = `Engineer ${i + 1}`;
            row.email = `engineer_${i + 1}@kelvinmech.local`;
            row.phone = `+91 98000 ${String(10000 + i)}`;
            row.password = '$2b$10$eDummyHashedPasswordForDevEnvironment00';
          }

          // Mask PII in follow_ups
          if (table === 'follow_ups') {
            row.contact_name = `Client Rep ${i + 1}`;
            row.phone = `+91 97000 ${String(20000 + i)}`;
          }

          const values = Object.values(row).map(formatSqlValue).join(', ');
          writeStream.write(`INSERT INTO \`${table}\` (${columns}) VALUES (${values});\n`);
        }
        writeStream.write(`\n`);
      }
      console.log(`  ✓ Sanitized & dumped: \`${table}\``);
    }

    writeStream.write(`SET FOREIGN_KEY_CHECKS = 1;\n`);
    writeStream.end();

    const stats = fs.statSync(outputFile);
    console.log('\n========================================================');
    console.log(`✅ Sanitized export generated successfully!`);
    console.log(`📁 File: database/backups/${path.basename(outputFile)}`);
    console.log(`📦 Size: ${(stats.size / 1024).toFixed(2)} KB`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Sanitization failed:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

if (require.main === module) {
  anonymizeAndExport();
}

module.exports = anonymizeAndExport;
