class Mapping
  def initialize(activity_name, openair_name)
    @activity_name = activity_name
    @openair_name = openair_name
  end

  def mapped?(name)
    name == @activity_name
  end

  def name
    @openair_name
  end
end

class TaskMap < Mapping
end

class ProjectMap < Mapping
end
