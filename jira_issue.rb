require './statuses.rb'

class JiraIssue

  include Statuses

  attr_reader :key, :client, :created, :summary, :description, :status, :fields, :histories,
    :assignee, :type, :raw, :subtasks, :parent, :finish_status

  attr_writer :finish_status

  def initialize(jira_issue, finish_status:)
    @finish_status = finish_status
    load_issue(jira_issue)
  end

  def done?
    !finish_time.nil?
  end

  def days_since_start
    ((Time.now - start_time) / 86400).round(1) rescue nil
  end

  def cycle_time_in_days
    if finish_time.nil? || start_time.nil?
      nil
    else
      ((finish_time - start_time) / 86400).round(1) rescue nil
    end
  end

  def start_time
    get_time_of_status_change_after_first("To Do") ||
      get_time_of_status_change_before_first("Code Review")
  end

  def finish_time
    get_time_of_last_status_change(finish_status) ||
      get_final_status_time ||
      get_time_of_status_change_after_last_preceding_status(finish_status)
  end

  def get_time_of_status_change_after_last_preceding_status(status)
    # get the preceding status from STATUSES
    preceding_status = STATUSES[STATUSES.index(status)-1]
    return nil if preceding_status.nil?
    # get the index of the LAST occurance of the preceding status
    last_preceding_status_index = status_changes.each_index.select {|i| status_changes[i][:status] == preceding_status}.last
    return nil if last_preceding_status_index.nil?
    # get the status immediately after that index and return its time
    change = status_changes[last_preceding_status_index + 1]
    return nil if change.nil?
    Time.parse change[:created]
  end

  def get_final_status_time
    return nil unless status == finish_status
    Time.parse status_changes.last[:created]
  end

  def get_time_of_status_change_before_first(status)
    idx = status_changes.find_index {|sc| sc[:status] == status}
    return idx if idx.nil?
    change = status_changes[idx - 1]
    return change if change.nil?
    Time.parse change[:created]
  end

  def get_time_of_status_change_after_first(status)
    idx = status_changes.find_index {|sc| sc[:status] == status}
    return idx if idx.nil?
    change = status_changes[idx + 1]
    return change if change.nil?
    Time.parse change[:created]
  end

  def get_time_of_last_status_change(status)
    change = find_last_status_change(status)
    return change if change.nil?
    Time.parse change[:created]
  end

  def find_last_status_change(status)
    status_changes.reverse.detect {|sc| sc[:status] == status}
  end

  def status_changes
    @status_histories ||= status_histories.map do |hist|
      { author: hist["author"]["displayName"],
        created: hist["created"],
        status: hist["items"].first["toString"] }
    end.sort {|a,b| a[:created] <=> b[:created]}
  end

  def status_histories
    histories.select {|hist| hist["items"].map {|i| i["field"]}.include?("status")}
  end

  def parent_key
    return "-" if parent.nil?
    parent["key"] rescue "-"
  end

  def parent_type
    return "-" if parent.nil?
    parent["fields"]["issuetype"]["name"]
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
