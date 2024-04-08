#!/usr/bin/env ruby
# frozen_string_literal: true

cmd = ARGV.join(' ')
# prog = __FILE__.split('/').last

def get_memory
  @mem ||= begin
             total, avail = `cat /proc/meminfo | grep -P "MemTotal|MemAvail" | tr -s ' ' | cut -d' ' -f2`.strip.split
             { total: total.to_f, avail: avail.to_f }
           end
end

MEM_RATIO = 0.6
def memory_ok?
  mem = get_memory
  (mem[:avail] / mem[:total]).to_i < MEM_RATIO
end

def memory_report
  puts "Memory available: #{((get_memory[:avail] / get_memory[:total]) * 100).to_i}%"
end

def ok?
  memory_ok? && network_ok? && cpu_ok?
end

def network_status
  @network_status ||= begin
                        raw = `da.sh ping time`.strip
                        if raw != "ERROR"
                          raw.split.first.to_i
                        else
                          raw
                        end
                      end
end

def network_ok?
  network_status != 'ERROR' && network_status < 100
end

def network_report
  if network_status == 'ERROR'
    puts 'Network probably down.'
  elsif network_status < 50
    puts "Network is ok: #{network_status} ms"
  else
    puts "Network is slow: #{network_status} ms"
  end
end

def cpu_usage
  @cpu_usage ||= 100 - `vmstat 1 2|tail -1|awk '{print $15}'`.strip.to_i
end

def cpu_ok?
  cpu_usage < 50
end

def cpu_report
  puts "CPU usage: #{cpu_usage}%"
end

case cmd
when 'system report'
  memory_report
  network_report
  cpu_report
when 'system is ok'
  exit 0 if ok?
  exit 1
else
  warn "!!! Unknown command: #{cmd}"
  exit 1
end # case
