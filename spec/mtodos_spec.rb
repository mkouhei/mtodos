require 'spec_helper'
require 'webmock'
require 'mtodos'

include WebMock::API

UDD = 'http://udd.debian.org/dmd/?email1=dummy%40example.org&format=json#todo'
GLANEUSES = 'http://example.org/glaneuses.json'

describe Mtodos do
  data = File.read('spec/data/udd.debian.org.json')
  glaneuses = File.read('spec/data/glaneuses.json')
  stub_request(:any, 'udd.debian.org/dmd/')
    .with(:query => {:email1 => 'dummy@example.org',
                     :format => 'json'})
    .to_return(:body => data,
               :status => 200,
               :headers => {'Content-Length' => 7632})
  stub_request(:any, 'example.org/glaneuses.json')
    .to_return(:body => glaneuses,
               :status => 200,
               :headers => {'Content-Length' => 10756})

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

  it 'store the key in cache after retrieve from udd' do
    cli = Mtodos::Client.new(UDD)
    cli.retrieve
    expect(cli.is_sent?('rc_std_ae0b0e7487e87af44c1b78efbbec037c')).to eq(true)
  end

  it 'store the key in cache after retrieve from glaneuses' do
    cli = Mtodos::Client.new(GLANEUSES)
    cli.retrieve
    expect(cli.is_sent?('rc_std_ae0b0e7487e87af44c1b78efbbec037c')).to eq(true)
  end

end
