require 'net/http'
require 'json'
require 'memcached'
require 'mtodos/version'


module Mtodos
  class Cache
    @@cache_filename = 'mtodos.cache'

    def initialize
      @cache_file = File.join(Dir::pwd, @@cache_filename)
      if File.file?(@cache_file)
        @hash = Marshal.load(File.read(@cache_file))
      else
        @hash = Hash.new()
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
        @hash = Hash.new()
      end
      if @hash[key]
        result = true
      else
        raise NotFound, 'NotFound key'
      end
      return result
    end
  end


  class Client
    def initialize(url, cache_file: true, memcached_server: nil)
      @url = url
      if cache_file
        @cache = Cache.new()
      else
        if memcached_server.nil?
          @cache = Memcached.new('localhost:11211')
        else
          @cache = Memcached.new(memcached_server)
        end
      end

      if url =~ /:\/\/udd.debian.org\//
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
      data_array.select {
        |todo| todo if critical?(todo) && !sent?(todo[':shortname'])
      }.each do |todo|
        notify(todo)
      end
    end

    def critical?(todo)
      return (todo[':type'] == 'RC bug' ||
              todo[':type'] == 'testing auto-removal') ? true : false
    end

    def sent?(key)
      begin
        result = @cache.get(key)
      rescue Cache::NotFound
        result = false
      rescue Memcached::NotFound
        result = false
      rescue Memcached::ServerIsMarkedDead
        result = false
      end
      return result
    end

    def store(key)
      begin
        @cache.set(key, true)
      rescue Memcached::ServerIsMarkedDead => e
        puts e
      end
    end

    def notify(todo)
      # TODO: change the send client some message system.
      puts todo[':shortname']
      store(todo[':shortname'])
    end
  end
end
