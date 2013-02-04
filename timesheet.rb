require "rubygems"
require "bundler/setup"

require "selene"
require 'date'
require './lib/calendar_event'
require './lib/git_commit'
require './lib/repo_activity'
require './lib/open_air_client'
require './lib/mapping'
require './lib/open_air_mapping'
require './lib/open_air_mappings'
require './lib/timesheet'
require './lib/util'

require 'pry'
require 'pp'

s   = determine_start_date(ENV['START_DATE'])
e   = determine_end_date(s)
date_range   = (s...e)

y = YAML.load_file('settings.yml')

calendar_dir      = y['calendar']['dir']
email             = y['git']['email']
open_air_settings = y['open_air']
company_id        = open_air_settings['company']
user_id           = open_air_settings['user']
password          = open_air_settings['password']

timesheet = Timesheet.new(date_range.first, date_range.last)

git_repos = y['git']['parent_repos_dir'].collect do |dir|
  git_repos_in_dir(dir)
end.flatten

puts "Fetching activities from #{date_range.first} - #{date_range.last}"

git_repos.each do |repo|
  name = File.basename(repo)
  #puts "Checking #{name}"
  logs = commit_logs(repo, date_range.first, date_range.last, email)
  if logs.length > 0
    puts "[#{name}] #{logs.length} commits found"
    logs.each do |log|
      timesheet.add_activity GitCommit.parse(log)
    end
  end
end

if File.exists?(calendar_dir)
  calendars = Dir.new(calendar_dir).select { |file| file.end_with? ".ics" }
else
  calendars = []
end

calendar_events = calendars.collect do |calendar_file|
  events = CalendarEvent.events_from_ics("#{calendar_dir}/#{calendar_file}")
  events.each do |event|
    if date_range.include?(event.date)
      unless timesheet.has_activity?(event.uuid)
        timesheet.add_activity event
      end
    end
  end
end

puts timesheet.to_s

# client task
# Operations Management | All Hands Meetings
# Engineering -- Operations | Daily Scrum
# Engineering -- Internal Tools | Internal Meetings
# Engineering -- Internal Tools | Development

mappings = OpenAirMappings.new

mappings << OpenAirMapping.new(
  TaskMap.new("operations_management", "Operations Management"),
  ProjectMap.new("all_hands", "All Hands")
)

mappings << OpenAirMapping.new(
  TaskMap.new("other_meetings", "Other Company Meetings"),
  ProjectMap.new("operations_management", "Operations Management")
)

mappings << OpenAirMapping.new(
  TaskMap.new("other_meetings", "Other Company Meetings"),
  ProjectMap.new("internal_tools", "Internal Tools")
)

mappings << OpenAirMapping.new(
  TaskMap.new("internal_tools", "Internal Tools"),
  ProjectMap.new("other_meetings", "Other Company Meetings")
)

mappings << OpenAirMapping.new(
  TaskMap.new("internal_tools", "Internal Tools"),
  ProjectMap.new("development", "Development")
)

timesheet.activities.each do |a|
  mapping = mappings.find_mapping(a)

  if mapping.nil?
    binding.pry
  end

  puts "#{mapping.project_text} - #{mapping.task_text}"
end

client = OpenAirClient.new(company_id, user_id, password, mappings)
client.fillout_timesheet(timesheet)

sleep(10)

client.close

