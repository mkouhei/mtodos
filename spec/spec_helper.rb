$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'


SimpleCov.start do
  add_filter '/\.bundle/'
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
