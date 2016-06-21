module PivotalTrackerPr
  class PivotalTrackerApi
    STORY_URL_PREFIX = 'https://www.pivotaltracker.com/services/v5/projects'.freeze

    def self.get_story_name(story_id)
      url = URI.parse(File.join(STORY_URL_PREFIX, ENV['PT_PROJECT_ID'], 'stories', story_id.to_s))

      https = Net::HTTP.new(url.host, 443)
      https.use_ssl = true
      https.open_timeout = 5
      https.read_timeout = 5

      response = https.get(url.path, 'X-TrackerToken' => ENV['PT_TOKEN'])
      case response
      when Net::HTTPSuccess
        JSON(response.body)['name']
      else
        puts 'Please check story id for following message:'
        puts JSON(response.body)['error'] || response.body

        nil
      end
    rescue Timeout::Error
      puts 'Timeout::Error, Please check network', :red
      nil
    rescue => e
      puts e.message
      nil
    end
  end
end
