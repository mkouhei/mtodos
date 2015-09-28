require 'net/http'
require 'json'
require 'memcached'
require 'mtodos/version'

module Mtodos
  # Local cache
  class Cache
    def initialize
      @cache_filename = 'mtodos.cache'
      @cache_file = File.join(Dir.pwd, @cache_filename)
      if File.file?(@cache_file)
        @hash = Marshal.load(File.read(@cache_file))
      else
        @hash = {}
        File.write(@cache_file, Marshal.dump(@hash))
      end
    end

    class NotFound < Exception; end

    def set(key, value)
      @hash[key] = value
      File.write(@cache_file, Marshal.dump(@hash))
    end

    def get(key)
      begin
        @hash = Marshal.load(File.read(@cache_file))
      rescue Errno::ENOENT
        @hash = {}
      end
      having?(key)
    end

    def having?(key)
      if @hash[key]
        true
      else
        fail NotFound, 'NotFound key'
      end
    end
  end

  # retrieving ToDo and send notification client
  class Client
    def initialize(url, notify_url, cache_file: true, memcached_server: nil)
      @url = url
      @notify_url = notify_url
      if cache_file
        @cache = Cache.new
      else
        initialize_memcache(memcached_server)
      end
      initialize_resource_type(url)
    end

    def initialize_memcache(memcached_server)
      if memcached_server.nil?
        @cache = Memcached.new('localhost:11211')
      else
        @cache = Memcached.new(memcached_server)
      end
    end

    def initialize_resource_type(url)
      if url =~ %r{://udd.debian.org/}
        @resouce_type = 'udd'
      elsif url =~ /glaneuses.json/
        @resouce_type = 'glaneuses'
      end
    end

    def retrieve
      json_data = JSON.parse(Net::HTTP.get(URI.parse(@url)))
      if @resouce_type == 'udd'
        data_array = json_data
      elsif @resouce_type == 'glaneuses'
        data_array = json_data['udd']
      end
      filter(data_array).each do |todo|
        notify(todo)
      end
    end

    def filter(data_array)
      data_array.select do |todo|
        todo if critical?(todo) && !sent?(todo[':shortname'])
      end
    end

    def critical?(todo)
      ['RC bug', 'testing auto-removal'].include?(todo[':type'])
    end

    def sent?(key)
      @cache.get(key)
    rescue Cache::NotFound
      false
    rescue Memcached::NotFound
      false
    rescue Memcached::ServerIsMarkedDead
      false
    end

    def store(key)
      @cache.set(key, true)
    rescue Memcached::ServerIsMarkedDead => e
      puts e
    end

    def notify(todo)
      pat_slack = %r{https://hooks.slack.com/services/}
      @notify_url =~ pat_slack && post_slack(todo) && store(todo[':shortname'])
    end

    def post_slack(todo)
      headers = { 'Content-Type' => 'application/json' }
      uri = URI.parse(@notify_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      case http.post(uri.path, message(todo).to_json, headers)
      when Net::HTTPSuccess
        true
      else
        false
      end
    end

    def message(todo)
      { text: todo[':shortname'] }
    end
  end
end
