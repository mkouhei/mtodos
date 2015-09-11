require 'spec_helper'
require 'webmock'
require 'mtodos'

include WebMock::API


describe Mtodos do
  data = File.read('spec/data/udd.debian.org.json')
  stub_request(:any, 'udd.debian.org').to_return(
    :body => data,
    :status => 200,
    :headers => {'Content-Length' => 7632}
  )
  it 'has a version number' do
    expect(Mtodos::VERSION).not_to be nil
  end

  it 'initialize Client with cache file' do
    Mtodos::Client.new('https://udd.debian.org/dmd/?email1=dummy%40example.org&format=json#todo')
    expect(File.exist?('mtodos.cache')).to eq(true)
  end
end
