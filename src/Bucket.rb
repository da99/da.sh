#!/usr/bin/env ruby
# frozen_string_literal: true

# Manage a files for a Bucket.
class Bucket
  class << self
    def file_json
      'bucket_files.json'
    end
  end # class << self

  attr_reader :dir, :files, :bucket

  def initialize(raw_dir, bucket)
    @bucket = bucket
    @dir = PublicFile.normalize_dir(raw_dir)

    `touch "#{self.class.file_json}"`
    txt = File.read(self.class.file_json).strip
    @files = txt.empty? ? [] : JSON.parse(txt)
  end # def

  def upload_file(new_file)
    cmd = %( bunx wrangler r2 object put "#{File.join(bucket, new_file.public_path)}" --file="#{new_file.path}" )
    puts "\n--- Uploading: #{cmd}"
    exit(1) unless system(cmd)
    new_file.summary
  end

  def upload
    old_etags = files.map { |x| x['etag'] }

    summarys = PublicFile.all(dir).map do |new_file|
      upload_file(new_file) unless old_etags.include?(new_file.etag)
    end

    return false if summarys.empty?

    @files.concat(summarys)
    puts "=== Finished uploading. Saving to: #{self.class.file_json}"
    File.write(self.class.file_json, @files.to_json)
  end # def
end # class

if $PROGRAM_NAME == __FILE__
  cmd = $ARGV.join(' ')
  case cmd
  when %r{^upload public ([./0-9A-Z]+) to (\w+)$}i
    `touch bucket_files.json`
    dir = Regexp.last_match(1)
    domain = Regexp.last_match(2)
    b = Bucket.new(dir, domain)
    b.upload

  when %r{^write file manifest for ([./0-9A-Z]+)$}i
    PublicFile.write_manifest(Regexp.last_match(1))


  else
    warn "!!! Unknown command: #{cmd}"
    exit 1
  end
end
