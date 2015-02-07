require File.join(File.dirname(__FILE__),'../test_environment')


class SqlCacheTest < Minitest::Test

  describe SqlCache do
    include FileUtils
    describe 'Load from SQL' do
      SELECT_SQL = 'SELECT * FROM TEST_TABLE'
      FILE_NAME = File.join(File.dirname(__FILE__),'cache_file.hsh').freeze
      TEST_FILE = File.join(File.dirname(__FILE__),'test_file.hsh').freeze
      PLACE_FILE = File.join(File.dirname(__FILE__),'place_test_file.txt').freeze
      before do
        SqlCache.table_name = 'test_table'
        SqlCache.connection.execute("CREATE TABLE test_table (ID INT NOT NULL PRIMARY KEY, NAME VARCHAR(20))")
        SqlCache.connection.execute("insert into test_table (ID, NAME) values (1,'Test Testerson')")
        SqlCache.connection.execute("insert into test_table (ID, NAME) values (2,'Mini Mouse')")
      end

      after do
        SqlCache.connection.execute('drop table test_table')
      end

      def cache_all
        rm_rf(FILE_NAME) if File.exist?(FILE_NAME)
        @test_table = SqlCache.all
        @test_file = @test_table.cache_result(FILE_NAME)
      end
      def read_cache
        @test_file =  SqlCache.read_cache_file(TEST_FILE)
      end

      describe 'new query' do
        before do
          cache_all
        end
        it 'should create basic tables' do
          @test_table[1].id.must_equal(2)
        end
        it 'should create a cachefile' do
          assert(File.exist?(FILE_NAME))
        end
        it 'should create an object of SqlCacheFile' do
          @test_file.must_be_instance_of SqlCache::SqlCacheFile
        end
        it 'should save correct values in hash file' do
          cache_ary = File.readlines(FILE_NAME)
          cache_ary[0].must_equal("{\"ID\"=>1, \"NAME\"=>\"Test Testerson\"}\n")
        end
        it 'should scroll to the next line' do
          @test_file.next_line
          result_hash = @test_file.next_line
          assert_equal(result_hash,{"ID"=>2, "NAME"=>"Mini Mouse"})
          assert_equal(@test_file.lineno,2)
        end

      end
      describe 'find by sql' do
        it 'should find by sql' do
          @test_file=SqlCache.cache_by_sql(FILE_NAME,'select * from test_table')
        #  puts @test_file.inspect
          @test_file.next_line
          result_hash = @test_file.next_line
          assert_equal(result_hash,{"ID"=>2, "NAME"=>"Mini Mouse"})
          assert_equal(@test_file.lineno,2)
        end
      end
      describe 'Cached query' do
        before do
          read_cache
        end
        it 'should create an object of SqlCacheFile' do
          @test_file.must_be_instance_of SqlCache::SqlCacheFile
        end
        it 'should reset the placeholder' do
          @test_file.reset_place
          assert_equal(File.read(PLACE_FILE),"0")
        end
        it 'should read a cached query' do
          @test_file.reset_place
          (1..2).each do |i|
            @test_file.next_line
          end
          assert_equal(@test_file.next_line,{"id"=>3, "firstname"=>"Donald", "lastname"=>"Duck", "purchased"=>"Singing Lessons", "email"=>"donald.duck@disney.com"})
        end
        it 'should save its place' do
          @test_file.reset_place
          (1..2).each do |i|
            @test_file.next_line
          end
          assert_equal(File.read(PLACE_FILE),"2")
          assert_equal(@test_file.lineno,2)
        end
      end
    end
  end


end
