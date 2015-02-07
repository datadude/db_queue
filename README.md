#DB Queue
An easy threaded work queue.

##Introduction
Suppose that you have a process that you want to perform for thousands of database records.
Think sending emails, or performing complex calculations or transformations that take a large amount of time.
You probably want to fire off a process and walk away from it.  I had just such a task, the process was going
to take 15 seconds or more and  I had 18,000 records to process. Testing indicated that to complete the task I
would need something like 36 hours!

I did not want to keep a database connection open that long, and if something happened I would want to be able to
pick up where I left off and complete the task. Enter the DB Queue!

###Features
* Easy queue creation using active record, a text file or a SQL query.
* Logging of each item processed, and a separate log for errors.
* Saves its place in the queue to file.
* Uses fairly human readable text files to cache.
* Tracks successes and failures
* Threaded processing.

##Dependencies
Depends on Standard RAILS components Active Record and Logger.
Plus any Active record adapter that you might need.
It has been tested with Mysql2 and FireBird adapters.

##Quickstart
Start by simply cloning this project:
```
     git clone https://github.com/datadude/db_queue
```

Then set up your database connection in the `envirionment.rb`


```ruby
ActiveRecord::Base.establish_connection(
    :adapter=> "mysql2",
    :host => "localhost",
    :database=> "my_users",
    :username => 'test_user',
    :password => 'secretpassword'
)
```


consider doing the same in `envirionment_test.rb` if you wish to run tests

Now write your processing code in a `.rb` file. You can find an example in `mail_users.rb`.
The following steps are needed to start the queue:
1. put the code you wish to run for each row of a query or file in a _lambda_ and assign it to a variable.
2. Create or connect ot a `SqlCache` file.  That contains rows of the data you wish to process.
3. Create a new DbQueue object passing in the `SQLCache` file, the lambda from step 1, and any configuration params
4. Call .run for the DbQueue instance, this will kick off the processing. firing off the number of threads configured
(2 by default). control will return once processing is complete.


