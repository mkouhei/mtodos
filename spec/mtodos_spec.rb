require 'spec_helper'
require 'webmock'
require 'mtodos'

include WebMock::API

UDD = 'http://udd.debian.org/dmd/?email1=dummy%40example.org&format=json#todo'


describe Mtodos do
  data = File.read('spec/data/udd.debian.org.json')
  stub_request(:any, 'udd.debian.org/dmd/')
    .with(:query => {:email1 => 'dummy@example.org',
                     :format => 'json'})
    .to_return(:body => data,
               :status => 200,
               :headers => {'Content-Length' => 7632})

  after do
    if File.exist?('mtodos.cache')
      File.unlink('mtodos.cache')
    end
  end
  
  it 'has a version number' do
    expect(Mtodos::VERSION).not_to be nil
  end

  it 'initialize Client with cache file' do
    cli = Mtodos::Client.new(UDD)
    expect(File.exist?('mtodos.cache')).to eq(true)
  end
end
