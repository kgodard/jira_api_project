class JiraCycleTimesReporter
  include DisplayHelpers

  attr_reader :jirasearch, :upto

  def initialize(jirasearch, upto: "Done")
    @jirasearch = jirasearch
    @upto       = upto
  end

  def render
    puts issue_count
    puts single_line
    puts report_title
    puts single_line
    puts report_headings
    puts single_line
    display_cycle_times
    puts single_line
  end

  def report_title
    "Average Cycle Times"
  end

  def issue_count
    "Total Issues: #{jirasearch.issues.size}"
  end

  def report_headings
    head_arr = []
    head_arr << truncpad("Status", 22)
    head_arr << truncpad("Avg Cycle Time (Days)", 21)
    head_arr.join(separator)
  end

  def cycle_time_line(item)
    line_arr = []
    line_arr << truncpad(item[:status], 22)
    line_arr << truncpad(item[:average_cycle_time], 21)
    line_arr.join(separator)
  end

  def display_cycle_times
    jirasearch.status_cycle_times(upto: upto).each do |item|
      puts cycle_time_line(item)
    end
  end

  def single_line
    '-' * report_headings.length
  end
end
