$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pivotal_tracker_pr'
require 'pivotal_tracker_pr/pivotal_tracker_api'
require 'coveralls'

Coveralls.wear!
