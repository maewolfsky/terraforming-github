require "spec_helper"

module Terraforming
  module Resource
    describe GithubRepository do
      let(:api_key) do
        "api_key"
      end

      let(:app_key) do
        "app_key"
      end

      let(:client) do
        # Setup stuff here
      end

      let(:get_all_monitors_response) do
        [
          "200",
          [
            {
              "tags" => [],
              "deleted" => nil,
              "query" => "avg(last_1h):avg:system.load.15{*} by {host,name} > 5",
              "message" =>
                "@slack-infrastructure\n{{#is_alert}}  @pagerduty-Datadog    \#{{/is_alert}}\n{{#is_recovery}} @pagerduty-resolve  \#{{/is_recovery}}",
              "matching_downtimes" => [],
              "id" => 123456,
              "multi" => true,
              "name" => "High Load Average {{host.name}} {{name.name}}",
              "created" => "2016-07-27T05:16:40.525472+00:00",
              "created_at" => 1469596600000,
              "creator" => {
                "id" => 999999, "handle" => "user@example.com", "name" => "User Example", "email" => "user@example.com"
              },
              "org_id" => 99999,
              "modified" => "2016-07-27T22:05:52.273579+00:00",
              "overall_state" => "OK",
              "type" => "metric alert",
              "options" => {
                "notify_audit" => false,
                "locked" => false,
                "timeout_h" => 0,
                "silenced" => {},
                "thresholds" => { "critical" => 3.1, "warning" => 2.0 },
                "require_full_window" => true,
                "notify_no_data" => false,
                "renotify_interval" => 0,
                "no_data_timeframe" => 120,
                "escalation_message" => "escalated",
                "include_tags" => false,
              }
            },
            {
              "tags" => [],
              "deleted" => nil,
              "query" => "\"aws.status\".over(\"region:ap-northeast-1\",\"service:vpc\").by(\"region\",\"service\").last(2).count_by_status()",
              "message" =>
                "@slack-engineering @slack-infrastructure\n{{#is_alert}}  @pagerduty-Datadog    \#{{/is_alert}}\n{{#is_recovery}} @pagerduty-resolve  \#{{/is_recovery}}",
              "matching_downtimes" => [],
              "id" => 789012,
              "multi" => true,
              "name" => "[Critical][VPC]AWS Service Status",
              "created" => "2015-11-09T02:21:52.013033+00:00",
              "created_at" => 1447035712000,
              "creator" => {
                "id" => 999999, "handle" => "user@example.com", "name" => "User Example", "email" => "user@example.com"
              },
              "org_id" => 99999,
              "modified" => "2016-07-26T02:23:15.446264+00:00",
              "overall_state" => "OK",
              "type" => "service check",
              "options" => {
                "notify_audit" => true,
                "locked" => false,
                "timeout_h" => 0,
                "silenced" => { "*" => nil },
                "notify_no_data" => false,
                "renotify_interval" => 0,
                "no_data_timeframe" => 2,
              }
            },
          ]
        ]
      end

      before do
        allow(client).to receive(:get_all_monitors).and_return(get_all_monitors_response)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-'EOS'
resource "github_repository" "repo1" {
    name               = "Test repository 1"
    descripton         = "Sample Description"
}
          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
            "version" => 1,
            "serial" => 1,
            "modules" => [
              {
                "path" => [
                  "root"
                ],
                "outputs" => {},
                "resources" => {
                  "github_repository.repo1" => {
                    "type" => "github_repository",
                    "primary" => {
                      "id" => "123456",
                      "attributes" => {
                        "id" => "123456",
                        "name" => "Test Repository 1",
                        "description" => "Sample Description"
                      }
                    }
                  }
                }
              }
            ]
          })
        end
      end
    end
  end
end
