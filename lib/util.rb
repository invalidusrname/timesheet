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

def git_repos_in_dir(dir, pull_changes = true)
  Dir.new(dir).entries.collect do |repo_dir|
    full_repo_path = File.join(dir,repo_dir)
    full_repo_path if File.directory?(File.join(full_repo_path, '.git'))
  end.compact
end

def update_repo_dir(dir)
  `cd #{dir}; git pull origin master`
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
