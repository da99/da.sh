
CREATE TABLE IF NOT EXISTS `files` (
  `public_path`  STRING NOT NULL PRIMARY KEY,
  `local_path`   STRING NOT NULL,
  `etag`         STRING CHECK (len(etag) > 5),
  `created_at`   INTEGER CHECK (date_created > 1712272096),
  `status`       INTEGER DEFAULT 0 CHECK (status < 3 AND status > -1)
);

-- STATUS:
--   0: NOT UPLOADED
--   1: UPLOADED
--   2: PRUNED/DELETED

-- SPLIT --

CREATE INDEX IF NOT EXISTS idx_local_path
  ON `files` (local_path, version_path);


