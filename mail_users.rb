require File.join(File.dirname(__FILE__),'environment')

mail_mutex = Mutex.new #you may need a mutex to access shared resources
#put the code you want to run in a thread in a lamba like this
callback = lambda{|row|
 mail_mutex do
  #access shared resorces here
 end
   #this can take a while so we don't want to lock it up in a Mutex.
   #your SMTP server should be thread safe
   TestUserMailer.mail_user(row['email'],"Thank-you for your purchase of #{row['purchased']}",row['firstname'])
   }


SqlCache.table_name = 'USERS' #I found I had to set the tablename or else the 'find_by_sql' method fails

filename =  File.join(Root_Dir,'test','test_email_group.hsh')
cache_file = SqlCache.read_cache_file(filename)
db_queue = DbQueue.new(cache_file,callback,{include_backtrace: true, threads: 4})
db_queue.run
puts 'Done!'
