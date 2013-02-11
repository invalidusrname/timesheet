class CommitDay
  attr_reader :date, :commits

  def initialize(date)
    @date = date
    @commits = []
  end

  def add_commit(git_commit)
    @commits << git_commit if git_commit.date == date
  end

  def duration
    min, max = @commits.minmax_by { |c| c.timestamp }

    if min && max
      diff = max.timestamp - min.timestamp
      (diff * 24 * 60).to_i
    end
  end
end

