#!/usr/bin/env ruby
# frozen_string_literal: true

THIS_DIR = File.dirname File.dirname($PROGRAM_NAME)

require 'json'
require File.join(THIS_DIR, 'src/Bucket')
require File.join(THIS_DIR, 'src/PublicFile')
require File.join(THIS_DIR, 'src/Template')

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

def run_cmd(s_cmd)
  warn "--- Running: #{s_cmd}"
  `#{s_cmd}`.strip
end

case cmd
when '-h', '--help', 'help'
  puts "#{prog} -h|--help|help  --  Show this message."
  puts "#{prog} upload public [dir] to [bucket]"
  puts "#{prog} write file manifest for [dir]"
  puts "#{prog} set src to [domain]"
  puts "#{prog} build mjs"
  puts "#{prog} info"
  puts "#{prog} serve"

when 'info'
  puts "__FILE__ :     #{__FILE__}"
  puts "file dir:      #{File.dirname __FILE__}"
  puts "templates dir: #{Template::DIR}"
  puts "dir:       #{Dir.pwd}"
  puts "prog:      #{prog}"

when %r{^upload public ([./0-9A-Z]+) to (\w+)$}i
  `touch bucket_files.json`
  dir = Regexp.last_match(1)
  domain = Regexp.last_match(2)
  b = Bucket.new(dir, domain)
  b.upload

when 'build mjs'
  raw_files = `find Public/section -type f -name index.mts`.strip.split("\n")
  case raw_files.size
  when 0
    warn '--- No .mts scripts found.'
  when 1
    raw = raw_files.first
    run_cmd %( bun build "#{raw}" > "#{raw.sub('.mts', '.mjs')}" )
    run_cmd %( rm "#{raw}")
  else
    run_cmd %( bun build Public/section/*/index.mts --splitting --outdir=Public/section --outbase=./ )
    raw_files.each do |x|
      run_cmd "mv #{x.sub('.mts', '.js')} #{x.sub('.mts', '.mjs')}"
      File.unlink(x)
      warn "--- File removed: #{x}"
    end
  end

when %r{^write file manifest for ([./0-9A-Z]+)$}i
  PublicFile.write_manifest(Regexp.last_match(1))

when /^set src to (.+)$/i
  dir = 'dist'
  domain = Regexp.last_match(1)
  manifest = PublicFile.manifest(dir)
  files = `find "#{dir}" -type f -name '*.html'`.strip.split('\n')
  if files.empty?
    puts "--- No files found for: setting #{dir}"
  else
    puts "--- Setting #{dir} to https://#{domain}..."
  end
  files.each do |raw|
    origin = File.read(raw)
    new_body = origin.gsub(/(src|href)="([^"]+)"/) do |match|
      attr = Regexp.last_match(1)
      new_val = manifest[Regexp.last_match(2)]
      if new_val
        %(#{attr}="https://#{File.join domain, new_val['public_path']}")
      else
        match
      end
    end # .gsub
    if origin == new_body
      warn "--- Skipping: #{raw}"
      next
    end
    warn "=== Updated: #{raw}"
    File.write(raw, new_body)
  end # files.each

else
  warn "!!! Unknown command: #{cmd}"
  exit 1
end # case
