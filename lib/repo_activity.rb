class RepoActivity
  attr_reader :repo, :commits

  def initialize(repo, commits)
    @repo = repo
    @commits = commits
  end
end

