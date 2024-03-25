# frozen_string_literal: true

# Represents a file in the public directory.
class PublicFile
  class << self
    def all(raw_dir)
      dir = normalize_dir(raw_dir)
      PublicFile.dir_exist!(dir)
      `find #{dir} -type f | xargs sha256sum`
        .strip
        .split("\n")
        .map { |l| PublicFile.new(dir, l) }
    end # def

    def normalize_dir(raw)
      raw.sub(%r{^\.?/}, '')
    end

    def dir_exist!(raw)
      dir = normalize_dir(raw)
      unless Dir.exist?(dir)
        warn "!!! Directory not found: #{dir}"
        exit 1
      end
      dir
    end

    def manifest(raw_dir)
      dir = normalize_dir(raw_dir)
      all(dir).inject({}) do |memo, new_file|
        memo[new_file.path.sub(dir, '')] = { 'public_path' => new_file.public_path, 'etag' => new_file.etag[0..8] }
        memo
      end
    end

    def write_manifest(raw_dir)
      json = manifest(raw_dir).to_json
      File.write 'files.mjs', Template.compile('file.mjs', { 'JSON' => json })
      puts '=== Wrote: files.mjs'
      File.write('files.json', json)
      puts '=== Wrote: files.json'
    end
  end # class << self

  attr_reader :dir, :raw, :etag, :path

  def initialize(dir, raw)
    @raw = raw
    @dir = PublicFile.normalize_dir(dir)
    pieces = raw.split
    @etag = pieces.shift
    if pieces.size != 1
      warn "!!! Invalid file path: #{path.join(' ')}"
      exit 2
    end
    @path = pieces.shift
  end # def

  def public_path
    pieces = path.split('.')
    pieces[pieces.size - 1] = "#{etag[0..5]}.#{pieces.last}"
    pieces.join('.').sub(dir, '')
  end

  def summary
    Hash.new(
      'path' => path,
      'dir' => dir,
      'public_path' => public_path,
      'etag' => etag
    )
  end # def
end # class
