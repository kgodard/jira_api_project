#!/usr/bin/env ruby

class JiraReporter

  attr_reader :issues

  def initialize(issues)
    @issues = issues
  end

  def report
    issues.each do |issue|
      puts display(issue)
    end
  end

  def display(issue)
    # key | parent_summary | summary | assignee | status | cycle_time_in_days OR days_since_start
    string_arr = []
    string_arr << truncpad(issue.key, 7)
    string_arr << truncpad(issue.parent_summary)
    string_arr << truncpad(issue.summary, 50)
    string_arr << truncpad(issue.assignee, 20)
    string_arr << truncpad(issue.status, 20)
    string_arr << days_or_cycle_time(issue)
    string_arr.join(separator)
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
