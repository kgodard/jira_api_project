#!/usr/bin/env ruby

require 'jira-ruby'
require './jira_issue.rb'

class JiraSearch

  attr_reader :client, :search_string, :search_options, :search_results, :issues,
              :project, :issue_types, :created_time, :statuses, :skipped_parents,
              :finished_within_weeks, :unfiltered_issues

  def initialize(project: default_search_project,
                 issue_types: default_search_issue_types,
                 created_time: default_search_created_time,
                 statuses: default_search_statuses,
                 skipped_parents: default_search_skipped_parents,
                 search_options: default_search_options,
                 client_options: default_client_options,
                 finished_within_weeks: nil
                )
    @client                = JIRA::Client.new(client_options)
    @project               = project
    @issue_types           = issue_types
    @created_time          = created_time
    @statuses              = statuses
    @skipped_parents       = skipped_parents
    @search_options        = search_options
    @finished_within_weeks = finished_within_weeks
    @unfiltered_issues     = []
    @issues                = []
    perform_search
    load_results
    filter_results
  end

  def load_results
    search_results.each do |result|
      unfiltered_issues << JiraIssue.new(result)
    end
  end

  def filter_results
    @issues += filtered_issues
  end

  def filtered_issues
    if finished_within_weeks.nil?
      unfiltered_issues
    else
      puts "filtering..."
      unfiltered_issues.select do |ui|
        puts "issue: #{ui.key} | finished: #{ui.finish_time}"
        !ui.finish_time.nil? && ui.finish_time >= (Date.today - finished_within_weeks * 7)
      end
    end
  end

  def average_cycle_time
    cycle_times = issues.map(&:cycle_time_in_days).compact
    # delete the most extreme cycle_time
    cycle_times.delete_at(cycle_times.index(cycle_times.max))
    (cycle_times.inject(0.0) {|sum, el| sum + el} / cycle_times.size).round(1)
  end

  def perform_search
    puts "Search string: #{search_string}"
    @search_results = client.Issue.jql(search_string, search_options)
  end

  def default_search_issue_types
    %w[Task Subtask Story]
  end

  def default_search_created_time
    '-24w'
  end

  def default_search_statuses
    %w[Done]
  end

  def default_search_skipped_parents
    %w[CQC-279 CQC-512 CQC-826 CQC-551]
  end

  def default_search_project
    'CQC'
  end

  def search_string
    # 'project = CQC AND type in (Task, Subtask, Story) AND created >=-12w AND status = Done and parent not in (CQC-279, CQC-512, CQC-826)'
    [
      "project = #{project}",
      "type in (\"#{issue_types.join('", "')}\")",
      "created >= #{created_time}",
      "status in (\"#{statuses.join('", "')}\")",
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
