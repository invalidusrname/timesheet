class OpenAirMapping
  attr_reader :project, :task

  def initialize(project_map, task_map)
    @project = project_map
    @task    = task_map
  end

  def mapped?(activity)
    matches_project?(activity) && matches_task?(activity)
  end

  def matches_project?(activity)
    project.mapped?(activity.project_type)
  end

  def matches_task?(activity)
    task.mapped?(activity.task_type)
  end

  def project_text
    project.name
  end

  def task_text
    task.name
  end
end

