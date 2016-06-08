require "pivotal_tracker_pr"
require 'json'
require 'net/http'
require 'thor'

module PivotalTrackerPr
  PULL_REQUEST_TEMPLATE = 'PULLREQ_EDITMSG'.freeze

  class CLI < Thor
    desc 'create', 'Generate pull request use story id / story name.'
    def create
      story_id = parse_story_id
      if story_id
        say "StoryId : #{story_id}", :green

        check_env_vars

        story_name = get_story_name(story_id)
        say "Story name : #{story_name}", :green

        write_pull_request_template story_id, story_name
      end

      say 'Done.'
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
      response.code == 200 ? JSON(response.body)['name'] : nil
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
      open(template_path, 'w') do |file|
        file.puts "[fixed ##{story_id}]#{story_name}"
        file.puts "\n"
        file.puts "https://www.pivotaltracker.com/story/show/#{story_id}"
      end
    end

    def template_path
      File.join(Dir.pwd, '.git', PULL_REQUEST_TEMPLATE)
    end
  end
end
