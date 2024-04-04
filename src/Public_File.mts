
import { Database } from 'bun:sqlite';

const cmd = Bun.argv.slice(2).join(' ');
const DB_FILE = 'public_files.sqlite';

switch (cmd) {
  case "setup":
    const db_exists = await Bun.file(DB_FILE).exists();
    if (db_exists) {
      console.warn(`!!! File already exists: ${DB_FILE}`);
      // process.exit(1);
    }
    const db = new_database();
    const raw_meta_sql = await Bun.file('/apps/da.sh/templates/public_file.sql').text();
    const meta_sql = raw_meta_sql.split(/--\ +SPLIT\ +--/);
    for (const q of meta_sql) {
      console.warn(`-- Running: ${q.slice(0,15).trim()}...`)
      console.warn(db.query(q).all());
    }
    break;

  default:
    console.warn(`!!! Unknown command: ${cmd}`)
    process.exit(1);
}

function new_database() {
    const db = new Database(DB_FILE, { create: true });
    db.exec('PRAGMA journal_mode = WAL;');
    return db;
}
