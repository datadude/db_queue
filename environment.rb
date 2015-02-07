require File.join(File.dirname(__FILE__),'bootstrap')

#your database connection parameters here
ActiveRecord::Base.establish_connection(
    :adapter=> "mysql2",
    :host => "localhost",
    :database=> "my_users",
    :username => 'test_user',
    :password => 'secretpassword'
)
