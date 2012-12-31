#!/usr/bin/env ruby

require 'date'

`./timesheet.bash`

commits = File.readlines("timesheet.txt")

days = {}

commits.each do |commit|
  app = commit[/\[.*\]/].to_s.strip
  msg = commit.split("]")[1].to_s.strip[2..-1]
  date = Date.parse(commit.split("[").first.to_s.strip)

  unless days.has_key?(date.to_s)
    days[date.to_s] = {}
  end

  unless days[date.to_s].has_key?(app)
    days[date.to_s][app] = []
  end

  days[date.to_s][app] << msg
end

days.each do |date, apps|
  puts date
  puts "=" * date.length
  apps.each do |app, commits|
    puts app
    commits.each do |commit|
      puts "  #{commit}"
    end
  end
end

