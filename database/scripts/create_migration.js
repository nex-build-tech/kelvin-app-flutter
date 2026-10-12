const fs = require('fs');
const path = require('path');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'migrations');

const nameArg = process.argv.slice(2).join('_').trim().toLowerCase().replace(/[^a-z0-9_]/g, '');

if (!nameArg) {
  console.log('Usage: node create_migration.js <migration_name>');
  console.log('Example: node create_migration.js add_vendor_ratings');
  process.exit(1);
}

if (!fs.existsSync(MIGRATIONS_DIR)) {
  fs.mkdirSync(MIGRATIONS_DIR, { recursive: true });
}

// Determine next index number
const existing = fs
  .readdirSync(MIGRATIONS_DIR)
  .filter((f) => f.endsWith('.sql'))
  .sort();

let nextNum = 1;
if (existing.length > 0) {
  const lastFile = existing[existing.length - 1];
  const match = lastFile.match(/^(\d+)_/);
  if (match) {
    nextNum = parseInt(match[1], 10) + 1;
  }
}

const prefix = String(nextNum).padStart(3, '0');
const filename = `${prefix}_${nameArg}.sql`;
const filePath = path.join(MIGRATIONS_DIR, filename);

const template = `-- ============================================================================
-- Migration: ${prefix}_${nameArg}
-- Created At: ${new Date().toISOString()}
-- ============================================================================

-- Up
-- Write your forward DDL statements here:
-- Example:
-- ALTER TABLE \`projects\` ADD COLUMN \`budget_code\` VARCHAR(50) DEFAULT NULL;


-- Down
-- Write your reverse / rollback DDL statements here:
-- Example:
-- ALTER TABLE \`projects\` DROP COLUMN \`budget_code\`;
`;

fs.writeFileSync(filePath, template, 'utf8');

console.log('========================================================');
console.log(`✨ Created new migration: database/migrations/${filename}`);
console.log('========================================================');
console.log('Edit the file and run:');
console.log('  npm run db:migrate');
