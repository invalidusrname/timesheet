class TimesheetPrinter

  def initialize(timesheet)
    @timesheet = timesheet
  end

  def to_s(tags = true)
    @timesheet.activites_by_day.each do |date, activities|

      commit_day = CommitDay.new(date)

      activities.each do |activity|
        commit_day.add_commit(activity) if activity.is_a? GitCommit
      end

      if tags
        s = "<br/>"
      else
        s = ""
      end

      puts s
      puts "#{commit_day.date} -- #{(commit_day.duration / 60.0).round(2) if commit_day.duration} #{s}"
      puts s

      commit_day.by_repo.each do |repo, git_commits|
        if git_commits.size > 0
          puts "[#{repo}]#{s}"
          puts git_commits.collect { |c| "-- #{filter_bad_words(c.msg)}#{s}" }
        end
      end
    end
  end

  def filter_bad_words(msg)
    msg.gsub(/(shit|damn|fuck|fucking)/, "****")
  end
end
