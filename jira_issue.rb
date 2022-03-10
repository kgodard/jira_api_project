#!/usr/bin/env ruby

# require 'jira-ruby'

class JiraIssue

  attr_reader :key, :client, :created, :summary, :description, :status, :fields, :histories,
    :assignee, :type, :raw, :subtasks, :parent

  def initialize(jira_issue)
    load_issue(jira_issue)
  end

  def display
    # key | parent_summary | summary | assignee | status | cycle_time_in_days OR days_since_start
    string_arr = []
    string_arr << truncpad(key, 7)
    string_arr << truncpad(parent_summary)
    string_arr << truncpad(summary, 50)
    string_arr << truncpad(assignee, 20)
    string_arr << truncpad(status, 20)
    string_arr << days_or_cycle_time
    string_arr.join(separator)
  end

  def separator
    ' | '
  end

  def days_or_cycle_time
    done? ? cycle_time_in_days : days_since_start
  end

  def truncpad(el, len = 30)
    trunc(el.to_s, len).ljust(len)
  end

  def trunc(txt, chars)
    dotdot = txt.length > chars ? '...' : ''
    txt[0,chars - dotdot.length] + dotdot
  end

  def done?
    !finish_time.nil?
  end

  def days_since_start
    ((Time.now - start_time) / 86400).round(1) rescue nil
  end

  def cycle_time_in_days
    if finish_time.nil?
      nil
    else
      ((finish_time - start_time) / 86400).round(1) rescue nil
    end
  end

  def start_time
    get_time_of_status_change("In Progress")
  end

  def finish_time
    get_time_of_status_change("Done") rescue nil
  end

  def get_time_of_status_change(status)
    change = find_status_change(status)
    Time.parse change[:created]
  end

  def find_status_change(status)
    status_changes.detect {|sc| sc[:status] == status}
  end

  def status_changes
    status_histories.map do |hist|
      { author: hist["author"]["displayName"],
        created: hist["created"],
        status: hist["items"].first["toString"] }
    end
  end

  def parent_type
    parent["fields"]["issuetype"]["name"]
  end

  def status_histories
    histories.select {|hist| hist["items"].map {|i| i["field"]}.include?("status")}
  end

  def parent_summary
    parent["fields"]["summary"] rescue nil
  end

  def load_issue(jira_issue)
    if jira_issue.nil?
      raise "JIRA issue #{key} was not found!"
    else
      @raw         = jira_issue
      @key         = jira_issue.key
      @type        = jira_issue.issuetype.name
      @assignee    = jira_issue.assignee.displayName rescue nil
      @created     = jira_issue.created
      @summary     = jira_issue.summary
      @description = jira_issue.description
      @status      = jira_issue.status.name
      @fields      = jira_issue.fields
      @histories   = jira_issue.changelog["histories"]
      @subtasks    = jira_issue.subtasks
      @parent      = jira_issue.parent rescue nil
    end
  end
end
