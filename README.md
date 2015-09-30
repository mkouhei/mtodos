# MTodos (Debian pacakge Maintainer ToDo notifier)

## Status

[![Build Status](https://travis-ci.org/mkouhei/mtodos.svg)](https://travis-ci.org/mkouhei/mtodos)
[![Coverage Status](https://coveralls.io/repos/mkouhei/mtodos/badge.svg?branch=master&service=github)](https://coveralls.io/github/mkouhei/mtodos?branch=master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mtodos'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mtodos

## Usage

    irb> require 'mtodos'
    irb> cli = Mtodos::Client.new('https://udd.debian.org/dmd/?email1=mkouhei%40palmtb.net&format=json', 'https://hooks.slack.com/services/dummy/dummy/dummy')
    irb> cli.retrieve

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mkouhei/mtodos. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

