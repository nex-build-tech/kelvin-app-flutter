const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function setupDatabase() {
  const host = process.env.DB_HOST || 'localhost';
  const port = parseInt(process.env.DB_PORT || '3306', 10);
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const dbName = process.env.DB_NAME || 'kelvin_mech_db';

  console.log('====================================================');
  console.log(' Kelvin Mech — Automated MySQL Database Initializer');
  console.log('====================================================');
  console.log(`Connecting to MySQL host: ${host}:${port} as user: '${user}'...`);

  let connection;
  try {
    connection = await mysql.createConnection({
      host,
      port,
      user,
      password,
      multipleStatements: true,
    });
    console.log('✅ Connection established with MySQL Server!');
  } catch (err) {
    console.error('❌ Failed to connect to MySQL:', err.message);
    console.log('\n[Help]: Please verify the password in backend/.env:');
    console.log('DB_PASSWORD=your_actual_password');
    process.exit(1);
  }

  try {
    // 1. Run schema.sql
    const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
    console.log(`Reading schema from: ${schemaPath}`);
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    console.log(`Creating database '${dbName}' and tables...`);
    await connection.query(schemaSql);
    console.log('✅ All 8 tables created successfully!');

    // 2. Run seed.sql
    const seedPath = path.join(__dirname, '..', 'database', 'seed.sql');
    console.log(`Reading seed data from: ${seedPath}`);
    const seedSql = fs.readFileSync(seedPath, 'utf8');

    console.log('Populating initial MEP operations seed data...');
    await connection.query(seedSql);
    console.log('✅ Initial seed data inserted successfully!');

    // 3. Verify row counts
    await connection.query(`USE \`${dbName}\`;`);
    const [users] = await connection.query('SELECT COUNT(*) as cnt FROM users');
    const [projects] = await connection.query('SELECT COUNT(*) as cnt FROM projects');
    const [approvals] = await connection.query('SELECT COUNT(*) as cnt FROM approvals');
    const [followups] = await connection.query('SELECT COUNT(*) as cnt FROM follow_ups');

    console.log('====================================================');
    console.log(' Database Summary:');
    console.log(`  - Users:        ${users[0].cnt}`);
    console.log(`  - Projects:     ${projects[0].cnt}`);
    console.log(`  - Approvals:    ${approvals[0].cnt}`);
    console.log(`  - Follow-ups:   ${followups[0].cnt}`);
    console.log('====================================================');
    console.log('🎉 Database initialization complete! Ready for backend server.');
  } catch (err) {
    console.error('❌ Error executing database script:', err.message);
  } finally {
    if (connection) await connection.end();
  }
}

setupDatabase();
