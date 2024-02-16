#!/usr/bin/env ruby
# frozen_string_literal: true

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

case cmd
when '-h', '--help', 'help'
  puts "#{prog} -h|--help|help  --  Show this message."
  puts "#{prog} every [time] [command]"
when /every (.+) .+/
  time = ARGV[1]
  command = ARGV[2..-1]
  while 
  puts "#{time} ---> #{command}"
else
  warn "!!! Unknown command: #{cmd}"
  exit 1
end # case
