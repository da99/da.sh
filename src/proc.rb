#!/usr/bin/env ruby

require "open3"

pid = false
puts "Process pid #{Process.pid}"
Signal.trap("INT") do
  Process.kill("INT", pid) if pid
end
Signal.trap("TERM") do
  Process.kill("INT", pid) if pid
end

def reload_genmon(id)
  puts "Reloading: #{id}"
  `xfce4-panel --plugin-event=genmon-#{id}:refresh:bool:true`
end

cmd  = ARGV.dup
genmon = cmd.shift
puts cmd.inspect

Open3.popen2(*cmd) do |i, o, status_thread|
  puts "#{cmd.first} PID: #{status_thread.pid}"
  pid = status_thread.pid
  o.each_line { |line|
    puts "--- #{line}"
    reload_genmon(genmon)
  }
  puts "ended: #{status_thread.value.success?.inspect}"
end

puts "Done."
