#!/usr/bin/env ruby
#
#
cmd = ARGV.join(" ")
prog = __FILE__.split('/').last

case cmd
when "-h", "--help", "help"
  puts "#{prog} -h|--help|help  --  Show this message."
else
  STDERR.puts "!!! Unknown command: #{cmd}"
  exit 1
end # case

