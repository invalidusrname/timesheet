class OpenAirMappings
  attr_reader :mappings

  def initialize
    @mappings = []
  end

  def <<(mapping)
    mappings << mapping
  end

  def find_mapping(activity)
    mappings.detect { |m| m.mapped?(activity) }
  end
end
