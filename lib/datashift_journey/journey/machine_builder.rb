module DatashiftJourney
  module Journey

    class MachineBuilder

=begin API Example

  # With no :machine_name specfied, defaults to use column 'state', which is expected on the journey_plan class

  MachineBuilder.extend_journey_plan_class(initial: :ship_address) do

    sequence [:ship_address, :bill_address]

    split_on_equality( :payment,
                       "payment_card",    # Create helper method on Checkout to return card type from Payment
                       [:visa_page, :mastercard_page, :paypal_page],
                       ['visa', 'mastercard', 'paypal'])

    split_sequence :visa_page, [:page_1_A, :page_2_A]

    split_sequence :mastercard_page, [:page_1_B, :page_2_B, :page_3_B]

    split_sequence :paypal_page, []

    sequence [:review, :complete ]
  end

  # A class can have multiple machines attached via  :machine_name

  MachineBuilder.extend_journey_plan_class(machine_name: :checkout_b, initial: :array1) do
    sequence [:array1, :array2, :array3]
  end

=end

      # N.B This gem is based on the AR integration
      # which uses the Machine name for the Column storing the state in
      # The default name and column is :state
      # Args
      #     :machine_name => :something_different     # Requires Class has a column called something_different
      #     :initial => :first_state
      #
      def self.extend_journey_plan_class(args = {}, &block)
        klass = DatashiftJourney.journey_plan_class

        machine_name = args.has_key?(:machine_name) ? args.delete(:machine_name) : :state

        machine = if(block_given?)
                    klass.class_eval do
                      state_machine machine_name, args do
                        instance_eval(&block)   # sets the context to be StateMachine class'
                      end
                    end
                  else
                    ::StateMachines::Machine.new(klass, machine_name, args)
                  end

        machine

      end

      # N.B This gem is based on the AR integration
      # which uses the Machine name for the Column storing the state in
      # The default name and column is :state
      # Args
      #     :machine_name => :something_different     # Requires Class has a column called something_different
      #     :initial => :first_state
      #
      def self.create_journey_plan(klass, args = {}, &block)

        machine_name = args.has_key?(:machine_name) ? args.delete(:machine_name) : :state

        puts "Building Machine for [#{klass}]"

        machine = if(block_given?)
                    klass.class_eval do
                      state_machine machine_name, args do
                        instance_eval(&block)   # sets the context to be StateMachine class'
                      end
                    end
                  else
                    ::StateMachines::Machine.new(klass, machine_name, args)
                  end

        machine

      end

    end

  end
end
