require_relative '../../lib/commit_day'
require_relative '../../lib/git_commit'

describe CommitDay do

  before do
    @date = Date.parse('2012-01-01')
    @commit_day = CommitDay.new(@date)
  end

  it "holds the date" do
    @commit_day.date.should eq(@date)
  end

  context "no commits" do
    it "knows there's no commits" do
      @commit_day.commits.size.should eq(0)
    end

    it "has no duration" do
      @commit_day.duration.should be(nil)
    end
  end

  context "1 commit" do
    it "knows there's 1 commit" do
      datetime = DateTime.parse("2012-01-01 12:00:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)

      @commit_day.add_commit(gc)
      @commit_day.commits.size.should eq(1)
    end

    it "rejects commits not from the provided day" do
      datetime = DateTime.parse("2012-01-02 12:00:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)

      @commit_day.add_commit(gc)
      @commit_day.commits.size.should be(0)
    end

    it "does not have a duration" do
      datetime = DateTime.parse("2012-01-01 12:00:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)

      @commit_day.add_commit(gc)

      @commit_day.duration.should eq(0)
    end
  end

  context "2 commits" do
    before do
      datetime = DateTime.parse("2012-01-01 8:00:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)
      @commit_day.add_commit(gc)

      datetime = DateTime.parse("2012-01-01 12:15:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)

      @commit_day.add_commit(gc)

      @duration = 255
    end

    it "knows there's 2 commits" do
      @commit_day.commits.size.should eq(2)
    end

    it "has a duration" do
      @commit_day.duration.should eq(@duration)
    end
  end

  context "3 commits" do
    before do
      datetime = DateTime.parse("2012-01-01 9:00:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)
      @commit_day.add_commit(gc)

      datetime = DateTime.parse("2012-01-01 8:00:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)
      @commit_day.add_commit(gc)

      datetime = DateTime.parse("2012-01-01 13:15:00")
      gc = GitCommit.new('some_repo', 'test_commit', datetime)

      @commit_day.add_commit(gc)

      @duration = 315
    end

    it "knows there's 3 commits" do
      @commit_day.commits.size.should eq(3)
    end

    it "has a duration" do
      @commit_day.duration.should eq(@duration)
    end
  end
end

