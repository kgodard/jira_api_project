class JiraReporter
  include DisplayHelpers

  attr_reader :issues, :sort_by, :show_cycle_time

  def initialize(issues)
    @issues = issues
  end

  def sorted_issues
    return issues if sort_by.nil?
    issues.sort_by {|i| [i.send(sort_by.to_sym) ? 0 : 1,i.send(sort_by.to_sym) || 0]}
  end

  def report(sort_by: nil, show_cycle_time: false)
    @sort_by = sort_by
    @show_cycle_time = show_cycle_time
    puts double_line
    puts report_title
    puts double_line
    sorted_issues.each do |issue|
      puts display(issue)
    end
    puts double_line
  end

  def report_title
    title_arr = []
    title_arr << truncpad("Key", 8)
    title_arr << truncpad("Type", 7)
    title_arr << truncpad("Parent", 35)
    title_arr << truncpad("Issue Summary", 60)
    title_arr << truncpad("Assignee", 20)
    title_arr << truncpad("Started", 8)
    title_arr << truncpad("Finished", 8)
    title_arr << truncpad("Status", 22)
    title_arr << truncpad("Days Since Start", 16) unless show_cycle_time
    title_arr << truncpad("Cycle Time - (#{issues.first.finish_status})", 40) if show_cycle_time
    title_arr.join(separator)
  end

  def display(issue)
    # key | parent_summary | summary | assignee | status | cycle_time_in_days OR days_since_start
    string_arr = []
    string_arr << truncpad(issue.key, 8)
    string_arr << truncpad(issue.type, 7)
    string_arr << truncpad(issue.parent_key.to_s + ' ' + issue.parent_summary.to_s, 35)
    string_arr << truncpad(issue.summary, 60)
    string_arr << truncpad(issue.assignee, 20)
    string_arr << truncpad(date_display(issue.start_time), 8)
    string_arr << truncpad(date_display(issue.finish_time), 8)
    string_arr << truncpad(issue.status, 22)
    string_arr << truncpad(issue.days_since_start, 16) unless show_cycle_time
    string_arr << truncpad(issue.cycle_time_in_days, 40) if show_cycle_time
    string_arr.join(separator)
  end

  def date_display(atime)
    atime.strftime("%x") rescue ""
  end

  def double_line
    '=' * report_title.length
  end
end
