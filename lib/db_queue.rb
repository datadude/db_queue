

class DbQueue
  include FileUtils
  Current_file = File.join(File.dirname(__FILE__)).freeze
  Log_dir = File.join(Current_file,'..','log').freeze
  Temp_dir = File.join(Current_file,'..','tmp').freeze
  Defaults = {
      log_file: File.join(Log_dir,'db_queue.log'),
      error_log_file: File.join(Log_dir,'db_queue_error.log'),
      cache_file: File.join(Temp_dir,'db_queue_cache.hsh'),
      id_row: 'id',
      do_reset: false,
      threads: 2
  }

  def initialize(sql_cache_file,callback=nil,params={})
    FileUtils.mkdir_p( Log_dir ) unless Dir.exist?( Log_dir )
    @params = params.reverse_merge(Defaults)
    @params.each do |key,value|
      instance_variable_set("@#{key.to_s}",value)
    end
    @list_mutex = Mutex.new
    @log_mutex = Mutex.new
    @logger = Logger.new(@log_file)
    @logger.info('DBCache initialized.')
    @error_logger = Logger.new(@error_log_file)
    @list = sql_cache_file
    @list.reset_place
    @callback = callback
  end

  def process(thread_no)
    row = {}
    @log_mutex.synchronize do
      @logger.info("Starting Thread ##{thread_no.to_s}")
    end
    begin
      @list_mutex.synchronize{
        row = @list.next_line
      }
      if row
        start_process = Time.now
        success = @callback.call(row)
        @log_mutex.synchronize do
          @count += 1
          @update_count += 1 if success
          @logger.info "Thread ##{thread_no.to_s} #{("Row ID: " + row[@id_row].to_s) if row[@id_row]} Processed: #{(@count).to_s} last process time: #{(Time.now - start_process).round(2).to_s} rate: #{(1/((Time.now - start_process)/60/60) ).to_s} per hour. Total rate: #{(@count/((Time.now - @time_start)/60/60) ).to_s}"
        end
      end
    rescue => e
      @log_mutex.synchronize do
        @count += 1
        @error_count += 1
        @error_logger.error "Thread ##{thread_no.to_s} #{("Row ID: " + row[@id_row].to_s) if row[@id_row]}  Error: #{e.class.name} #{e.message}\n #{(@include_backtrace ? e.backtrace.join("\n") : '')}"
      end
    end while row
  end

  def run
    @time_start = Time.now
    @count = 0
    @error_count = 0
    @update_count = 0
    @list.reset if @do_reset
    threads = []
    (1..@threads).each do |i|
      threads << Thread.new do
        process(i)
      end
    end

    while threads.any?{|thread|thread.status} do
      sleep(1)
    end

    @logger.info "Work complete, Count :#{@count.to_s}, Total time: #{( Time.now - @time_start).to_s}, successful updates: #{@update_count.to_s}, errors: #{@error_count.to_s} rate: #{(@count/(( Time.now - @time_start)/60/60)).round(1).to_s} per hour."
  end

end