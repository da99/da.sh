#!/usr/bin/env ruby

require "open3"

def reload_genmon(id)
  puts "Reloading: #{id}"
  `xfce4-panel --plugin-event=genmon-#{id}:refresh:bool:true`
end

xtitle_genmon = ARGV.first
player_genmon = ARGV.last

puts "xitle: #{xtitle_genmon} player: #{player_genmon}"

fork do
  Open3.popen2('playerctl', '--follow', 'status') do |i, o, status_thread|
    puts "playerctl PID: #{status_thread.pid}"
    o.each_line { |line|
      puts "--- #{line}"
      reload_genmon(player_genmon)
    }
    puts "ended: #{status_thread.value.success?.inspect}"
  end
end

Open3.popen2('xtitle', '-s') do |i, o, status_thread|
  puts "xtitle PID: #{status_thread.pid}"
  o.each_line { |line|
    puts "--- #{line}"
    reload_genmon(xtitle_genmon)
  }
  puts "ended: #{status_thread.value.success?.inspect}"
end

puts "Done."
