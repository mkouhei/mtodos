require 'spec_helper'
require 'mtodos'


describe Mtodos do
  it 'has a version number' do
    expect(Mtodos::VERSION).not_to be nil
  end

  it 'initialize Client with cache file' do
    Mtodos::Client.new('http://d.palmtb.net/_static/glaneuses.json')
    expect(File.exist?('mtodos.cache')).to eq(true)
  end
end
