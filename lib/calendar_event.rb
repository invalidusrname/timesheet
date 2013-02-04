require 'time'
require 'date'

class CalendarEvent
  include Comparable

  attr_reader :summary, :start_time, :end_time

  def initialize(summary, start_time, end_time)
    @summary    = summary
    @start_time = start_time
    @end_time   = end_time
  end

  def date
    start_time.to_date
  end

  def duration_in_minutes
  ((end_time - start_time) / 60).to_i
  end

  def uuid
    "#{summary} - #{date}"
  end

  def project_type
    if summary.include? 'Staff Meeting'
      'operations_management'
    elsif summary.include? 'Tech Lunch'
      'internal_tools'
    else
      'internal_tools'
    end
  end

  def task_type
    if summary.include? 'Staff Meeting'
      'other_meetings'
    else
      'internal_meetings'
    end
  end

  def notes
    "Meeting"
  end

  def timestamp
    DateTime.parse(start_time.to_s)
  end

  def <=>(another)
    timestamp <=> another.timestamp
  end

  def to_s
    "[meeting] #{start_time} - #{end_time} - #{summary}"
  end

  def to_note
    "[meeting] #{summary}"
  end

  def self.events_from_ics(ics_file)
    ical = Selene.parse(File.read(ics_file))
    ical["vcalendar"].first["vevent"].collect do |event|
      begin
        start_time = Time.parse(event["dtstart"].first)
        end_time   = Time.parse(event["dtend"].first)

        new(event["summary"], start_time, end_time)
      rescue ArgumentError => e
        nil # bad time given. whatever
      end
    end.compact
  end
end
