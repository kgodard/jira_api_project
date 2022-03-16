#!/usr/bin/env ruby

require 'jira-ruby'
require './jira_issue.rb'

class JiraSearch

  attr_reader :client, :search_string, :search_options, :search_results, :issues,
              :project, :issue_types, :start_time, :status, :skipped_parents

  def initialize(project: default_search_project,
                 issue_types: default_search_issue_types,
                 start_time: default_search_start_time,
                 status: default_search_status,
                 skipped_parents: default_search_skipped_parents,
                 search_options: default_search_options,
                 client_options: default_client_options)
    @client          = JIRA::Client.new(client_options)
    @project         = project
    @issue_types     = issue_types
    @start_time      = start_time
    @status          = status
    @skipped_parents = skipped_parents
    @search_options  = search_options
    @issues          = []
    perform_search
    load_options
  end

  def load_options
    search_results.each do |result|
      issues << JiraIssue.new(result)
    end
  end

  def average_cycle_time
    cycle_times = issues.map(&:cycle_time_in_days).compact
    # delete the most extreme cycle_time
    cycle_times.delete_at(cycle_times.index(cycle_times.max))
    (cycle_times.inject(0.0) {|sum, el| sum + el} / cycle_times.size).round(1)
  end

  def perform_search
    @search_results = client.Issue.jql(search_string, search_options)
  end

  def default_search_issue_types
    %w[Task Subtask Story]
  end

  def default_search_start_time
    '-12w'
  end

  def default_search_status
    'Done'
  end

  def default_search_skipped_parents
    %w[CQC-279 CQC-512 CQC-826]
  end

  def default_search_project
    'CQC'
  end

  def search_string
    # 'project = CQC AND type in (Task, Subtask, Story) AND created >=-12w AND status = Done and parent not in (CQC-279, CQC-512, CQC-826)'
    [
      "project = #{project}",
      "type in (#{issue_types.join(', ')})",
      "created >= #{start_time}",
      "status = #{status}",
      "parent NOT IN (#{skipped_parents.join(', ')})"
    ].join(' AND ')
  end

  def default_search_options
    {max_results: 100, expand: 'changelog'}
  end

  def default_client_options
    { username: 'kim.godard@snapdocs.com',
      password: ENV["JIRA_TOKEN"],
      site: 'http://snapdocs-eng.atlassian.net:443/',
      context_path: '',
      auth_type: :basic }
  end
end
