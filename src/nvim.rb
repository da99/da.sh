#!/usr/bin/env ruby

require "net/http"
require "json"
require 'fileutils'

SOURCE_URL = "https://api.github.com/repos/neovim/neovim/releases/latest"
ARCH = "linux-x64";
HOME_BIN = "#{ENV['HOME']}/bin"
LATEST = JSON.parse(Net::HTTP.get(URI(SOURCE_URL)))
NVIM_VERSION_TXT = 'nvim.version.txt'

cmd = ARGV.join(' ')


def latest_version
  LATEST['target_commitish']
end

def latest?
  Dir.chdir(HOME_BIN) {
    current = (File.read(NVIM_VERSION_TXT) rescue '')
    return current.strip == latest_version.strip
  }
end

def remote_file
  LATEST['assets'].find { |x| x['name'] == 'nvim.appimage' }['browser_download_url']
end


case cmd
when 'nvim latest'
  puts latest_version

when 'nvim latest remote file'
  puts remote_file

when 'nvim is latest'
  exit 0 if latest?
  exit 1

when 'nvim install latest'
  if latest?
    Dir.chdir(HOME_BIN) {
      puts File.read(NVIM_VERSION_TXT)
    }
    exit(0) 
  end
  Dir.chdir(HOME_BIN)
  download_url = remote_file
  new_file_name = File.basename(download_url)

  FileUtils.rm(new_file_name, :force => true)
  FileUtils.rm('nvim', :force => true)
  File.open(new_file_name, 'wb') { |f| 
    f.write Net::HTTP.get(URI(download_url))
  }
  File.write(NVIM_VERSION_TXT, "#{latest_version}\n")
  FileUtils.mv(new_file_name, 'nvim')
else
  STDERR.puts "!!! Not found: #{ARGV.map(&:inspect).join ' '}"
  exit 1
end
