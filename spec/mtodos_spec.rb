require 'spec_helper'
require 'webmock'
require 'mtodos'

include WebMock::API

UDD = 'http://udd.debian.org/dmd/?email1=dummy%40example.org&format=json#todo'
GLANEUSES = 'http://example.org/glaneuses.json'
SLACK = 'https://hooks.slack.com/services/dummy/dummy/dummy'

describe Mtodos do
  data = File.read('spec/data/udd.debian.org.json')
  glaneuses = File.read('spec/data/glaneuses.json')
  key = 'rc_std_ae0b0e7487e87af44c1b78efbbec037c'
  stub_request(:any, 'udd.debian.org/dmd/')
    .with(query: { email1: 'dummy@example.org',
                   format: 'json' })
    .to_return(body: data,
               status: 200,
               headers: { 'Content-Length' => 7632 })
  stub_request(:any, 'example.org/glaneuses.json')
    .to_return(body: glaneuses,
               status: 200,
               headers: { 'Content-Length' => 10_756 })
  stub_request(:any, 'https://hooks.slack.com/services/dummy/dummy/dummy')
    .to_return(status: 200)

  after do
    File.exist?('mtodos.cache') && File.unlink('mtodos.cache')
  end

  it 'has a version number' do
    expect(Mtodos::VERSION).not_to be nil
  end

  it 'initialize Client with cache file' do
    Mtodos::Client.new(UDD, SLACK)
    expect(File.exist?('mtodos.cache')).to eq(true)
  end

  it 'store the key in cache after retrieve from udd' do
    cli = Mtodos::Client.new(UDD, SLACK)
    cli.retrieve
    expect(cli.sent?(key)).to eq(true)
  end

  it 'store the key in cache after retrieve from glaneuses' do
    cli = Mtodos::Client.new(GLANEUSES, SLACK)
    cli.retrieve
    expect(cli.sent?(key)).to eq(true)
  end

  it 'should load the key from the cache file' do
    cli = Mtodos::Client.new(UDD, SLACK)
    cli.retrieve
    expect(cli.sent?(key)).to eq(true)
    cli2 = Mtodos::Client.new(UDD, SLACK)
    expect(cli2.sent?(key)).to eq(true)
  end

  it 'should fail to load the key from the cache file' do
    cli = Mtodos::Client.new(UDD, SLACK)
    cli.retrieve
    File.exist?('mtodos.cache') && File.unlink('mtodos.cache')
    expect(cli.sent?(key)).to eq(false)
  end

  it 'should store the key in memcached after retrieve from udd' do
    memcache_mock = double('memcached mock')
    allow(memcache_mock).to receive(:get).and_return(true)
    cli = Mtodos::Client.new(UDD, SLACK, cache_file: nil)
    allow(cli).to receive(:sent?).and_return(memcache_mock.get)
    expect(File.exist?('mtodos.cache')).to eq(false)
    cli.retrieve
    expect(cli.sent?(key)).to eq(true)
  end

  it 'should store the key in memcached specifing memacached server' do
    memcache_mock = double('memcached mock')
    allow(memcache_mock).to receive(:get).and_return(true)
    cli = Mtodos::Client.new(UDD,
                             SLACK,
                             cache_file: nil,
                             memcached_server: 'localhost:11211')
    allow(cli).to receive(:sent?).and_return(memcache_mock.get)
    expect(File.exist?('mtodos.cache')).to eq(false)
    cli.retrieve
    expect(cli.sent?(key)).to eq(true)
  end
end
