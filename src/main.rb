#!/usr/bin/env ruby

NODEJS_URL        = 'https://nodejs.org'
NODEJS_INDEX_JSON = "#{NODEJS_URL}/dist/index.json"
ARCH = "linux-x64";

require "net/http"
require "json"

cmd = ARGV.join(' ')

def node_latest_version
  uri = URI(NODEJS_INDEX_JSON)
  json = JSON.parse Net::HTTP.get(uri)
  latest = json.find { |x| 
    x['files'].include? ARCH
  }
  if latest
    return latest['version']
  end
end


case cmd
when 'node latest'
  latest = node_latest_version
  if latest
    puts latest
    exit 0
  end
  exit 1

when 'node latest remote file'
  latest = node_latest_version
  puts File.join(NODEJS_URL, 'dist', latest, "node-#{latest}-#{ARCH}.tar.xz" )

when 'node is latest'
  current = `node --version`.strip
  latest = node_latest_version
  puts latest
  if current == latest
    exit 0
  end
  exit 1
else
  STDERR.puts "!!! Not found: #{ARGV.map(&:inspect).join ' '}"
  exit 1
end
