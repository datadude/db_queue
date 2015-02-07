require File.join(File.dirname(__FILE__),'bootstrap')
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'fileutils'

#you will need to create this database and user if you want to test.
ActiveRecord::Base.establish_connection(
    :adapter=> "mysql2",
    :host => "127.0.0.1",
    :database=> "sqlcache_test",
    :username => 'test_user',
    :password => 'secretpassword'
)

ActionMailer::Base.delivery_method = :test