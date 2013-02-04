class Timesheet
  attr_reader :start_date, :end_date, :activities

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date   = end_date
    @activities = []
  end

  def add_activity(activity)
    activities << activity
  end

  def activites_by_day
    (start_date...end_date).collect do |date|
      activities_for_date(date)
    end
  end

  def activities_for_date(date)
    activities.select do |a|
      a.date == date
    end
  end

  def has_activity?(uuid)
    activities.any? { |a| a.uuid == uuid }
  end

  def to_s
    activities.sort
  end
end

