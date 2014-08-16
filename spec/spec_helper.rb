require 'rspotify'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
end

RSpec.configure do |config|

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect

    mocks.verify_partial_doubles = true
  end
end



def authenticate_test_account
  # Keys generated specifically for the tests. Should be removed in the future
  client_id     = '5ac1cda2ad354aeaa1ad2693d33bb98c'
  client_secret = '155fc038a85840679b55a1822ef36b9b'
  RSpotify.authenticate(client_id, client_secret)
end

def stubbed_authenticate_test_account
  VCR.use_cassette('authenticate:5ac1cda2ad354aeaa1ad2693d33bb98c') do 
    authenticate_test_account
  end
end