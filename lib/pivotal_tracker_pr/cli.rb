require "pivotal_tracker_pr"
require 'json'
require 'net/http'
require 'thor'

module PivotalTrackerPr
  PULL_REQUEST_MESSAGE = 'PULLREQ_EDITMSG'.freeze
  MESSAGE_TEMPLATE = 'PULLREQ_MSG_TEMPLATE'.freeze

  class CLI < Thor
    default_command :create
    desc 'create [STORY_ID]', 'Create pull request use story id / story name of PivotalTracker.'
    def create(story_id = nil)
      story_id ||= parse_story_id
      if story_id
        say "StoryId : #{story_id}", :green

        check_env_vars

        story_name = get_story_name(story_id)
        if story_name
          say "Story name : #{story_name}", :green
          write_pull_request_template story_id, story_name
        end
      end

      system 'hub pull-request --browse'
    end

    private

    def parse_story_id
      current_branch = `git symbolic-ref --short HEAD`
      current_branch.match(/(\d+)/)
      $1
    end

    def get_story_name(story_id)
      url = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{ENV['PT_PROJECT_ID']}/stories/#{story_id}")
      https = Net::HTTP.new(url.host, 443)
      https.use_ssl = true

      response = https.get(url.path, 'X-TrackerToken' => ENV['PT_TOKEN'])
      case response
      when Net::HTTPSuccess
        JSON(response.body)['name']
      else
        say 'Please check story id for following message:', :red
        say JSON(response.body)['error'] || response.body, :red

        nil
      end
    end

    def check_env_vars
      unless ENV['PT_TOKEN']
        say 'Please export PT_TOKEN', :red
        exit 1
      end

      unless ENV['PT_PROJECT_ID']
        say 'Please export PT_PROJECT_ID', :red
        exit 1
      end
    end

    def write_pull_request_template(story_id, story_name)
      message_context =
        if File.exists?(message_template_path)
          message_from_template(story_id, story_name)
        else
          default_message
        end

      open(pull_request_message, 'w') { |file| file.puts message_context }
    end

    def message_template_path
      File.join(Dir.pwd, '.git', MESSAGE_TEMPLATE)
    end

    def message_from_template(story_id, story_name)
      template_content = File.open(message_template_path).read
      template_content.gsub('{{STORY_ID}}', story_id).gsub('{{STORY_NAME}}', story_name).gsub('{{STORY_LINK}}', story_link(story_id))
    end

    def pull_request_message
      File.join(Dir.pwd, '.git', PULL_REQUEST_MESSAGE)
    end

    def default_message(story_id, story_name)
      <<~EOF
        [fixed ##{story_id}]#{story_name}

        #{story_link story_id}
      EOF
    end

    def story_link(story_id)
      "https://www.pivotaltracker.com/story/show/#{story_id}"
    end
  end
end
