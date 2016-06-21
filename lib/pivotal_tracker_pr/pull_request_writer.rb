module PivotalTrackerPr
  class PullRequestWriter
    PULL_REQUEST_MESSAGE = 'PULLREQ_EDITMSG'.freeze
    MESSAGE_TEMPLATE = 'PULLREQ_MSG_TEMPLATE'.freeze

    def initialize(story_id, story_name)
      @story_id = story_id
      @story_name = story_name
    end

    def write_pull_request_template
      message_context =
        if File.exist?(message_template_path)
          message_from_template(story_id, story_name)
        else
          default_message story_id, story_name
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
      <<-EOF
[fixed ##{story_id}]#{story_name}

#{story_link story_id}
      EOF
    end

    def story_link(story_id)
      "https://www.pivotaltracker.com/story/show/#{story_id}"
    end
  end
end
