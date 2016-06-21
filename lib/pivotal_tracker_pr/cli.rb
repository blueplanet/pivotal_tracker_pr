require "pivotal_tracker_pr"
require 'pivotal_tracker_pr/pivotal_tracker_api'
require 'json'
require 'net/http'
require 'thor'

module PivotalTrackerPr
  class CLI < Thor
    default_command :create
    desc 'create [STORY_ID]', 'Create pull request use story id / story name of PivotalTracker.'
    def create(story_id = nil)
      story_id ||= parse_story_id
      if story_id
        say "story id : #{story_id}", :green

        check_env_vars

        story_name = PivotalTrackerApi.get_story_name(story_id)
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
  end
end
