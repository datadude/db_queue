require 'logger'
require 'active_record'
require 'action_mailer'
require 'action_view'
require 'haml'
require 'haml/template/plugin'
require 'haml/template/options'
#find the root of the project
Root_Dir = File.join(File.dirname(__FILE__)).freeze
#load up the lib dir
Dir.glob(File.join(Root_Dir,'lib','*.rb')){|file|require file }
