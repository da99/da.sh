
import { Database } from 'bun:sqlite';

const NOT_UPLOADED = 0
const UPLOADED = 1
const PRUNED = 2

type JSON_FILE = {
  local_path: string,
  public_path: string,
  etag: string,
  created_at: string
}

type FILE_ROW = {
  local_path: string,
  public_path: string,
  etag: string,
  created_at: string,
  status: typeof NOT_UPLOADED | typeof UPLOADED | typeof PRUNED
}

const THE_CMD = Bun.argv.slice(2).join(' ');
const DB_FILE = 'public_files.sqlite';

const PUBLIC_FOLDER = 'Public';

switch (THE_CMD) {
  case "setup":
    await setup();
    break;

  case "upload":
    await setup();
    await cmd(`www write file manifest for ${PUBLIC_FOLDER}`)
    const current_files = await Bun.file("public_files.json").json();
    for (const k in current_files) {
      const f = current_files[k] as JSON_FILE;
      const is_up = await is_uploaded(f);
      if (is_up) {
        console.warn(`--- Already uploaded: ${f}`)
      } else {
        console.warn(`--- Uploading file: ${f}`)
        await upload_file(f);
      }
    }
    break;

  default:
    console.warn(`!!! Unknown command: ${THE_CMD}`)
    process.exit(1);
} // switch

function new_database() {
  const db = new Database(DB_FILE, { create: true });
  db.exec('PRAGMA journal_mode = WAL;');
  return db;
} // function

async function is_uploaded(f: JSON_FILE) {
  const db = new_database();
  const q = db.query(`SELECT local_path FROM files WHERE local_path = $lp;`);
  const row = await q.get({ $lp: f.local_path, $stat: NOT_UPLOADED}) as | FILE_ROW;
  if (!row)
    return false;
  return row.status === UPLOADED;
} // function

async function setup() {
  const db_exists = await Bun.file(DB_FILE).exists();
  if (db_exists) {
    console.warn(`--- File already exists: ${DB_FILE}`);
    return false;
  }
  const db = new_database();
  const raw_meta_sql = await Bun.file('/apps/da.sh/templates/public_file.sql').text();
  const meta_sql = raw_meta_sql.split(/--\ +SPLIT\ +--/);
  for (const q of meta_sql) {
    console.warn(`-- Running: ${q.slice(0,15).trim()}...`)
    console.warn(db.query(q).all());
  }
  return true;
} // function

async function cmd(...raw: string[]) {
  let cmd_args = raw;
  if (cmd_args.length === 1)
    cmd_args = cmd_args[0].trim().split(/\s+/);
  console.warn(`=== ${cmd_args.join(' ')}`);
  return Bun.spawn(cmd_args).exited
}

async function upload_file
