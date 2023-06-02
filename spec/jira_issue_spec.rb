require 'json'
require 'ostruct'
require 'time'
require_relative '../jira_issue.rb'

shared_examples 'cycle_time_in_days' do |finish_status:, result:|
  let(:test_finish_status) { finish_status }

  it { expect(subject.cycle_time_in_days).to eq result }
end

describe JiraIssue do
  # @raw         = jira_issue
  # @key         = jira_issue.key
  # @type        = jira_issue.issuetype.name
  # @assignee    = jira_issue.assignee.displayName rescue nil
  # @created     = jira_issue.created
  # @summary     = jira_issue.summary
  # @description = jira_issue.description
  # @status      = jira_issue.status.name
  # @fields      = jira_issue.fields
  # @histories   = jira_issue.changelog["histories"]
  # @subtasks    = jira_issue.subtasks
  # @parent      = jira_issue.parent rescue nil

  let(:test_status_changes) {
    [{:author=>"Alex Ryan", :created=>"2023-03-10T14:56:50.488-0500", :status=>"Estimation Required"},
     {:author=>"Alex Ryan", :created=>"2023-03-16T10:51:54.241-0400", :status=>"Ready for Scheduling"},
     {:author=>"Alex Ryan", :created=>"2023-03-16T10:51:55.582-0400", :status=>"To Do"},
     {:author=>"Syl Turner", :created=>"2023-03-20T11:18:12.883-0400", :status=>"20/Mar/23 11:18 AM"},
     {:author=>"Syl Turner", :created=>"2023-03-24T11:37:25.801-0400", :status=>"Code Review"},
     {:author=>"Afotey Quaye", :created=>"2023-03-30T11:55:15.057-0400", :status=>"Dev Complete"},
     {:author=>"Afotey Quaye", :created=>"2023-03-30T11:55:43.447-0400", :status=>"Ready for Testing"},
     {:author=>"Veronica Buchwald", :created=>"2023-03-31T13:37:06.517-0400", :status=>"In Testing"},
     {:author=>"Veronica Buchwald", :created=>"2023-03-31T13:50:47.915-0400", :status=>"31/Mar/23 1:50 PM"},
     {:author=>"Alex Ryan", :created=>"2023-04-03T15:19:45.063-0400", :status=>"In Testing"},
     {:author=>"Alex Ryan", :created=>"2023-04-03T15:19:46.846-0400", :status=>"To Do"},
     {:author=>"Sophear Theng", :created=>"2023-04-06T10:04:34.634-0400", :status=>"06/Apr/23 10:04 AM"},
     {:author=>"Nikole McLeish", :created=>"2023-04-07T10:59:52.525-0400", :status=>"Code Review"},
     {:author=>"Syl Turner", :created=>"2023-04-14T10:49:36.261-0400", :status=>"In Development"},
     {:author=>"Syl Turner", :created=>"2023-04-14T10:49:37.689-0400", :status=>"Code Review"},
     {:author=>"Syl Turner", :created=>"2023-04-14T10:49:39.302-0400", :status=>"Dev Complete"},
     {:author=>"Syl Turner", :created=>"2023-04-14T10:49:40.583-0400", :status=>"Ready for Testing"},
     {:author=>"Veronica Buchwald", :created=>"2023-04-14T12:05:39.859-0400", :status=>"In Testing"},
     {:author=>"Veronica Buchwald", :created=>"2023-04-14T15:50:31.567-0400", :status=>"14/Apr/23 3:50 PM"},
     {:author=>"Sophear Theng", :created=>"2023-05-05T09:34:03.294-0400", :status=>"Resolved"}]
  }

  let(:search_result) {
    fakeresult = {
      key: "123",
      issuetype: {name: "issue_name"},
      assignee: {displayName: "display_name"},
      created: Time.now - 86400,
      summary: "summary",
      description: "description",
      status: {name: "Done"},
      fields: [],
      changelog: {"histories"=> []},
      subtasks: [],
      parent: nil
    }
    JSON.parse(fakeresult.to_json, object_class: OpenStruct)
  }

  subject { JiraIssue.new(search_result, finish_status: test_finish_status) }

  context "with multiple repeating status changes" do
    before do
      expect_any_instance_of(JiraIssue).to receive(:status_changes).at_least(4).times.and_return(test_status_changes)
    end

    it_behaves_like 'cycle_time_in_days', finish_status: "Code Review", result: 25.0
    it_behaves_like 'cycle_time_in_days', finish_status: "Dev Complete", result: 25.0
    it_behaves_like 'cycle_time_in_days', finish_status: "Ready for Testing", result: 25.0
    it_behaves_like 'cycle_time_in_days', finish_status: "In Testing", result: 25.0
    it_behaves_like 'cycle_time_in_days', finish_status: "Done", result: 45.9
  end
end
