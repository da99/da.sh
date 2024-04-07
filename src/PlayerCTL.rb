#!/usr/bin/env ruby
# frozen_string_literal: true
require 'forwardable'

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

class PlayerCTL
  PLAYER_MEMO = '/tmp/my.media.memo.txt'

  # === class self
  #
  attr_reader :streams

  def initialize
    @streams = `playerctl --list-all`.strip.split("\n").map { |x| Stream.new(x) }
  end

  def stopped?
    !playing? && File.exist?(PLAYER_MEMO)
  end

  def playing?
    streams.any?(&:playing?)
  end

  def stop
    streams.map do |s|
      next unless s.playing?

      if s.name[/^chrom/]
        s.pause
      else
        s.stop
      end
      $stdout.puts "Stopped: #{s.name}"
      File.write(PLAYER_MEMO, s.name)
    end
  end

  def pause
    streams.map do |s|
      next unless s.playing?

      s.pause
      $stdout.puts "Paused: #{s.name}"
      File.write(PLAYER_MEMO, s.name)
    end
  end

  def last_stream
    return nil unless File.exist?(PLAYER_MEMO)

    File.read(PLAYER_MEMO).strip
  end

  def play
    target = last_stream
    return nil unless target

    warn target
    streams.map do |s|
      next unless s.name == target

      s.play
      $stdout.puts "Playing again: #{s.name}"
      File.unlink(PLAYER_MEMO)
    end
  end

  class Stream
    attr_reader :name

    def initialize(raw_name)
      @name = raw_name
    end

    def cmd(raw_cmd)
      new_cmd = "playerctl --player=#{name} #{raw_cmd}".strip
      warn new_cmd
      `#{new_cmd}`.strip
    end

    def status
      cmd('status')
    end

    def play
      cmd('play')
    end

    def playing?
      status == 'Playing'
    end

    def stopped?
      status == 'Stopped'
    end

    def pause
      cmd('pause')
    end

    def stop
      cmd('stop')
    end
  end

  # === class
end
# === class
#
case cmd
when 'status'
  PlayerCTL.new.streams.map { |x| puts "#{x.name}: #{x.status}" }
when 'list'
  PlayerCTL.new.streams.map { |x| puts x.name }
when 'play'
  PlayerCTL.new.play
when 'pause'
  PlayerCTL.new.pause
when 'stop'
  PlayerCTL.new.stop
when 'is playing'
  if PlayerCTL.new.playing?
    exit(0)
  else
    exit(1)
  end
when 'is stopped'
  if PlayerCTL.new.stopped?
    exit(0)
  else
    exit(1)
  end
else
  warn "!!! Unknown command: #{cmd}"
  exit 1
end # case
