require 'date'

def determine_start_date(str_date = nil)
  if str_date
    Date.parse(str_date)
  else
    date = Date.today
    sub = date.cwday == 6 ? 0 : date.wday + 1
    date - (sub + 7)
  end
end

def determine_end_date(start_date)
  start_date + 6
end

def git_repos_in_dir(dir)
  Dir.new(dir).entries.collect do |d|
    repo_dir = File.join(dir, d)
    #`cd #{repo_dir}; git pull`
    repo_dir if File.directory?("#{repo_dir}/.git")
  end.compact
end

def commit_logs(repo, start_date, end_date, email)
  repo_name = File.basename(repo)

  git_params = [
    "--since=\"#{start_date}\"",
    "--until=\"#{end_date}\"",
    "--no-merges",
    "--pretty=format:'%ad [#{repo_name}] - %s'",
    "--author=#{email}",
  ]

  cmd = "cd #{repo}; git log #{git_params * ' '}"
  `#{cmd}`.split("\n")
end
