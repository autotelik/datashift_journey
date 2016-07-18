## DataShift State

[![Build Status](https://travis-ci.org/autotelik/datashift_journey.svg?branch=master)](https://travis-ci.org/autotelik/datashift_journey)

Define a journey through your site, via a simple state based DSL, provides a generic Controller that
manages navigation for you, collect data via a forms based approach. 

Take any ActiveRecord model and add a state machine that manages a multi-page forms based journey
such as a questionnaire, checkout, survey, registration process etc

Provides high level syntactic sugar to program the journey steps, and manage the views and underlying forms.

The paths can split, based on values collected or provided by user, and can reconnect later.

Forward and back navigation through the different paths is automatically generated.

The underlying gems we are using :

* https://github.com/state-machines/state_machines
* https://github.com/state-machines/state_machines-activerecord
* https://github.com/apotonick/reform

## Getting started

This is a Rails engine so simply add this line to your application's Gemfile:

```ruby
gem 'datashift_journey', git: 'https://github.com/autotelik/datashift_journey'
```

And then execute:

    $ bundle install
    
## Setup and Configuration

The app must inform datashift_journey of the model, that hosts the journey plan and stores data collected on the journey.

This will be the parent model off which all the data to be collected should hang, the concept is like a 
Checkout, Registration or Enrollment.

So create a normal Rails model and associated migration.

N.B Your journey class must have a string column called state i.e

class CreateCheckouts < ActiveRecord::Migration
  def change
    create_table :checkouts do |t|
      t.string :state
      t.timestamps null: false
    end

  end
end

Now inform datashift of the name of this class via an initializer

For example, in `config/initializers/datashift_journey.rb`
    
```ruby
  DatashiftJourney.journey_plan_class = "Checkout"
```

The app model will be decorated with an association to the state machine.

### Define the journey

Here's a simple example for a basic checkout, on an ActiveRecord model, `Checkout`

```ruby
DatashiftJourney::Journey::MachineBuilder.build(initial: :ship_address) do

            sequence [:ship_address, :bill_address]

            split_on_equality( :payment,
                               "payment_card",                                # The helper method on Checkout, returns card type from Payment
                               [:visa_page, :mastercard_page, :paypal_page],  # Target pages
                               ['visa', 'mastercard', 'paypal'])              # Value to trigger target

            split_sequence :visa_page, [:page_1_A, :page_2_A]

            split_sequence :mastercard_page, [:page_1_B, :page_2_B, :page_3_B]

            split_sequence :paypal_page, []

            # The end points of each split will re-attach to the start of this sequence
            sequence [:review, :complete ]
```
    
This will generate  a series of states (steps) and the navigation between them.

A view partial and associated form, will be expected for each state.

### Rendering Views

If you need to set the location of the partials for rendering states, over ride the path via helper
`journey_plan_partial_location` in `app/helpers/application_helper.rb`

```ruby
    def journey_plan_partial_location(state)
      "my_path/states/#{state}"
    end
```

## License

Author ::   Tom Statter

Date ::     April 2016

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
