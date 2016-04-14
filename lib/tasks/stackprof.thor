ENV['RAILS_ENV'] = 'test'

require 'stackprof'

module We

  class Stack < Thor

    desc "prof", "Run rspec tests via StackProf, display results"

    method_option :specs, aliases: '-s', required: false, default: 'spec', desc: "The spec files to run"

    method_option :interval, aliases: '-i', required: false,
                  type: :numeric, default: 1000, desc: "The sampling interval"

    method_option :limit, aliases: '-l', required: false, type: :numeric,
                  default: 20, desc: "Max number results to output"

    def prof

      $:.unshift 'spec'
      require 'rspec'
      require 'rails_helper'

      spec = options[:specs]

      interval = options[:interval]
      limit = options[:limit]

      output_file = "tmp/#{spec.split('/').last}.dump"

      StackProf.run(mode: :cpu, out: output_file, interval: interval) do
        RSpec::Core::Runner.run([spec], $stderr, $stdout)
      end

      system("stackprof #{output_file} --text --limit #{limit}")
    end
  end
end

