

CREATE TABLE IF NOT EXISTS `files` (
  `version_path` STRING NOT NULL PRIMARY KEY,
  `local_path`   STRING NOT NULL,
  `date_created` INTEGER CHECK (date_created > 1712272096),
  `status`       INTEGER DEFAULT 0 CHECK (status < 4 AND status > -1)
);

-- SPLIT --

CREATE INDEX IF NOT EXISTS idx_local_path
  ON `files` (local_path, version_path);


-- STATUS:
--   0: NOT UPLOADED
--   1: UPLOADED
--   2: PRUNED/DELETED
