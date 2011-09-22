# A sample Gemfile
source "http://rubygems.org"

gem "activesupport"
gem "json_pure"
gem "rgl"

group :development do
  gem "rake"
  gem "rspec"

  # FIXME: change to the latest cucumber version when cucumber bug gets fixed
  # https://github.com/cucumber/cucumber/issues/136
  gem "cucumber", "1.0.3"

  gem "jeweler"
  gem "murdoc", "~> 0.1.11"
  gem "ruby-debug19", :platforms => :ruby_19

  # FIXME: linecache being ruby1.9+only
  gem "linecache", "= 0.45", :platforms => :ruby_18

  gem "ruby-debug",   :platforms => :ruby_18
  gem 'fssm'

  gem 'yuicompressor',    :require => false
  gem 'uglifier',         :require => false
  gem 'front-compiler',   :require => false
  gem 'closure-compiler', :require => false

  gem 'execjs', :require => false

  # Some of these might be neccessary, check out execjs runtimes
  # gem 'therubyracer', :platform => :ruby,  :require => false
  # gem 'therubyrhino', :platform => :jruby, :require => false

  gem 'sinatra'
  gem 'rack-test'
  gem 'yard'
end
