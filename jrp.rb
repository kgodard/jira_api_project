#!/usr/bin/env ruby

require 'optparse'
require 'jira-ruby'
require './display_helpers.rb'
require './script_options.rb'
require './jira_issue.rb'
require './jira_search.rb'
require './jira_reporter.rb'
require './jira_cycle_times_reporter.rb'
require './jira_report_cli.rb'

JiraReportCli.new(ARGV)
