
class SqlCache < ActiveRecord::Base
  self.abstract_class = true
  include FileUtils
  attr_accessor :filename
  def self.read_cache_file(filename)
    SqlCacheFile.new(filename)
  end
  def self.cache_by_sql(filename,sql)
    result = find_by_sql(sql)
    SqlCacheFile.new(filename,result)
  end

  class ActiveRecord_Relation
    def cache_result(filename)
      SqlCacheFile.new(filename,self)
    end
  end
  class SqlCacheFile
    def initialize(filename,result_set=nil)
      @filename = filename
      if File.exist?(filename) && !result_set
        @cache_file = File.open(filename,'r')
        self.lineno = read_place
      else
        FileUtils.mkdir_p(File.dirname(filename)) unless Dir.exist?(File.dirname(filename))
        hash_ary = result_set.to_a.map(&:serializable_hash)
        @cache_file = File.open(filename,'w')
        begin
          hash_ary.each do |qhash|
            @cache_file.puts(qhash)
          end
        ensure
          @cache_file.close
          @cache_file = File.open(filename,'r')
          save_place
        end
      end
    end
    def lineno
      @cache_file.lineno
    end
    def lineno=(lineno)
      @cache_file.rewind
      (0..lineno-1).each{|i| @cache_file.gets}
      save_place
    end

    def next_line
      begin
        result = instance_eval @cache_file.readline("\n")
        save_place
      rescue EOFError
        result = nil
      end
      result
    end

    def reset_place
      @cache_file.rewind
      save_place
    end
    def reload_file
      @cache_file = File.open(filename,'r')
      save_place
    end
    private
    def place_file_name
      File.join(File.dirname(@filename),"place_#{File.basename(@filename,'.hsh')}.txt")
    end
    def save_place
      File.open(place_file_name,'w'){|f| f.print(@cache_file.lineno.to_s)}
    end
    def read_place
      File.exist?(place_file_name) ? File.open(place_file_name,'r'){|f| f.readline.to_i} : 0
    end

  end

end