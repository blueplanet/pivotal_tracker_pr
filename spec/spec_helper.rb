$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pivotal_tracker_pr'
require 'pivotal_tracker_pr/pivotal_tracker_api'
require 'pivotal_tracker_pr/pull_request_writer'
require 'coveralls'

Coveralls.wear!
