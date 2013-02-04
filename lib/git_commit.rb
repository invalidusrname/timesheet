require 'date'

class GitCommit
  include Comparable

  attr_reader :repo, :msg, :date, :datetime

  def initialize(repo, msg, datetime)
    @repo = repo
    @msg  = msg
    @datetime = datetime
  end

  def notes
    msg
  end

  def uuid
    "#{repo} - #{msg} - #{@datetime}"
  end

  def date
    @datetime.to_date
  end

  def timestamp
    @datetime
  end

  def <=>(another)
    timestamp <=> another.timestamp
  end

  def project_type
    'internal_tools'
  end

  def task_type
    'development'
  end

  def to_note
    "[#{repo}] - #{msg}"
  end

  def to_s
    "[#{repo}] #{datetime} - #{msg}"
  end

  def self.parse(str)
    #"Mon Jan 28 21:37:17 2013 +0000 [puppet] - add akrimax_pap to QA"]
    datetime = DateTime.parse(str.split(" [").first)
    repo     = str.split("[").last.split("] - ").first
    msg      = str.split("[").last.split("] - ").last

    new(repo, msg, datetime)
  end
end
