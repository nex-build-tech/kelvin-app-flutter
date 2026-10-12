const fs = require('fs');
const path = require('path');
const { config, getConnection } = require('./db_config');

const FIXTURES_DIR = path.join(__dirname, '..', 'fixtures');

async function importFixtures() {
  console.log('========================================================');
  console.log(`📥 Importing JSON Fixtures into MySQL -> ${config.database}`);
  console.log(`📁 Source Directory: database/fixtures/`);
  console.log('========================================================\n');

  if (!fs.existsSync(FIXTURES_DIR)) {
    console.error(`❌ No fixtures directory found at: ${FIXTURES_DIR}`);
    process.exit(1);
  }

  const files = fs
    .readdirSync(FIXTURES_DIR)
    .filter((f) => f.endsWith('.json'))
    .sort();

  if (files.length === 0) {
    console.log('ℹ️ No JSON fixture files found to import.');
    return;
  }

  let conn;

  try {
    conn = await getConnection();
    await conn.query('SET FOREIGN_KEY_CHECKS = 0');

    for (const file of files) {
      const table = file.replace(/\.json$/, '');
      const content = fs.readFileSync(path.join(FIXTURES_DIR, file), 'utf8');
      const rows = JSON.parse(content);

      if (!Array.isArray(rows) || rows.length === 0) {
        console.log(`  - ${file}: empty (skipped)`);
        continue;
      }

      const columns = Object.keys(rows[0]);
      const columnNames = columns.map((c) => `\`${c}\``).join(', ');
      const placeholders = columns.map(() => '?').join(', ');
      const sql = `INSERT IGNORE INTO \`${table}\` (${columnNames}) VALUES (${placeholders})`;

      let inserted = 0;
      for (const row of rows) {
        const values = columns.map((col) => {
          const val = row[col];
          if (val && typeof val === 'string' && val.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)) {
            return new Date(val);
          }
          return val;
        });
        await conn.query(sql, values);
        inserted++;
      }

      console.log(`  ✓ Imported ${String(inserted).padStart(3)} rows into \`${table}\``);
    }

    await conn.query('SET FOREIGN_KEY_CHECKS = 1');
    console.log('\n========================================================');
    console.log(`🎉 All JSON fixtures imported into MySQL successfully!`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Failed to import fixtures:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

if (require.main === module) {
  importFixtures();
}

module.exports = importFixtures;
