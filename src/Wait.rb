#!/usr/bin/env ruby
# frozen_string_literal: true
def wait_until(hour, mer)
  hour += 12 if mer == 'PM'
  now = Time.now
  wait_secs = 59 - now.sec
  wait_mins = 59 - now.min
  wait_hours = if hour < now.hour
                 24 - (hour - now.hour)
               elsif hour == now.hour
                 24
               else
                 hour - now.hour
               end

  if wait_secs.positive?
    wait_mins -= 1
  else
    wait_secs = 0
  end

  if wait_mins.positive?
    wait_hours -= 1
  else
    wait_mins = 0
  end

  wait_hours = 0 if wait_hours.negative?

  puts "Waiting: Hour: #{wait_hours}, Mins: #{wait_mins}, Secs: #{wait_secs}"
  sleep((60 * 60 * wait_hours) + (60 * wait_mins) + wait_secs)
end
# === def

if $PROGRAM_NAME == __FILE__
  cmd = ARGV.join(' ')
  prog = __FILE__.split('/').last

  case cmd
  when '-h', '--help', 'help'
    puts "#{prog} -h|--help|help  --  Show this message."

  when /every ([0-9]{1,2})(AM|PM|am|pm) (.+)/
    hour = Regexp.last_match(1).to_i
    mer = Regexp.last_match(2).upcase
    cmd = Regexp.last_match(3)
    puts "Hour: #{hour}, MER: #{mer}, CMD: #{cmd.inspect}"
    loop do
      wait_until hour, mer
      puts "--- Running @ #{Time.now}"
      system(cmd)
      puts $?.inspect
      sleep 61
    end
  when /wait until ([0-9]{1,2})(AM|PM|am|pm)/
    hour = Regexp.last_match(1).to_i
    mer = Regexp.last_match(2).upcase
    wait_until(hour, mer)
    puts "It is now: #{Time.now}"
  else
    warn "!!! Unknown command: #{cmd}"
    exit 1
  end
  # === case
end
# === if
