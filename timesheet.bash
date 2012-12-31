#!/bin/bash
set -e

work_dirs="$DEV_BOX/apps $DEV_BOX/gems"
email=`git config user.email`
start_date="1 week ago"
end_date="today"
timesheet=$PWD/timesheet.txt

touch $timesheet
cat /dev/null > $timesheet

for repo_subfolder in $work_dirs; do
  for git_repo in $repo_subfolder/*
  do
    if [ -d $git_repo ]; then
      cd $git_repo
      repo=`basename $git_repo`
      FORMAT="%ad [$repo] - %s"
      LOG_PARAMS=("--no-merges" "--pretty=format:$FORMAT" "--author=$email" "--since='$start_date' --until='$end_date'")
      if [[ -n `git log "${LOG_PARAMS[@]}"` ]]; then
        echo "" >> $timesheet
        git log "${LOG_PARAMS[@]}" >> $timesheet
      fi
    fi
  done
done

if [[ -f $timesheet ]]; then
  sort $timesheet -o $timesheet
  sed -i "" -e "1d" $timesheet
  cat $timesheet
fi

