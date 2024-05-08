#!/usr/bin/env ruby
# frozen_string_literal: true


if $PROGRAM_NAME == __FILE__
  cmd = ARGV.join(' ')
  prog = __FILE__.split('/').last

  case cmd
  when '-h', '--help', 'help'
    puts "#{prog} -h|--help|help  --  Show this message."
  when /wait until ([0-9])(AM|PM|am|pm)/
    hour = Regexp.last_match(1).to_i
    mer = Regexp.last_match(2).upcase
    hour += 12 if mer == 'PM'
    now = Time.now
    wait_mins = 59 - now.min
    wait_hours = if hour < now.hour
                   24 - (hour - now.hour)
                 else
                   hour - now.hour
                 end
    if wait_mins.positive?
      wait_hours -= 1
      puts "Waiting: Mins: #{wait_mins} Hour: #{wait_hours}"
      sleep(60 * wait_mins)
    else
      puts "Waiting: Hour: #{wait_hours}"
    end
    sleep(60 * 60 * wait_hours)
  else
    warn "!!! Unknown command: #{cmd}"
    exit 1
  end
  # === case
end
# === if
