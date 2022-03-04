#!/usr/bin/env ruby

require 'jira-ruby'

class JiraIssue

  attr_reader :key, :client, :created, :summary, :description, :status, :fields, :histories

  def initialize(key:, options: default_options)
    @key = key
    @client = JIRA::Client.new(options)
    fetch_and_load
  end

  def cycle_time_in_days
    if finish_time.nil?
      nil
    else
      ((finish_time - start_time) / 86400).round(1)
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

  def status_histories
    histories.select {|hist| hist["items"].map {|i| i["field"]}.include?("status")}
  end

  def fetch_and_load
    load_issue(jira_fetch)
  end

  def load_issue(jira_issue)
    if jira_issue.nil?
      raise "JIRA issue #{key} was not found!"
    else
      @created     = jira_issue.created
      @summary     = jira_issue.summary
      @description = jira_issue.description
      @status      = jira_issue.status.name
      @fields      = jira_issue.fields
      @histories   = jira_issue.changelog["histories"]
    end
  end

  def jira_fetch
    response = client.Issue.jql("key = #{key}", {expand: 'changelog'})
    response.first rescue nil
  end

  def default_options
    { username: 'kim.godard@snapdocs.com',
      password: ENV["JIRA_TOKEN"],
      site: 'http://snapdocs-eng.atlassian.net:443/',
      context_path: '',
      auth_type: :basic }
  end
end
