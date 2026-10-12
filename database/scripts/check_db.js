const { config, getConnection } = require('./db_config');

async function checkDb() {
  console.log('========================================================');
  console.log(`🔍 Kelvin Mech — MySQL Database Health & Status Check`);
  console.log('========================================================');

  const startTime = Date.now();
  let conn;

  try {
    conn = await getConnection();
    const pingLatency = Date.now() - startTime;

    const [[versionRow]] = await conn.query('SELECT VERSION() AS version');
    const [[dbStatus]] = await conn.query('SELECT DATABASE() AS current_db');

    console.log(`🔌 Host:            ${config.host}:${config.port}`);
    console.log(`👤 User:            ${config.user}`);
    console.log(`🗄️ Database:        ${dbStatus.current_db}`);
    console.log(`⚡ MySQL Version:   ${versionRow.version}`);
    console.log(`⏱️ Ping Latency:    ${pingLatency} ms`);
    console.log('--------------------------------------------------------');

    // 1. Tables and Row Counts
    const [tables] = await conn.query(`
      SELECT 
        table_name AS tableName,
        table_rows AS approxRows,
        ROUND((data_length + index_length) / 1024, 2) AS sizeKb,
        engine
      FROM information_schema.tables
      WHERE table_schema = ?
      ORDER BY table_name ASC
    `, [config.database]);

    console.log('📊 Tables Overview:');
    let totalSizeKb = 0;

    for (const t of tables) {
      // Get accurate count
      const [[countRow]] = await conn.query(`SELECT COUNT(*) AS total FROM \`${t.tableName}\``);
      const size = parseFloat(t.sizeKb || 0);
      totalSizeKb += size;

      console.log(
        `  • ${t.tableName.padEnd(25)} : ${String(countRow.total).padStart(5)} rows | ${size.toFixed(1).padStart(7)} KB (${t.engine || t.ENGINE || 'InnoDB'})`
      );
    }

    console.log('--------------------------------------------------------');
    console.log(`📁 Total Tables:     ${tables.length}`);
    console.log(`💾 Total Data Size:  ${totalSizeKb.toFixed(2)} KB`);

    // 2. Migrations check
    try {
      const [migrations] = await conn.query('SELECT version, applied_at FROM schema_migrations ORDER BY version ASC');
      console.log('--------------------------------------------------------');
      console.log(`🚀 Applied Migrations (${migrations.length}):`);
      for (const m of migrations) {
        console.log(`  ✓ ${m.version} (applied: ${new Date(m.applied_at).toLocaleString()})`);
      }
    } catch (_) {
      console.log('ℹ️ No schema_migrations table found.');
    }

    console.log('========================================================');
    console.log('✅ Database is healthy and fully operational!');
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Database health check failed:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

checkDb();
