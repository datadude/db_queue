require File.join(File.dirname(__FILE__),'../test_environment')


class TestDbQueue < Minitest::Test

  describe DbQueue do
    include FileUtils
    TEST_FILE = File.join(File.dirname(__FILE__),'test_file.hsh').freeze
    PLACE_FILE = File.join(File.dirname(__FILE__),'place_test_file.txt').freeze

    before do
      ActionMailer::Base.deliveries = []
      process_row = lambda{|row|
        TestUserMailer.mail_user(row['email'],"Thank-you for your purchase of #{row['purchased']}",row['firstname']).deliver
        sleep(1)
      }
      rm_rf(Dir.glob(File.join(Root_Dir,'log','*')))
      rm_rf(Dir.glob(File.join(Root_Dir,'tmp','*')))
      cache_file = SqlCache.read_cache_file(TEST_FILE)
      @new_queue = DbQueue.new(cache_file,process_row)
    end
    it 'should create a new log file' do
      assert(File.exist?(@new_queue.instance_variable_get("@log_file")))
    end
    it 'should create a new error log file' do
      assert(File.exist?(@new_queue.instance_variable_get("@error_log_file")))
    end

    it 'should run' do
      @new_queue.run
      assert_equal(@new_queue.instance_variable_get("@count"),3)
      assert_equal(@new_queue.instance_variable_get("@update_count"),3)
      assert_equal(@new_queue.instance_variable_get("@error_count"),0)
    end

    it 'should deliver three emails' do
      @new_queue.run
      assert_equal(3,ActionMailer::Base.deliveries.count)
    end
  end


end