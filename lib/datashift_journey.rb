require 'rails'
require 'state_machines-activerecord'
require 'has_secure_token'

require_relative 'datashift_journey/engine'
require 'reform'
require 'reform/form'

module DatashiftJourney

  def self.library_path
    File.expand_path("#{File.dirname(__FILE__)}/../lib")
  end

  # Load all the datashift Thor commands and make them available throughout app

  def self.load_commands
    base = File.join(library_path, 'tasks', '**')

    Dir["#{base}/*.thor"].each do |f|
      next unless File.file?(f)
      load(f)
    end
  end
end
