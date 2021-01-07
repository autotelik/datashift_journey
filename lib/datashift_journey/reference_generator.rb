module DatashiftJourney

  class ReferenceGenerator < Module
    BASE           = 10
    DEFAULT_LENGTH = 9
    NUMBERS        = (0..9).to_a.freeze
    LETTERS        = ('A'..'Z').to_a.freeze

    attr_accessor :prefix, :length

    def initialize(options)
      @random     = Random.new
      @prefix     = options.fetch(:prefix)
      @length     = options.fetch(:length, DEFAULT_LENGTH)
      @candidates = NUMBERS + (options[:letters] ? LETTERS : [])
    end

    def included(host)
      generator_method   = method(:generate_permalink)
      generator_instance = self

      host.class_eval do
        #validates(:reference, presence: true, uniqueness: { allow_blank: true })

        validates_presence_of :reference
        validates_uniqueness_of :reference

        before_validation do |instance|
          instance.reference ||= generator_method.call(host)
        end

        define_singleton_method(:reference_generator) { generator_instance }
      end
    end

    private

    def generate_permalink(host)
      length = @length

      loop do
        candidate = new_candidate(length)
        return candidate unless host.exists?(reference: candidate)

        # If over half of all possible options are taken add another digit.
        length += 1 if host.count > Rational(BASE**length, 2)
      end
    end

    def new_candidate(length)
      @prefix + Array.new(length) { @candidates.sample(random: @random) }.join
    end
  end
end
