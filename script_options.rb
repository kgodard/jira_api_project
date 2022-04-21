class ScriptOptions

  attr_accessor :show_cycle_time, :show_statuses, :statuses, :parents

  def initialize
    @parents         = nil
    @show_cycle_time = nil
    @show_statuses   = nil
    @statuses        = nil
  end
end
