#!/usr/bin/env ruby

class JiraReporter

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
    puts report_title
    puts double_line
    sorted_issues.each do |issue|
      puts display(issue)
    end
    puts double_line
  end

  def report_title
    title_arr = []
    title_arr << truncpad("Key", 7)
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
    string_arr << truncpad(issue.key, 7)
    string_arr << truncpad(issue.type, 7)
    string_arr << truncpad(issue.parent_key + ' ' + issue.parent_summary, 35)
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

  def separator
    ' | '
  end

#   def days_or_cycle_time(issue)
#     issue.done? ? issue.cycle_time_in_days : issue.days_since_start
#   end

  def truncpad(el, len = 30)
    trunc(el.to_s, len).ljust(len)
  end

  def trunc(txt, chars)
    dotdot = txt.length > chars ? '...' : ''
    txt[0,chars - dotdot.length] + dotdot
  end
end
