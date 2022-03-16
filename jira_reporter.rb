#!/usr/bin/env ruby

class JiraReporter

  attr_reader :issues

  def initialize(issues)
    @issues = issues
  end

  def report
    puts report_title
    puts double_line
    issues.each do |issue|
      puts display(issue)
    end
    puts double_line
  end

  def report_title
    title_arr = []
    title_arr << truncpad("Key", 7)
    title_arr << truncpad("Parent Summary", 35)
    title_arr << truncpad("Issue Summary", 60)
    title_arr << truncpad("Assignee", 20)
    title_arr << truncpad("Started", 8)
    title_arr << truncpad("Finished", 8)
    title_arr << truncpad("Status", 20)
    title_arr << "Days Since Start/Cycle Time"
    title_arr.join(separator)
  end

  def display(issue)
    # key | parent_summary | summary | assignee | status | cycle_time_in_days OR days_since_start
    string_arr = []
    string_arr << truncpad(issue.key, 7)
    string_arr << truncpad(issue.parent_summary, 35)
    string_arr << truncpad(issue.summary, 60)
    string_arr << truncpad(issue.assignee, 20)
    string_arr << truncpad(date_display(issue.start_time), 8)
    string_arr << truncpad(date_display(issue.finish_time), 8)
    string_arr << truncpad(issue.status, 20)
    string_arr << days_or_cycle_time(issue)
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

  def days_or_cycle_time(issue)
    issue.done? ? issue.cycle_time_in_days : issue.days_since_start
  end

  def truncpad(el, len = 30)
    trunc(el.to_s, len).ljust(len)
  end

  def trunc(txt, chars)
    dotdot = txt.length > chars ? '...' : ''
    txt[0,chars - dotdot.length] + dotdot
  end
end
