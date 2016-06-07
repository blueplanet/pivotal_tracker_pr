require "pivotal_tracker_pr"
require 'thor'

module PivotalTrackerPr
  class CLI < Thor
    desc 'create', 'Generate pull request use story id / story name.'
    def create
      say 'Parse story id'
      say 'Get story name', :green
      say 'Write template for pull request'
      say 'Done.', :green
    end

    private


  end
end
